# Output Specification

> *Protocol file — free to load, does not count toward context budget.*

## Directory

```
docs/security/
```

Create this directory if it does not exist. All SAR files go here and nowhere else.

## File Naming

Every report generates **exactly two linked files**:

```
[DD-MM-YYYY]_[SHORT-TITLE]_EN.md   ← English (en_US)
[DD-MM-YYYY]_[SHORT-TITLE]_ES.md   ← Spanish (es_VE)
```

Example:

```
docs/security/09-03-2026_SQL-INJECTION-RISK_EN.md
docs/security/09-03-2026_SQL-INJECTION-RISK_ES.md
```

Each file must contain a cross-language link at the top:

```markdown
> 🌐 **Also available in:** [Español (es_VE)](./09-03-2026_SQL-INJECTION-RISK_ES.md)
```

## Required Document Structure (each file)

```markdown
# [Report Title] — [LANG]

> 🌐 Also available in: [link to counterpart]

## Table of Contents
## Executive Summary
## Scope & Methodology
## Findings  (ordered 100 → 51, then warnings 50 → 1)
### [SCORE] — [Finding Title]
- Description
- Affected Component(s)
- Evidence / Code Reference
- Standards Violated
- MITRE ATT&CK Technique (if applicable)
- Score Justification (list every exploitation complexity, impact scope, and data sensitivity factor)
- Suggested Mitigation Actions
## Security Posture Dashboard
## Risk Matrix
## Compliance Gap Summary
## Appendix
```

---

## Security Posture Dashboard (mandatory)

Every SAR must include a **Security Posture Dashboard** section immediately after Findings and before Risk Matrix. This section provides quantitative metrics that serve as measurable OKRs for the assessed system.

### Required metrics

Calculate and present the following metrics based on the assessment results:

| Metric | Formula | Example |
|--------|---------|--------|
| **Assessment Coverage** | (Endpoints/components analyzed ÷ total endpoints/components discovered) × 100 | 87% (48/55 endpoints analyzed) |
| **Secure Surface** | (Endpoints with no findings > 50 ÷ total endpoints analyzed) × 100 | 62% (30/48 endpoints secure) |
| **Critical Exposure** | (Endpoints with findings ≥ 90 ÷ total endpoints analyzed) × 100 | 8% (4/48 critical) |
| **High Exposure** | (Endpoints with findings 70–89 ÷ total endpoints analyzed) × 100 | 12% (6/48 high) |
| **Medium Exposure** | (Endpoints with findings 50–69 ÷ total endpoints analyzed) × 100 | 17% (8/48 medium) |
| **Auth Coverage** | (Endpoints with authentication enforced ÷ total endpoints analyzed) × 100 | 91% (44/48 authenticated) |
| **Input Validation Coverage** | (Endpoints with input validation ÷ endpoints that accept user input) × 100 | 73% (32/44 validated) |
| **Parameterized Query Rate** | (DB queries using parameterized/prepared statements ÷ total DB queries found) × 100 | 85% (34/40 parameterized) |
| **Secrets Hygiene** | (Secrets managed via secrets manager ÷ total secrets discovered) × 100 | 58% (7/12 managed) |
| **Encryption Coverage** | (Data stores with encryption at rest ÷ total data stores) × 100 | 75% (3/4 encrypted) |
| **Compliance Alignment** | (Standards with zero critical gaps ÷ total applicable standards) × 100 | 65% (13/20 aligned) |
| **Mean Finding Score** | Sum of all finding scores ÷ number of findings (primary only, > 50) | 74.3 |
| **Remediation Priority Index** | (Critical + High findings ÷ total primary findings) × 100 | 56% (10/18 urgent) |

### Conditional metrics

Include these when the assessment scope covers the relevant area:

| Metric | When to include | Formula |
|--------|----------------|--------|
| **Cloud Storage Secure Rate** | Cloud storage in scope | (Buckets/containers with proper ACL + encryption ÷ total) × 100 |
| **CORS Policy Compliance** | APIs with CORS | (Endpoints with restrictive CORS ÷ endpoints with CORS enabled) × 100 |
| **Rate Limiting Coverage** | Public APIs | (Public endpoints with rate limiting ÷ total public endpoints) × 100 |
| **Logging & Monitoring Rate** | Observability in scope | (Endpoints with security event logging ÷ total endpoints) × 100 |
| **Dependency Vulnerability Rate** | Dependency audit in scope | (Dependencies with known CVEs ÷ total dependencies) × 100 |
| **RBAC Enforcement Rate** | Role-based access in scope | (Endpoints with role checks ÷ endpoints requiring role checks) × 100 |

### Presentation format

Present the dashboard as a single summary table at the top of the section, followed by a severity distribution breakdown:

```markdown
## Security Posture Dashboard

| Metric | Value | Rating |
|--------|-------|--------|
| Assessment Coverage | 87% (48/55) | ✅ |
| Secure Surface | 62% (30/48) | ⚠️ |
| Critical Exposure | 8% (4/48) | 🟥 |
| ... | ... | ... |

### Severity Distribution

| Severity | Count | % of Findings | % of Surface |
|----------|-------|---------------|-------------|
| Critical (90–100) | 4 | 22% | 8% |
| High (70–89) | 6 | 33% | 12% |
| Medium (50–69) | 8 | 44% | 17% |
| Warning (≤50) | 5 | — | 10% |
| **Secure (no findings)** | **30** | **—** | **62%** |
```

### Rating thresholds

| Rating | Symbol | Condition |
|--------|--------|----------|
| Good | ✅ | Metric ≥ 80% (or ≤ 10% for exposure metrics) |
| Needs improvement | ⚠️ | Metric 50–79% (or 11–30% for exposure) |
| Critical | 🟥 | Metric < 50% (or > 30% for exposure) |

> **Rule**: All percentages must show both the percentage and the raw count in parentheses (e.g., `62% (30/48)`). Raw counts without percentages or percentages without raw counts are incomplete.
