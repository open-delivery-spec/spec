# Examples: Release Readiness

## Passing release readiness report

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
    "ci": { "passed": true, "required": true },
    "tests": { "passed": true, "required": true },
    "security_scan": { "passed": true, "required": true },
    "ai_review": { "passed": true, "required": true },
    "approvals": { "passed": true, "required": true },
    "rollback_plan": { "passed": true, "required": true },
    "breaking_changes": { "passed": true, "required": true },
    "documentation": { "passed": true, "required": false }
  },
  "ai_release_summary": {
    "total_changes": 47,
    "ai_contributed_changes": 31,
    "ai_contribution_percentage": 66,
    "risk_assessment": "medium",
    "recommendation": "Proceed with release. AI contributed 66% but all passed L2/L3 review."
  }
}
```

## Blocked release (missing approval)

```json
{
  "release_id": "v1.5.0",
  "repository": "org/backend-service",
  "target_environment": "production",
  "timestamp": "2026-01-20T10:00:00Z",
  "ready": false,
  "overall_score": 65,
  "gates": {
    "ci": { "passed": true, "required": true },
    "tests": { "passed": true, "required": true },
    "security_scan": { "passed": true, "required": true },
    "ai_review": { "passed": true, "required": true },
    "approvals": { "passed": false, "required": true },
    "rollback_plan": { "passed": false, "required": true },
    "breaking_changes": { "passed": true, "required": true }
  },
  "warnings": [
    { "gate": "approvals", "message": "Missing security-reviewer approval", "severity": "critical" },
    { "gate": "rollback_plan", "message": "Rollback plan not tested", "severity": "warning" }
  ]
}
```

## CLI Usage

```bash
# Generate template
ods generate release --version v1.4.0 --env production

# Check readiness
ods release check --version v1.4.0

# Validate report
ods validate release --file readiness.json
```
