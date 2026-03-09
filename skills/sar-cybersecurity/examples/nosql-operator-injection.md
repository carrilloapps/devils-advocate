# Example: NoSQL Operator Injection via Direct Body Passthrough

> *Reference output — load on demand when analyzing MongoDB/NoSQL query patterns with user input.*
>
> ⚠️ **Example only** — All patterns below are synthetic descriptions of vulnerable code and correct SAR output. They are not real code and must not be executed.

## Scenario

An endpoint passes `req.body` directly into a MongoDB query. An attacker sends an operator object instead of a string to extract all records.

```text
Vulnerable pattern (pseudocode):

  File: src/auth/auth.service.ts — line 34
  Function: findUser(email)
    → calls userModel.findOne({ email })
    → 'email' comes directly from req.body.email — no sanitization

  File: src/auth/auth.controller.ts — line 12
  Route: POST /login
    → extracts body.email from request body (typed as 'any')
    → passes directly to findUser() — no type validation
    → body.email can be an object instead of a string

  Missing controls: no express-mongo-sanitize, no DTO validation
```

## Assessment Trace

1. **Entry point**: `POST /login` — public endpoint, no auth required.
2. **Input handling**: `body.email` passed to `findUser()` without type validation — can be `{"$ne": null}`.
3. **Schema check**: Mongoose schema has `email: { type: String }` but `strict: true` only applies to document creation, not query filters.
4. **Middleware check**: No `express-mongo-sanitize` in middleware chain (`main.ts`, `app.module.ts`).
5. **Impact**: Attacker sends `{"email": {"$ne": null}}` → query becomes `{email: {$ne: null}}` → returns the **first user in the collection** (typically an admin created early). Combined with password-less flows or password reset, this enables full account takeover.
6. **Scale**: Searched codebase for similar patterns — found **14 additional endpoints** passing `req.body` fields directly to `.find()`, `.findOne()`, or `.aggregate()`.

## SAR Finding

### [92] — NoSQL Operator Injection via Direct Body Passthrough (15 Endpoints)

- **Description**: `POST /login` and 14 additional endpoints pass user input directly to MongoDB query filters without sanitization. An attacker can inject operators like `{"$ne": null}`, `{"$gt": ""}`, or `{"$regex": ".*"}` to bypass authentication, enumerate data, or extract the entire collection.
- **Affected Component(s)**: `src/auth/auth.service.ts:34`, `src/auth/auth.controller.ts:12`, and 14 additional endpoints (see Appendix for full list)
- **Evidence**:
  ```text
  Attack payload: POST /login with email field set to a "not-equal-null" operator object
  Query executed: findOne with operator filter instead of string match
  Result: Returns first user document in collection (typically admin)
  ```
- **Standards Violated**: OWASP Top 10 (A03:2021 Injection), NIST SP 800-53 SI-10, CIS Controls 16.4, ISO 27001 A.14.2, GDPR Art. 32 (if PII exposed), SOC 2 CC6.6
- **MITRE ATT&CK**: T1190 (Exploit Public-Facing Application), T1078 (Valid Accounts — via auth bypass)
- **Score**: **92** (Critical) — public endpoint, no sanitization at any layer, full collection exfiltration possible, PII exposure confirmed (email, name, phone fields in user schema).
- **Suggested Mitigation Actions**:
  1. **Immediate**: Install and apply `express-mongo-sanitize` as global middleware
  2. **Short-term**: Create DTOs for all endpoints with `class-validator` type enforcement (`@IsString()`, `@IsEmail()`)
  3. **Medium-term**: Audit all 15 endpoints for explicit field validation; replace `Model.findOne(bodyField)` with `Model.findOne({ email: String(bodyField) })`
  4. **Schema hardening**: Ensure `strict: true` on all Mongoose schemas
  5. **Testing**: Add integration tests with operator injection payloads (`$ne`, `$gt`, `$regex`, `$where`)

## Key Principles Demonstrated

- **Systemic pattern detection**: Found 14 additional vulnerable endpoints beyond the initial finding
- **Full attack chain**: Traced from public endpoint to database query to data exposure
- **PII impact assessment**: Evaluated which fields are exposed, not just that a query is injectable
- **Layered mitigation**: Immediate → short-term → medium-term remediation path

## Cross-Reference

- All NoSQL injection patterns → see [`frameworks/injection-patterns.md`](../frameworks/injection-patterns.md)
- MongoDB inspection procedures → see [`frameworks/database-access-protocol.md`](../frameworks/database-access-protocol.md)
- Standard mapping guide → see [`frameworks/compliance-standards.md`](../frameworks/compliance-standards.md)
