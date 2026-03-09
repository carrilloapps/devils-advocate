# Example: Public Cloud Storage Bucket with Sensitive Data

> *Reference output — load on demand when assessing cloud storage configurations (S3, GCS, Azure Blob).*
>
> ⚠️ **Example only** — All patterns, IaC descriptions, and configuration references below are synthetic illustrations of vulnerable configurations and correct SAR output. They are not real infrastructure and must not be executed or deployed.

## Scenario

An S3 bucket is configured with public read access and contains user uploads, database backups, and application logs.

```text
Vulnerable IaC pattern (pseudocode):

  File: terraform/s3.tf
  Resource: aws_s3_bucket "uploads"
    → bucket name: <APP>-user-uploads-prod
    → ACL set to public-read
    → no block_public_access resource defined
    → no encryption, no versioning, no access logging
```

```text
Bucket policy (discovered during assessment):

  Statement:
    → Effect: Allow
    → Principal: * (any unauthenticated user)
    → Action: s3:GetObject
    → Resource: all objects in the bucket
```

## Assessment Trace

1. **IaC scan**: `terraform/s3.tf` defines bucket with `acl = "public-read"`, no `aws_s3_bucket_public_access_block` resource.
2. **Policy analysis**: Bucket policy grants `s3:GetObject` to `"Principal": "*"` on all objects — any unauthenticated user can download any file.
3. **Bucket contents**: Contains three prefixes:
   - `uploads/` — user-uploaded documents (IDs, contracts, personal files)
   - `backups/` — daily database dumps (`.sql.gz` files with customer PII)
   - `logs/` — application logs (contain JWT tokens, API keys in error traces)
4. **Encryption**: No `ServerSideEncryptionConfiguration` — data stored unencrypted.
5. **Access logging**: No S3 Server Access Logging — no audit trail of who accessed what.
6. **Frontend exposure**: Bucket name hardcoded in `src/config/storage.ts` and visible in client-side JavaScript.

## SAR Finding

### [97] — Public S3 Bucket Containing PII, Database Backups, and Application Secrets

- **Description**: Production S3 bucket is publicly readable via ACL and bucket policy (Principal set to wildcard). The bucket contains user-uploaded personal documents, database backups with customer PII, and application logs with authentication tokens and API keys. No encryption at rest, no access logging.
- **Affected Component(s)**: `terraform/s3.tf`, bucket policy, `src/config/storage.ts`
- **Evidence**:
  ```text
  Public URL: bucket backups prefix accessible without authentication (HTTP 200)
  Policy: Principal set to wildcard, Action s3:GetObject on all objects
  ACL: public-read
  Encryption: None
  Logging: None
  ```
- **Standards Violated**: OWASP Top 10 (A01:2021 Broken Access Control, A02:2021 Cryptographic Failures), GDPR Art. 32 (data protection), PCI-DSS Req. 3 & 7 (if payment data in backups), ISO 27001 A.8, A.10 (asset management, cryptography), NIST SP 800-53 AC-3, SC-28, AU-2, SOC 2 CC6.1, CC6.7, CSA STAR CCM DSI-04
- **MITRE ATT&CK**: T1530 (Data from Cloud Storage Object), T1552.005 (Cloud Instance Metadata API — if credentials in logs)
- **Score**: **97** (Critical) — public access, PII confirmed, database backups accessible, secrets in logs, no encryption, no audit trail.
- **Suggested Mitigation Actions**:
  1. **Emergency (within hours)**:
     - Set `BlockPublicAccess: true` at the account level
     - Remove `"Principal": "*"` from bucket policy
     - Change ACL to `private`
  2. **Immediate (within 24h)**:
     - Enable SSE-KMS encryption on the bucket
     - Rotate all JWT secrets and API keys found in log files
     - Rotate database credentials (credentials visible in backup filenames/contents)
  3. **Short-term**:
     - Enable S3 Server Access Logging + CloudTrail data events
     - Enable versioning + MFA Delete
     - Move database backups to a separate, private bucket with cross-account access only
     - Remove bucket name from frontend code — use pre-signed URLs generated server-side
  4. **Medium-term**:
     - Implement S3 Object Lambda for malware scanning on uploads
     - Add DLP scanning for PII in uploaded documents
     - Set up automated alerts for public bucket configuration changes

## Key Principles Demonstrated

- **Data classification**: Distinguished between user uploads, backups, and logs — each with different risk profiles
- **Multiple violation mapping**: Mapped to 7 standards with justification
- **Tiered remediation**: Emergency → immediate → short-term → medium-term timeline
- **Collateral impact**: Identified cascading risks (credential rotation needed from exposed logs)

## Cross-Reference

- All cloud storage patterns → see [`frameworks/storage-exfiltration.md`](../frameworks/storage-exfiltration.md)
- Compliance standards → see [`frameworks/compliance-standards.md`](../frameworks/compliance-standards.md)
- Scoring system → see [`frameworks/scoring-system.md`](../frameworks/scoring-system.md)
