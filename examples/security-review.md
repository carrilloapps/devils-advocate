# Example Devil's Advocate Analysis: API Authentication Security Review

> **Original proposal (from Developer):** Add JWT authentication to our internal REST API. Plan: generate a JWT with HS256 signing using a shared secret stored in the codebase, 30-day expiry, no refresh token. The API serves both web clients and mobile apps.

---

## ⚡ IMMEDIATE REPORT — 🔴 Critical Finding

**Finding**: JWT secret hardcoded in source code — committed to the repository, readable by anyone with repo access.
**Domain**: Security
**Why immediate**: Irreversible exposure — once a secret is in git history, rotating it requires not just changing the value but auditing every clone, fork, and CI/CD artifact that pulled the repo.
**Risk if not addressed**: Any developer with repo access can forge valid JWTs and authenticate as any user. No mitigation possible until the secret is rotated and removed from git history.

---
### 🔍 Context Needed

1. **Git history**: Has the secret already been committed? Is it in any previous commit, branch, or PR?
2. **Blast radius**: Which endpoints and data does this API protect? What is the worst-case data accessible with a forged token?
3. **Current API consumers**: How many clients are deployed with this secret? What is the rotation impact?

---
Reply: 📝 [answers] to raise confidence | `continue` to proceed at worst-case score

*(Context provided: "Yes, the secret has been in git for 2 weeks across 3 PRs. API protects user profiles, orders, and payment history. 2 web clients + 1 mobile app deployed.")*

---

## 🛑 HANDBRAKE ACTIVATED

**Critical finding**: Hardcoded JWT secret in git history — active exposure, 2 weeks in repository
**Domain**: Security
**Responsible role**: Security Engineer / AppSec
**Why Handbrake level**: Active secret exposure in version control. The secret must be treated as compromised until rotated. Every token issued with the old secret is potentially forged.

**Context received**: Secret confirmed in git history, endpoints expose PII (profiles, orders, payment history), 3 deployed consumers.

**Specialist context questions sent to Security Engineer / AppSec:**

1. Is there an audit log of API calls made with this key over the 2-week exposure window that could reveal unauthorized access?
2. What is the process for invalidating all currently live tokens immediately upon secret rotation?
3. Should HS256 (symmetric, shared secret) be replaced with RS256 (asymmetric) given that clients only need to verify, not sign?

*(Specialist answered: "No audit log exists — blind period on that 2-week window. Invalidation: no token revocation list exists, so rotation immediately invalidates all live sessions. RS256 recommended — mobile client should never hold the signing key.")*

**Re-analysis**: Secret rotation is mandatory and immediate. Token revocation gap means all active sessions will break on rotation — this requires a coordinated client rollout. RS256 architecture is the correct long-term fix. 30-day expiry and no refresh token are independent High findings.

---

# 🔴 Devil's Advocate Analysis: JWT Authentication Implementation

**Analyzed**: 2026-02-20
**Skill version**: 2.7.8
**Scope**: Security — JWT auth implementation for internal REST API

---

## 📊 Executive Summary

**Overall Risk Rating**: 🔴 Critical

**Key Findings**:
1. JWT secret hardcoded in git — compromised, must be rotated immediately
2. 30-day token expiry with no refresh token means a stolen token is valid for up to 30 days with no revocation mechanism
3. HS256 with a shared secret means every client that can verify tokens can also forge them

**Recommendation**: ❌ Reject and redesign — rotate secret now, switch to RS256, implement refresh token rotation, add a token revocation list

**Analysis Confidence**: 🟢 High — Security Engineer confirmed attack surface and provided architectural guidance

---

## 🛑 Handbrake & ⚡ Immediate Report Status

| Protocol | Finding | Domain | Escalated to | Context received | Risk change |
|----------|---------|--------|-------------|-----------------|-------------|
| ⚡ Immediate | Hardcoded JWT secret in git | Security | Team | ✅ Full — 2 weeks, 3 PRs, PII exposed | ➡️ Confirmed Critical |
| 🛑 Handbrake | Hardcoded JWT secret — active exposure | Security | Security Engineer / AppSec | ✅ Full — RS256 recommended, no revocation list | 🔺 Raised: no audit trail for 2-week exposure |

