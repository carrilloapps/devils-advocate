# Example: Secrets Committed to Source Control

> *Reference output — load on demand when assessing repositories for leaked credentials, API keys, or hardcoded secrets.*
>
> ⚠️ **Example only** — All patterns, shell output, and credential placeholders below are synthetic descriptions of vulnerable configurations and correct SAR output. They are not real secrets and must not be executed or used.

## Scenario

The git repository contains `.env` files, hardcoded API keys, and database connection strings with credentials.

```text
Discovery (pseudocode):

  git ls-files '*.env*' reveals 3 committed environment files:
    .env
    .env.production
    docker/.env.local
```

```text
Sensitive content found in .env.production (committed to repo):

  <DB_CONN_VAR>             = <protocol>://<user>:<pass>@<host>:<port>/<db>
  <SIGNING_KEY_VAR>         = <plaintext-signing-key>
  <CLOUD_ACCESS_ID_VAR>     = <cloud-access-id-placeholder>
  <CLOUD_SECRET_VAR>        = <cloud-secret-placeholder>
  <PAYMENT_KEY_VAR>         = <payment-key-placeholder>
```

```text
Hardcoded credential in source code:

  File: src/config/database.ts — line 8
  Variable: DB_CONNECTION_STRING
    → contains full connection string with plaintext username and password
```

## Assessment Trace

1. **Git file scan**: `.env`, `.env.production`, and `docker/.env.local` are tracked in git (not in `.gitignore`).
2. **Secret pattern scan**: Found 12 secrets across 6 files:
   - 3 `.env*` files: DB credentials, token signing key, cloud provider keys, payment API key
   - `src/config/database.ts`: hardcoded connection string
   - `Dockerfile`: signing key set via ENV directive in build args
   - `docker-compose.yml`: plaintext credentials in environment section
3. **Git history check**: `git log` shows `.env` committed 14 months ago, `.env.production` committed 8 months ago.
4. **`.gitignore` check**: No `.env*` pattern found in `.gitignore`.
5. **Secrets manager**: No references to AWS Secrets Manager, Vault, or any secrets management service across the codebase.
6. **CI/CD check**: GitHub Actions workflow uses masked secrets in one step but echoes a database URL variable in a debug step (log exposure).

## SAR Finding

### [93] — Secrets Committed to Source Control (12 Secrets, 6 Files, 14 Months Exposure)

- **Description**: 12 production secrets (database credentials, token signing key, cloud access keys, payment API key) are committed to the repository across 6 files. Secrets have been in git history for up to 14 months. No secrets management service is used. CI/CD pipeline echoes one secret to build logs.
- **Affected Component(s)**: `.env`, `.env.production`, `docker/.env.local`, `src/config/database.ts:8`, `Dockerfile`, `docker-compose.yml`, `.github/workflows/deploy.yml`
- **Evidence**:
  ```text
  Committed files: git ls-files '*.env*' → 3 files tracked
  History: first .env commit was 14 months ago
  Hardcoded: connection string with credentials in src/config/database.ts line 8
  Docker: signing key visible in image layers via ENV directive
  CI/CD: database URL echoed to build logs in debug step
  ```
- **Standards Violated**: OWASP Top 10 (A02:2021 Cryptographic Failures, A05:2021 Security Misconfiguration), ISO 27001 A.9.2, A.10.1 (access management, cryptography), NIST SP 800-53 IA-5 (Authenticator Management), CIS Controls 16.1, PCI-DSS Req. 3.4, 8.2 (if payment data), SOC 2 CC6.1, GDPR Art. 32 (if DB contains EU PII)
- **MITRE ATT&CK**: T1552.001 (Credentials in Files), T1552.004 (Private Keys), T1528 (Steal Application Access Token)
- **Score**: **93** (Critical) — production secrets, 14 months exposure in git history, no secrets manager, all contributors and any repo clone have full access.
- **Suggested Mitigation Actions**:
  1. **Emergency (within hours)**:
     - Rotate **all** exposed credentials immediately: DB password, signing key, cloud access keys, payment API key
     - Revoke the cloud access key via the provider's IAM console
     - Regenerate payment API key in the provider's dashboard
  2. **Immediate (within 24h)**:
     - Add `.env*` patterns to `.gitignore`
     - Remove secrets from `Dockerfile` — use runtime injection
     - Fix CI/CD pipeline — remove debug echo of database URL variable, use GitHub Actions masked secrets
  3. **Short-term**:
     - Purge git history using `git filter-repo` or BFG Repo-Cleaner to remove all .env files from history
     - Force-push cleaned history (coordinate with team — destructive operation)
     - Replace hardcoded connection string in source code with environment variable reference
  4. **Medium-term**:
     - Adopt AWS Secrets Manager (or HashiCorp Vault) for all production secrets
     - Add pre-commit hooks: `gitleaks` or `detect-secrets` to prevent future leaks
     - Docker: use multi-stage builds + runtime secret injection (Docker secrets, ECS task secrets)
     - Set up automated secret scanning (GitHub Secret Scanning, GitGuardian)

## Key Principles Demonstrated

- **Historical analysis**: Checked git history, not just current HEAD
- **Comprehensive scan**: Found secrets in code, env files, Dockerfile, docker-compose, and CI/CD
- **Credential rotation priority**: Emergency rotation before any cleanup — secrets are already exposed
- **Cascading remediation**: Rotate → gitignore → purge history → adopt secrets manager → prevent recurrence

## Cross-Reference

- All secrets/storage patterns → see [`frameworks/storage-exfiltration.md`](../frameworks/storage-exfiltration.md)
- Compliance standards → see [`frameworks/compliance-standards.md`](../frameworks/compliance-standards.md)
- Scoring system → see [`frameworks/scoring-system.md`](../frameworks/scoring-system.md)
