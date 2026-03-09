# Example: Regex Injection / ReDoS via Unsanitized Search Input

> *Reference output — load on demand when analyzing search endpoints that construct regex from user input.*
>
> ⚠️ **Example only** — All patterns below are synthetic descriptions of vulnerable code and correct SAR output. They are not real code and must not be executed.

## Scenario

A search endpoint constructs a dynamic regex from user input and uses it in a MongoDB query. Input is not escaped.

```text
Vulnerable pattern (pseudocode):

  File: src/products/products.service.ts — line 67
  Function: search(searchValue)
    → constructs new RegExp(searchValue, 'i') — no escaping of metacharacters
    → passes regex object to MongoDB regex query on name field, with .limit(50)

  File: src/products/products.controller.ts — line 23
  Route: GET /products/search?q=...
    → query parameter 'q' passed directly to search() — public endpoint
```

## Assessment Trace

1. **Entry point**: `GET /products/search?q=...` — public endpoint.
2. **Input handling**: Query parameter `q` passed directly to `new RegExp()` without escaping metacharacters.
3. **Attack vector 1 — Data exfiltration** (**primary SAR concern**): Attacker sends a wildcard-match-all pattern → regex matches all documents → returns first 50 products (limited by `.limit(50)`, but reveals data patterns). Attacker can iterate with prefix patterns (A, B, etc.) to enumerate the entire catalog.
4. **Attack vector 2 — ReDoS** (**availability-only, secondary**): Attacker sends a nested-quantifier pattern → catastrophic backtracking → MongoDB/Node.js CPU exhaustion → service degradation. No data is exposed through this vector.
5. **Impact classification**: **Dual-vector** — same vulnerability enables both data exfiltration (primary) and service disruption (secondary). Score on the exfiltration vector per Confidentiality Primacy rule.
6. **Codebase scan**: Found **8 files with 23 total occurrences** of `new RegExp(userInput)` without escaping. All use the same pattern.

## SAR Finding

### [82] — Regex Injection with Data Enumeration via Unsanitized Search Input (23 Occurrences)

- **Description**: 23 occurrences across 8 files construct `RegExp` from user input without escaping metacharacters. Attackers can inject wildcard patterns (match-all, prefix-match) to enumerate data beyond their authorization. A secondary ReDoS vector (nested-quantifier catastrophic backtracking) enables service degradation but is not the primary concern — data exfiltration is.
- **Affected Component(s)**: `src/products/products.service.ts:67` and 22 additional occurrences (see Appendix)
- **Evidence**:
  ```text
  Primary vector (data exfiltration): wildcard-match-all query → matches all documents, returns 50 per request
  Enumeration: prefix-based queries (A, B, ...) → iterative extraction of full catalog
  Secondary vector (availability): nested-quantifier query → catastrophic backtracking, >10s CPU per request
  ```
- **Standards Violated**: OWASP Top 10 (A03:2021 Injection), NIST SP 800-53 SI-10 (Information Input Validation), ISO 27001 A.14.2, CIS Controls 16.4, GDPR Art. 32 (if product data includes supplier PII or customer-facing pricing strategies)
- **MITRE ATT&CK**: T1190 (Exploit Public-Facing Application), T1530 (Data from Information Repositories)
- **Impact Classification**: **Dual-vector** — data exfiltration (primary) + availability (secondary). Scored on exfiltration.
- **Score**: **82** (High) — public endpoints, systemic pattern, data enumeration confirmed via wildcard injection. The ReDoS vector alone would cap at 45 (availability-only), but the data exfiltration vector elevates this to a primary finding.
- **Score Justification**:
  - Base severity: 85 (regex injection with confirmed data exfiltration path)
  - Exploitation Complexity: no adjustment — public endpoint, no auth
  - Impact Scope: no adjustment — `.limit(50)` bounds per-request exposure, but iterative enumeration is trivial
  - Data Sensitivity: −3 (product catalog data — commercial value but not PII/credentials in this case)
  - **Final: 82** (High — data exfiltration is the driver, not DoS)
- **Suggested Mitigation Actions**:
  1. **Immediate**: Create a centralized `safeRegExp` utility that escapes all regex metacharacters before constructing the RegExp object
  2. **Replace all occurrences**: Apply `safeRegExp` across all 23 occurrences
  3. **Prefer text search**: Replace regex-based queries with MongoDB text index search for user-facing search endpoints
  4. **Query timeout**: Set `maxTimeMS(5000)` on all search queries as a safety net against the ReDoS vector
  5. **Testing**: Add fuzzing tests with both exfiltration patterns (wildcard, prefix-match) and ReDoS payloads (nested-quantifier)

## Key Principles Demonstrated

- **Confidentiality primacy**: The score is driven by the data exfiltration vector, not the ReDoS/availability vector
- **Impact classification**: Dual-vector finding explicitly identifies which vector determines the score
- **Availability delegation**: The ReDoS vector is documented as secondary; alone it would cap at 45
- **Systemic count**: Reported total occurrences across the codebase, not just the first finding

## Cross-Reference

- All regex/ReDoS patterns → see [`frameworks/injection-patterns.md`](../frameworks/injection-patterns.md)
- Scoring rules → see [`frameworks/scoring-system.md`](../frameworks/scoring-system.md)
