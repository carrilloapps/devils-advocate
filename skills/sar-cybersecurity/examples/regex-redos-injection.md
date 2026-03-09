# Example: Regex Injection / ReDoS via Unsanitized Search Input

> *Reference output — load on demand when analyzing search endpoints that construct regex from user input.*
>
> ⚠️ **Example only** — All code snippets below are synthetic illustrations of vulnerable patterns and correct SAR output. They are not real code and must not be executed.

## Scenario

A search endpoint constructs `new RegExp(req.body.search_value, 'i')` and uses it in a MongoDB query. Input is not escaped.

```typescript
// src/products/products.service.ts — line 67
async search(searchValue: string) {
  const regex = new RegExp(searchValue, 'i'); // No escaping
  return this.productModel.find({ name: { $regex: regex } }).limit(50);
}
```

```typescript
// src/products/products.controller.ts — line 23
@Get('search')
async search(@Query('q') q: string) {
  return this.productsService.search(q);
}
```

## Assessment Trace

1. **Entry point**: `GET /products/search?q=...` — public endpoint.
2. **Input handling**: Query parameter `q` passed directly to `new RegExp()` without escaping metacharacters.
3. **Attack vector 1 — Data exfiltration**: Attacker sends `q=.*` → regex matches all documents → returns first 50 products (limited by `.limit(50)`, but reveals data patterns).
4. **Attack vector 2 — ReDoS**: Attacker sends `q=(a+)+$` → catastrophic backtracking → MongoDB/Node.js CPU exhaustion → service degradation.
5. **Codebase scan**: Found **8 files with 23 total occurrences** of `new RegExp(userInput)` without escaping. All use the same pattern.

## SAR Finding

### [82] — Regex Injection / ReDoS via Unsanitized Search Input (23 Occurrences)

- **Description**: 23 occurrences across 8 files construct `RegExp` from user input without escaping metacharacters. Attackers can inject regex patterns for data enumeration (`.*`) or CPU exhaustion via catastrophic backtracking (`(a+)+$`).
- **Affected Component(s)**: `src/products/products.service.ts:67` and 22 additional occurrences (see Appendix)
- **Evidence**:
  ```
  Exfiltration payload: GET /products/search?q=.*
  ReDoS payload: GET /products/search?q=(a%2B)%2B%24
  CPU impact: Single request causes >10s processing time on nested quantifier
  ```
- **Standards Violated**: OWASP Top 10 (A03:2021 Injection), NIST SP 800-53 SC-5 (Denial of Service Protection), ISO 27001 A.12.1 (Operational Procedures), CIS Controls 16.4
- **MITRE ATT&CK**: T1499.004 (Application or System Exploitation — ReDoS)
- **Score**: **82** (High) — public endpoints, systemic pattern, both data exposure and DoS vectors confirmed.
- **Suggested Mitigation Actions**:
  1. **Immediate**: Create a centralized `safeRegExp` utility:
     ```typescript
     export function safeRegExp(input: string, flags?: string): RegExp {
       const escaped = input.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
       return new RegExp(escaped, flags);
     }
     ```
  2. **Replace all occurrences**: Apply `safeRegExp` across all 23 occurrences
  3. **Prefer text search**: Replace `$regex` with MongoDB `$text` index search for user-facing search endpoints
  4. **Query timeout**: Set `maxTimeMS(5000)` on all search queries as a safety net
  5. **Testing**: Add fuzzing tests with known ReDoS payloads

## Key Principles Demonstrated

- **Dual attack vector**: Identified both data exposure and DoS risks from the same vulnerability
- **Systemic count**: Reported total occurrences across the codebase, not just the first finding
- **Concrete mitigation code**: Provided the exact utility function to fix the pattern

## Cross-Reference

- All regex/ReDoS patterns → see [`frameworks/injection-patterns.md`](../frameworks/injection-patterns.md)
- Scoring rules → see [`frameworks/scoring-system.md`](../frameworks/scoring-system.md)
