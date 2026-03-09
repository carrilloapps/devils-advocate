# Criticality Scoring System

> *Protocol file — free to load, does not count toward context budget.*

Score every finding from **100 (most critical) to 0 (no risk)**. Report only findings **above 50** as primary content. Items scoring 1–50 appear as **warnings** or **informational notes**.

| Score | Label         | Action Required       |
|-------|---------------|-----------------------|
| 90–100 | Critical     | Immediate remediation |
| 70–89  | High         | Urgent remediation    |
| 50–69  | Medium       | Planned remediation   |
| 25–49  | Low/Warning  | Monitor and log       |
| 1–24   | Informational | Optional improvement |
| 0      | None         | No action needed      |

## Scoring Adjustments

- Vulnerability unreachable via any public-facing surface → **cap at 40**
- Vulnerability mitigated by upstream validation, guard, pipe, or middleware → **downgrade to warning range (25–49)**, with the mitigating factor documented explicitly

## Scoring Decision Flow

```
Finding identified
       │
       ▼
Is the vulnerability reachable via any network-exposed surface?
       │
   NO ─┤── Cap score at 40 (Low/Warning max)
       │
   YES ▼
Are existing controls mitigating the risk?
       │
   YES ┤── Downgrade to 25–49, document the mitigating control
       │
   NO  ▼
Score based on net effective risk (50–100)
       │
       ▼
Map to applicable standards + MITRE ATT&CK
       │
       ▼
Write actionable mitigation steps
```
