# Example: Secrets Committed to Source Control

> *Reference output — load on demand when assessing repositories for leaked credentials, API keys, or hardcoded secrets.*
>
> ⚠️ **Example only** — All code snippets, shell commands, and credential patterns below are synthetic illustrations of vulnerable configurations and correct SAR output. They are not real secrets and must not be executed or used.

## Scenario

The git repository contains `.env` files, hardcoded API keys, and database connection strings with credentials.

```bash
# git ls-files shows committed .env
$ git ls-files '*.env*'
.env
.env.production
docker/.env.local
```

```ini
# .env.production (committed to repo)
DATABASE_URL=mongodb://admin:S3cretP@ss!@prod-db.cluster.mongodb.net:27017/myapp
JWT_SECRET=my-super-secret-jwt-key-2024
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
STRIPE_SECRET_KEY=sk_live_51H7...
```

```typescript
// src/config/database.ts — line 8
const MONGO_URI = 'mongodb://admin:S3cretP@ss!@prod-db.cluster.mongodb.net:27017/myapp';
```

## Assessment Trace

1. **Git file scan**: `.env`, `.env.production`, and `docker/.env.local` are tracked in git (not in `.gitignore`).
2. **Secret pattern scan**: Found 12 secrets across 6 files:
   - 3 `.env*` files: DB credentials, JWT secret, AWS keys, Stripe key
   - `src/config/database.ts`: hardcoded MongoDB connection string
   - `Dockerfile`: `ENV JWT_SECRET=...` in build args
   - `docker-compose.yml`: plaintext credentials in environment section
3. **Git history check**: `git log --all --diff-filter=A -- '*.env*'` shows `.env` committed 14 months ago, `.env.production` committed 8 months ago.
4. **`.gitignore` check**: No `.env*` pattern found in `.gitignore`.
5. **Secrets manager**: No references to AWS Secrets Manager, Vault, or any secrets management service across the codebase.
6. **CI/CD check**: GitHub Actions workflow uses `${{ secrets.AWS_KEY }}` in one step but `echo $DATABASE_URL` in debug step (log exposure).

## SAR Finding

### [93] — Secrets Committed to Source Control (12 Secrets, 6 Files, 14 Months Exposure)

- **Description**: 12 production secrets (database credentials, JWT signing key, AWS access keys, Stripe API key) are committed to the repository across 6 files. Secrets have been in git history for up to 14 months. No secrets management service is used. CI/CD pipeline echoes one secret to build logs.
- **Affected Component(s)**: `.env`, `.env.production`, `docker/.env.local`, `src/config/database.ts:8`, `Dockerfile`, `docker-compose.yml`, `.github/workflows/deploy.yml`
- **Evidence**:
  ```
  Committed files: git ls-files '*.env*' → 3 files tracked
  History: git log --all --diff-filter=A -- '.env' → first commit: 14 months ago
  Hardcoded: MONGO_URI in src/config/database.ts line 8
  Docker: ENV JWT_SECRET=... visible in image layers
  CI/CD: echo $DATABASE_URL in deploy.yml debug step
  ```
- **Standards Violated**: OWASP Top 10 (A02:2021 Cryptographic Failures, A05:2021 Security Misconfiguration), ISO 27001 A.9.2, A.10.1 (access management, cryptography), NIST SP 800-53 IA-5 (Authenticator Management), CIS Controls 16.1, PCI-DSS Req. 3.4, 8.2 (if payment data), SOC 2 CC6.1, GDPR Art. 32 (if DB contains EU PII)
- **MITRE ATT&CK**: T1552.001 (Credentials in Files), T1552.004 (Private Keys), T1528 (Steal Application Access Token)
- **Score**: **93** (Critical) — production secrets, 14 months exposure in git history, no secrets manager, all contributors and any repo clone have full access.
- **Suggested Mitigation Actions**:
  1. **Emergency (within hours)**:
     - Rotate **all** exposed credentials immediately: MongoDB password, JWT secret, AWS keys, Stripe key
     - Revoke the AWS access key via IAM console
     - Regenerate Stripe API key in Stripe dashboard
  2. **Immediate (within 24h)**:
     - Add `.env*` patterns to `.gitignore`
     - Remove secrets from `Dockerfile` — use runtime injection
     - Fix CI/CD pipeline — remove `echo $DATABASE_URL`, use GitHub Actions masked secrets
  3. **Short-term**:
     - Purge git history using `git filter-repo` or BFG Repo-Cleaner:
       ```bash
       git filter-repo --invert-paths --path .env --path .env.production --path docker/.env.local
       ```
     - Force-push cleaned history (coordinate with team — destructive operation)
     - Replace `src/config/database.ts` hardcoded string with `process.env.DATABASE_URL`
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
