---
title: "09 — Production Release Evidence"
layout: default
nav_order: 10
parent: Modules
---

# 09 — Production Release Evidence

Immutable, auditable evidence bundle for production deployments.

## Evidence Bundle Structure

```
Bundle
 ├── Release Readiness Report
 ├── CI Pipeline Results
 ├── Test Results
 ├── Security Scan Results
 ├── AI Review Records
 ├── Approval Records
 ├── Rollback Plan
 └── Deployment Log
```

## Immutability

- Content hash calculated at generation
- Stored in tamper-evident location (S3 Object Lock)
- Hash logged to append-only audit log

## Minimum Evidence

A production deployment requires ALL:

1. ☐ Release readiness report (score ≥ 80)
2. ☐ CI pipeline passed
3. ☐ Security scan clean (no critical/high)
4. ☐ All AI reviews completed
5. ☐ All approvals obtained
6. ☐ Rollback plan exists and tested
7. ☐ Deployment log with health check

## Compliance

Supports SOC2, ISO27001 framework mapping.

## CLI Usage

```bash
# Generate
ods evidence generate --release v1.4.0 --env production

# Verify
ods evidence verify evidence-v1.4.0.json

# Audit
ods evidence audit SOC2
```

[View full spec →](https://github.com/open-delivery-spec/spec/blob/main/spec/09-prod-release-evidence.md)
[View schema →](https://github.com/open-delivery-spec/spec/blob/main/schemas/prod-release-evidence.json)
