# 09 — Production Release Evidence

**Version:** 1.0.0  
**Schema:** [`schemas/prod-release-evidence.json`](../schemas/prod-release-evidence.json)

## Overview

After deployment: *Can you prove it was safe?* Auditors, compliance teams, and incident responders need a single source of truth. ODS defines the production release evidence bundle — an immutable, verifiable record that proves every gate was checked and every approval was granted.

## Specification

### Evidence Bundle

```json
{
  "bundle_id": "evidence-v1.4.0-20260115",
  "release_id": "v1.4.0",
  "repository": "org/backend-service",
  "environment": "production",
  "deployed_at": "2026-01-15T17:00:00Z",
  "deployed_by": "ci-pipeline",
  "bundle_generated_at": "2026-01-15T17:05:00Z",
  "bundle_hash": "sha256:abc123def456...",
  "immutable": true,
  "evidence": {
    "release_readiness": {
      "report_url": "https://artifacts.example.com/release/v1.4.0/readiness.json",
      "report_hash": "sha256:111...",
      "score": 92,
      "all_gates_passed": true
    },
    "ci_pipeline": {
      "pipeline_id": "build-12345",
      "pipeline_url": "https://ci.example.com/build/12345",
      "status": "passed",
      "all_stages_passed": true,
      "artifact_hash": "sha256:222..."
    },
    "test_results": {
      "total": 342,
      "passed": 342,
      "failed": 0,
      "coverage_percentage": 80,
      "report_url": "https://artifacts.example.com/tests/v1.4.0/junit.xml"
    },
    "security_scan": {
      "scanner": "trivy",
      "scan_id": "scan-12345",
      "critical": 0,
      "high": 0,
      "medium_with_waivers": 2,
      "report_url": "https://artifacts.example.com/security/v1.4.0/trivy.json"
    },
    "ai_reviews": {
      "total_ai_prs": 8,
      "all_reviewed": true,
      "review_records": [
        {
          "pr_number": 42,
          "review_level": "L2",
          "outcome": "approved_with_changes",
          "review_record_url": "https://artifacts.example.com/reviews/pr-42.json"
        },
        {
          "pr_number": 45,
          "review_level": "L3",
          "outcome": "approved",
          "review_record_url": "https://artifacts.example.com/reviews/pr-45.json"
        }
      ]
    },
    "approvals": {
      "required": 2,
      "obtained": 2,
      "approval_records": [
        {
          "approver": "jane-doe",
          "role": "tech-lead",
          "timestamp": "2026-01-15T15:00:00Z",
          "method": "GitHub PR review"
        },
        {
          "approver": "john-smith",
          "role": "security-reviewer",
          "timestamp": "2026-01-15T15:30:00Z",
          "method": "GitHub PR review"
        }
      ]
    },
    "rollback_plan": {
      "exists": true,
      "tested": true,
      "test_passed": true,
      "plan_url": "https://wiki.example.com/rollback/v1.4.0",
      "plan_hash": "sha256:333..."
    },
    "deployment_log": {
      "deployment_id": "deploy-12345",
      "strategy": "rolling",
      "started_at": "2026-01-15T16:55:00Z",
      "completed_at": "2026-01-15T17:00:00Z",
      "duration_seconds": 300,
      "instances_updated": 12,
      "health_check_passed": true,
      "log_url": "https://deploy.example.com/logs/deploy-12345"
    }
  },
  "ai_summary": {
    "total_changes": 47,
    "ai_contributed": 31,
    "ai_contribution_pct": 66,
    "highest_review_level": "L3",
    "ai_summary": "66% of changes are AI-generated. All AI changes passed L2/L3 review. Critical paths (auth, db migrations) are human-authored. Deployment risk: medium."
  },
  "signatures": [
    {
      "signed_by": "ci-pipeline",
      "timestamp": "2026-01-15T17:05:00Z",
      "signature": "sha256:xyz789...",
      "verified": true
    }
  ],
  "compliance": {
    "frameworks": ["SOC2", "ISO27001"],
    "controls_satisfied": [
      "CC8.1 — Change Management",
      "CC7.1 — Security Monitoring",
      "A1.2 — Authorization"
    ],
    "retention_period_days": 365,
    "deletion_date": "2027-01-15T00:00:00Z"
  }
}
```

### Evidence Immutability

The evidence bundle MUST be immutable after generation:
1. Content hash (`bundle_hash`) is calculated at generation time
2. Bundle is stored in a tamper-evident location (S3 with versioning, immudb, etc.)
3. Bundle hash is logged to an append-only audit log
4. Any modification can be detected via hash mismatch

### Evidence Chain

Each piece of evidence references its source in a chain:

```
Release Readiness Report
  └── CI Pipeline Results (build-12345)
  │     └── Unit Test Results (junit.xml)
  │     └── Security Scan Results (trivy.json)
  ├── AI Review Records
  │     ├── PR #42 Review (L2)
  │     └── PR #45 Review (L3)
  ├── Approval Records (GitHub)
  ├── Rollback Plan
  └── Deployment Log
```

### Minimum Evidence Threshold

A production deployment is **not valid** without ALL of:
1. ☐ Release readiness report (score ≥ 80)
2. ☐ CI pipeline results (all stages passed)
3. ☐ Security scan results (no critical/high)
4. ☐ All AI reviews completed (if AI contribution > 20%)
5. ☐ All required approvals obtained
6. ☐ Rollback plan exists and is tested
7. ☐ Deployment log with health check verification

### Verification Process

```bash
# Verify evidence bundle integrity
ods evidence verify --bundle evidence-v1.4.0.json

# Cross-reference with source systems
ods evidence cross-ref --bundle evidence-v1.4.0.json

# Generate compliance report
ods evidence compliance --bundle evidence-v1.4.0.json --framework SOC2
```

Output:
```
✓ Bundle hash verified: sha256:abc123def456...
✓ 7/7 evidence items present
✓ 7/7 evidence items verified against source systems
✓ 0 discrepancies found
✓ SOC2 controls: CC8.1 ✓, CC7.1 ✓, A1.2 ✓
✓ Bundle is valid and immutable
```

### Storage and Retention

| Environment | Retention | Storage |
|-------------|-----------|---------|
| Production | 365 days | Immutable (S3 Object Lock, immudb) |
| Staging | 90 days | Standard (S3) |
| Development | 30 days | Optional |

## Tooling

### CLI
```bash
# Generate evidence bundle post-deployment
ods evidence generate --release v1.4.0 --env production

# Verify bundle integrity
ods evidence verify --bundle evidence-v1.4.0.json

# Sign evidence bundle
ods evidence sign --bundle evidence-v1.4.0.json --key ci-signing-key

# Generate audit report
ods evidence audit --bundle evidence-v1.4.0.json --output audit.pdf
```

## Relationship to Other Specs

The evidence bundle aggregates ALL other specs:
- [01](01-branch-naming.md) — Branch naming compliance
- [02](02-commit-message.md) — Commit message standards
- [03](03-pr-description.md) — PR descriptions
- [04](04-ai-change-review.md) — AI review records
- [05](05-ci-failure.md) — CI results
- [06](06-release-readiness.md) — Readiness report
- [07](07-approval-workflow.md) — Approval records
- [08](08-rollback-plan.md) — Rollback plan
