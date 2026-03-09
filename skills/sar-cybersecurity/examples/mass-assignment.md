# Example: Mass Assignment via Unfiltered Body in Update Operations

> *Reference output — load on demand when analyzing endpoints that pass request bodies directly to ORM/ODM update methods.*
>
> ⚠️ **Example only** — All patterns below are synthetic descriptions of vulnerable code and correct SAR output. They are not real code and must not be executed.

## Scenario

An endpoint calls a database update method with the full request body without filtering which fields the client can modify.

```text
Vulnerable pattern (pseudocode):

  File: src/users/users.controller.ts — line 45
  Route: PATCH /users/:id
  Guards: JwtAuthGuard (authenticated, but no role check)
    → extracts 'id' from URL params and 'body' from request
    → passes both directly to usersService.update(id, body)

  File: src/users/users.service.ts — line 30
  Function: update(id, data)
    → calls userModel.findByIdAndUpdate(id, data, { new: true })
    → no field filtering — all body fields are written to the document

  Mongoose schema sensitive fields: role, isAdmin, balance, verified, email, name, phone
```

## Assessment Trace

1. **Entry point**: `PATCH /users/:id` — authenticated (JWT guard), but no role check.
2. **Input handling**: `req.body` passed directly to `findByIdAndUpdate` — no field filtering.
3. **Schema analysis**: User schema contains sensitive fields: `role` (String, default: 'user'), `isAdmin` (Boolean, default: false), `balance` (Number), `verified` (Boolean).
4. **Attack scenario**: Authenticated user sends `{ "role": "admin", "isAdmin": true, "balance": 999999 }` → all fields modified.
5. **IDOR check**: No verification that `req.user.id === id` — user can modify **any** user's profile, including escalating other accounts.
6. **Schema strict mode**: Schema uses `strict: true`, which only prevents fields **not** in the schema — all listed fields are in the schema and therefore writable.

## SAR Finding

### [88] — Mass Assignment + IDOR on User Update Endpoint

- **Description**: `PATCH /users/:id` passes the full request body to `findByIdAndUpdate` without field filtering. Any authenticated user can modify any field (including `role`, `isAdmin`, `balance`) on any user account (IDOR — no ownership check).
- **Affected Component(s)**: `src/users/users.controller.ts:45`, `src/users/users.service.ts:30`
- **Evidence**:
  ```text
  Attack payload: PATCH /users/<OTHER_USER_ID>
  Body: fields set to role=admin, isAdmin=true, balance=999999
  Result: Target user escalated to admin with modified balance
  ```
- **Standards Violated**: OWASP Top 10 (A01:2021 Broken Access Control, A04:2021 Insecure Design), ISO 27001 A.9.4 (System Access Control), NIST SP 800-53 AC-6 (Least Privilege), PCI-DSS Req. 7.1, SOC 2 CC6.1
- **MITRE ATT&CK**: T1098 (Account Manipulation), T1548 (Abuse Elevation Control Mechanism)
- **Score**: **88** (High) — authenticated endpoint (not public, reducing from Critical), but privilege escalation + IDOR on financial data confirmed.
- **Suggested Mitigation Actions**:
  1. **Immediate**: Add IDOR check — verify `req.user.id === id` or `req.user.role === 'admin'`
  2. **Field allowlist**: Replace raw body passthrough with a utility that picks only allowed fields (name, phone, bio, avatar) before passing to the update method
  3. **Create a DTO**: Use class-validator + class-transformer with explicit exclusion of sensitive fields
  4. **Separate admin endpoint**: Create `PATCH /admin/users/:id` with explicit admin guard for privileged field modifications
  5. **Audit trail**: Log all user update operations with before/after field values

## Key Principles Demonstrated

- **Compound vulnerability**: Mass assignment + IDOR identified together, scored on combined impact
- **Schema analysis**: Checked which sensitive fields exist and are writable, not just that the pattern exists
- **Defense-in-depth mitigation**: IDOR fix + field allowlist + DTO + separate admin endpoint

## Cross-Reference

- All mass assignment patterns → see [`frameworks/injection-patterns.md`](../frameworks/injection-patterns.md)
- Compliance standards for access control → see [`frameworks/compliance-standards.md`](../frameworks/compliance-standards.md)
- Scoring rules → see [`frameworks/scoring-system.md`](../frameworks/scoring-system.md)
