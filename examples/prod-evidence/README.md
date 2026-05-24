# Examples: Production Release Evidence

## Complete evidence bundle

```json
{
  "bundle_id": "evidence-v1.4.0-20260115",
  "release_id": "v1.4.0",
  "repository": "org/backend-service",
  "environment": "production",
  "deployed_at": "2026-01-15T17:00:00Z",
  "deployed_by": "ci-pipeline",
  "bundle_generated_at": "2026-01-15T17:05:00Z",
  "bundle_hash": "sha256:abc123def4567890abc123def4567890abc123def4567890abc123def4567890",
  "immutable": true,
  "evidence": {
    "release_readiness": {
      "score": 92,
      "all_gates_passed": true
    },
    "ci_pipeline": {
      "pipeline_id": "build-12345",
      "status": "passed",
      "all_stages_passed": true
    },
    "test_results": {
      "total": 342,
      "passed": 342,
      "failed": 0,
      "coverage_percentage": 80
    },
    "security_scan": {
      "scanner": "trivy",
      "critical": 0,
      "high": 0
    },
    "approvals": {
      "required": 2,
      "obtained": 2,
      "approval_records": [
        { "approver": "jane-doe", "role": "tech-lead", "timestamp": "2026-01-15T15:00:00Z" },
        { "approver": "john-smith", "role": "security-reviewer", "timestamp": "2026-01-15T15:30:00Z" }
      ]
    },
    "rollback_plan": {
      "exists": true,
      "tested": true
    },
    "deployment_log": {
      "deployment_id": "deploy-12345",
      "strategy": "rolling",
      "started_at": "2026-01-15T16:55:00Z",
      "completed_at": "2026-01-15T17:00:00Z",
      "health_check_passed": true
    }
  },
  "compliance": {
    "frameworks": ["SOC2", "ISO27001"],
    "retention_period_days": 365
  }
}
```

## CLI Usage

```bash
# Generate bundle
ods evidence generate --release v1.4.0 --env production

# Verify integrity
ods evidence verify evidence-v1.4.0.json

# Audit for compliance
ods evidence audit SOC2
```