**Re-analysis note**: Secret rotation confirmed mandatory and immediate. No audit log means the 2-week exposure window cannot be analyzed for unauthorized access — worst-case assumption applies (treat as compromised). RS256 replacement eliminates the shared-secret attack surface permanently.

---

## ✅ Strengths (What Works Well)

1. **JWT standard** — stateless auth with industry-standard tooling; correct choice for REST API
2. **Expiry is defined** — 30 days is too long, but the field exists and can be shortened without a protocol change
3. **Separate auth concern** — authentication is centralized, not scattered across handlers

---

## ❌ Weaknesses (What Could Fail)

### 🔴 Critical Issues (Must fix before production)

1. **Hardcoded JWT secret in git repository** *(Handbrake resolved — rotation required immediately)*
   - **Risk**: Secret readable by any contributor, CI system, or anyone with repo access; allows token forgery
   - **Impact**: Attacker can authenticate as any user and access PII (profiles, orders, payment history)
   - **Likelihood**: High — secret has been in git for 2 weeks across 3 PRs
   - **Mitigation**: (1) Rotate secret immediately in all environments; (2) Remove from git history (`git filter-repo`); (3) Move to environment variable or secrets manager; (4) Audit all 3 deployed consumers for updates

2. **HS256 symmetric signing — clients can forge tokens**
   - **Risk**: HS256 uses the same key for signing and verification. Any consumer that receives the key can issue tokens
   - **Impact**: If a mobile app is compromised, the attacker holds a key that signs tokens for all users
   - **Likelihood**: Medium — mobile apps are decompilable; embedded secrets are regularly extracted
   - **Mitigation**: Switch to RS256 — private key signs (server only), public key verifies (clients). Clients never hold the signing key

### 🟠 High-Priority Issues

1. **30-day token expiry with no refresh token**
   - **Risk**: A stolen token is valid for up to 30 days. No mechanism to revoke it short of rotating the secret (which breaks all sessions)
   - **Impact**: Account takeover window is 30 days on token theft
   - **Mitigation**: Reduce access token expiry to 15 minutes; issue a separate 7-day refresh token with rotation on each use; store refresh tokens server-side for revocation

2. **No token revocation list**
   - **Risk**: Logout does not invalidate the token. A logged-out session's token remains valid until expiry
   - **Impact**: Log out → attacker still has a valid token; no way to force session termination
   - **Mitigation**: Implement a blocklist (Redis with TTL) for revoked token JTI values; check on every request

3. **No rate limiting on the auth endpoint**
   - **Risk**: Token generation endpoint has no rate limit — brute-force or credential stuffing attack surface
   - **Mitigation**: Apply IP-based rate limiting (10 requests/minute); add exponential backoff on failed attempts

### 🟡 Medium-Priority Issues

1. **No `aud` (audience) claim** — token issued for the web app can be replayed against the mobile API and vice versa
2. **Missing `jti` (JWT ID) claim** — required for any revocation list implementation; add now before tokens are issued in volume
3. **No token logging** — there is no audit trail of token issuance; forensic analysis impossible after an incident

---

## ⚠️ Assumptions Challenged

| Assumption | Challenge | Evidence | Risk if wrong |
|---|---|---|---|
| "Hardcoded secret is temporary" | Already in git history — rotation required regardless | ❌ 2 weeks, 3 PRs | Active exposure; treat as compromised |
| "30 days is a reasonable session length" | Industry standard for access tokens is 5–15 minutes | ❌ No refresh strategy | 30-day attack window on any stolen token |
| "Internal API = lower risk" | Internal APIs are primary attack path in supply chain attacks | ❌ No network isolation confirmed | Internal ≠ trusted; lateral movement amplifier |
| "HS256 is sufficient" | Clients receiving the verification key can also forge tokens | ❌ Mobile app embeds the key | Token forgery possible from any compromised client |

---

## 🎯 Edge Cases & Failure Modes

