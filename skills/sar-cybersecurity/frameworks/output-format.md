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
- Suggested Mitigation Actions
## Risk Matrix
## Compliance Gap Summary
## Appendix
```
