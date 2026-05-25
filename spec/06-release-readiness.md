# 06 — Release Readiness

**Version:** 1.0.0-draft  
**Status:** Draft  
**Schema:** [`schemas/release-readiness.json`](../schemas/release-readiness.json)

## Overview

"Is this ready to release?" — the question every team answers before deploying. In the AI era, this decision needs to be evidence-based, not gut-feel. ODS defines a standardized release readiness report with verifiable checks and machine-readable gates.

## Specification

### Release Readiness Report

```json
{
  "release_id": "v1.4.0",
  "repository": "org/backend-service",
  "target_environment": "production",
  "requested_by": "jane-doe",
  "timestamp": "2026-01-15T16:00:00Z",
  "ready": true,
  "overall_score": 92,
  "gates": {
    "ci": {
      "status": "passed",
      "passed": true,
      "pipeline_id": "build-12345",
      "evidence_url": "https://ci.example.com/build/12345",
      "required": true
    },
    "tests": {
      "status": "passed",
      "passed": true,
      "coverage_before": "78%",
      "coverage_after": "80%",
      "coverage_threshold": "75%",
      "total_tests": 342,
      "passed_tests": 342,
      "failed_tests": 0,
      "skipped_tests": 5,
      "ai_generated_tests": 48,
      "ai_generated_test_pass_rate": "96%",
      "required": true
    },
    "security_scan": {
      "status": "passed",
      "passed": true,
      "scanner": "trivy",
      "critical_vulnerabilities": 0,
      "high_vulnerabilities": 0,
      "medium_vulnerabilities": 2,
      "low_vulnerabilities": 5,
      "waivers": [
        {
          "vulnerability_id": "CVE-2025-12345",
          "severity": "medium",
          "reason": "Not exploitable in our configuration",
          "approved_by": "security-team",
          "expires": "2026-03-15T00:00:00Z"
        }
      ],
      "required": true
    },
    "ai_review": {
      "status": "passed",
      "passed": true,
      "total_prs": 12,
      "ai_assisted_prs": 8,
      "ai_review_completed": 8,
      "ai_review_levels": {
        "L1": 2,
        "L2": 4,
        "L3": 2
      },
      "blocking_issues": 0,
      "required": true
    },
    "approvals": {
      "status": "passed",
      "passed": true,
      "required_approvals": 2,
      "actual_approvals": 2,
      "approvers": [
        {
          "name": "jane-doe",
          "role": "tech-lead",
          "timestamp": "2026-01-15T15:00:00Z"
        },
        {
          "name": "john-smith",
          "role": "security-reviewer",
          "timestamp": "2026-01-15T15:30:00Z"
        }
      ],
      "policy": "tech-lead + security-reviewer for AI-assisted releases",
      "required": true
    },
    "rollback_plan": {
      "status": "passed",
      "passed": true,
      "exists": true,
      "tested": true,
      "estimated_rollback_time_minutes": 5,
      "evidence_url": "https://wiki.example.com/rollback/v1.4.0",
      "required": true
    },
    "breaking_changes": {
      "status": "passed",
      "passed": true,
      "has_breaking_changes": false,
      "migration_guide_exists": false,
      "required": true
    },
    "documentation": {
      "status": "passed",
      "passed": true,
      "changelog_updated": true,
      "api_docs_updated": true,
      "runbook_updated": true,
      "required": false
    }
  },
  "warnings": [
    {
      "gate": "security_scan",
      "message": "2 medium vulnerabilities with waivers. All waivers expire before next release.",
      "severity": "info"
    }
  ],
  "ai_release_summary": {
    "total_changes": 47,
    "ai_contributed_changes": 31,
    "ai_contribution_percentage": 66,
    "human_authored_critical_paths": ["auth/token.go", "db/migrations/V14.sql"],
    "risk_assessment": "medium",
    "recommendation": "Proceed with release. AI contributed 66% of changes but all passed L2/L3 review. Critical paths are human-authored."
  }
}
```

### Gate Definitions

| Gate | Required | Description |
|------|----------|-------------|
| `ci` | **Yes** | All CI pipeline stages passed |
| `tests` | **Yes** | Test coverage at or above threshold |
| `security_scan` | **Yes** | No critical/high vulnerabilities without waiver |
| `ai_review` | If AI > 20% | All AI-assisted PRs completed review |
| `approvals` | **Yes** | Required number of approvals obtained |
| `rollback_plan` | **Yes** | Rollback plan exists and has been tested |
| `breaking_changes` | **Yes** | Breaking changes documented with migration guide |
| `documentation` | No | Changelog, API docs, runbook updated |

### Readiness Score

ODS calculates a readiness score (0-100):

```
Score = Σ(passed_gates × gate_weight) / Σ(gate_weight) × 100
```

Default weights:
- `ci`: 20
- `tests`: 20
- `security_scan`: 20
- `ai_review`: 15 (if applicable)
- `approvals`: 15
- `rollback_plan`: 10
- `breaking_changes`: 10
- `documentation`: 5

A release is `ready: true` when:
1. All required gates pass
2. Score ≥ 80

### AI-Specific Gates

When AI contribution exceeds 20%, additional gates are checked:

1. **AI review completed:** All AI-assisted PRs have completed review with outcome `approved` or `approved_with_changes`
2. **Critical path exclusion:** Human author verified that critical paths (auth, security, payments, data migration) are not AI-authored
3. **Hallucination scan:** CI includes automated hallucination detection; no high-severity hallucinations found

## Tooling

### CLI
```bash
# Validate a release readiness report JSON
ods validate release --file .ods/releases/v1.4.0/release-readiness.json

# Experimental readiness command
ods release check --version v1.4.0

# Experimental evidence summary
ods release evidence --version v1.4.0
```

## Relationship to Other Specs

- [04 — AI Change Review](04-ai-change-review.md): Review records feed the `ai_review` gate
- [05 — CI Failure](05-ci-failure.md): CI results feed the `ci` and `tests` gates
- [07 — Approval Workflow](07-approval-workflow.md): Defines approval policies
- [08 — Rollback Plan](08-rollback-plan.md): Defines rollback plan requirements
- [09 — Production Release Evidence](09-prod-release-evidence.md): Aggregates all evidence for audit