| Scenario | What Happens | Handled? | Risk | Fix |
|----------|-------------|----------|------|-----|
| Token stolen via XSS or MITM | Token valid for 30 days, no revocation | ❌ No | Critical | Short expiry + refresh rotation |
| Mobile app decompiled | HS256 key extracted; attacker forges tokens | ❌ No | Critical | RS256 — public key only in app |
| User logs out | Token still valid until expiry | ❌ No | High | Revocation list (Redis JTI blocklist) |
| Secret rotation required | All live sessions instantly invalidated | ⚠️ Partial | High | Refresh token + rotation strategy |
| Replay attack across services | Token issued for web accepted by mobile API | ❌ No | Medium | `aud` claim validation |

---

## 🔒 Security Concerns

### STRIDE Summary
- **Spoofing**: 🔴 — Hardcoded HS256 secret allows token forgery; any repo access = any identity
- **Tampering**: 🟡 — JWT payload tampered if secret is known (which it is); RS256 eliminates this
- **Repudiation**: 🔴 — No audit log of token issuance; 2-week exposure window unanalyzable
- **Information Disclosure**: 🔴 — Secret in git history; PII accessible via forged tokens
- **Denial of Service**: 🟡 — No rate limiting on auth endpoint; credential stuffing risk
- **Elevation of Privilege**: 🔴 — Any user with repo access can forge admin-level tokens

---

## ⚡ Performance Concerns

- **Bottleneck**: Token validation on every request — synchronous; negligible at current scale
- **Scalability limit**: Redis JTI blocklist grows unboundedly without TTL-matched cleanup; implement TTL = access token expiry
- **Resource usage**: RS256 verification is ~3× slower than HS256 for CPU; at current API scale this is under 1ms per request

---

## 💡 Alternative Solutions

1. **RS256 with JWKS endpoint**
   - Better at: Clients fetch public key dynamically; key rotation without client redeployment
   - Worse at: Slightly more infrastructure (JWKS endpoint)
   - Consider if: Always — for any API with more than one consumer type

2. **Opaque tokens + introspection endpoint**
   - Better at: Instant revocation; no token content exposure
   - Worse at: Every request hits the introspection endpoint (latency, SPOF)
   - Consider if: Revocation SLA is < 1 second (e.g., compliance or financial)

---

## ✅ Recommendations

### Must Do (Immediately — before next deployment)
- [ ] Rotate the JWT secret across all environments now (treat as compromised)
- [ ] Remove secret from git history (`git filter-repo --replace-text`)
- [ ] Move secret to environment variable or secrets manager (Vault, AWS Secrets Manager)
- [ ] Notify all 3 deployed consumers of the breaking change and coordinate rotation

### Must Do (Before production)
- [ ] Switch to RS256 — generate RSA key pair; distribute public key only to clients
- [ ] Reduce access token expiry to 15 minutes; implement 7-day refresh token with rotation
- [ ] Implement JTI-based revocation list in Redis (TTL = access token expiry)
- [ ] Add `aud` claim to scope tokens to their intended consumer
- [ ] Rate-limit the auth endpoint (10 req/min per IP)

### Should Do (Next sprint)
- [ ] Add token issuance audit log (jti, iat, sub, client_id, IP)
- [ ] Add `jti` claim to all issued tokens (required for revocation)
- [ ] Define incident response runbook: what to do if a token is confirmed stolen

---

## 📋 Follow-Up Questions

1. Is there an existing secrets manager (Vault, AWS SSM) already in use that this key can be moved into immediately?
2. What is the rollout coordination process for the 3 deployed consumers when the secret is rotated?
3. Is there any compliance requirement (SOC 2, PCI-DSS) that mandates a specific audit log retention period for authentication events?

---
🔴 Devil's Advocate complete.

**Before I proceed, please confirm:**
- [ ] I have reviewed all Critical and High issues above
- [ ] I accept the risks marked as accepted (or they are mitigated)
- [ ] I want to proceed with the approved action

Reply with:
  ✅ Proceed   — continue with the approved action as planned
  🔁 Revise    — describe the change and I will re-analyse
  ❌ Cancel    — stop, do not implement
  `continue`   — proceed without addressing remaining issues (risks remain active and unmitigated)