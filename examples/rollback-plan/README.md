# Examples: Rollback Plan

## Feature flag rollback

```json
{
  "release_id": "v1.4.0",
  "repository": "org/backend-service",
  "created_by": "jane-doe",
  "created_at": "2026-01-15T14:00:00Z",
  "rollback_strategy": "feature_flag",
  "estimated_rollback_time_minutes": 5,
  "tested": true,
  "last_test_timestamp": "2026-01-14T10:00:00Z",
  "steps": [
    {
      "step": 1,
      "action": "disable_feature_flag",
      "description": "Disable oauth-v2 feature flag in LaunchDarkly",
      "command": "ld-toggle --project backend --flag oauth-v2 --off",
      "executor": "any-team-member",
      "expected_duration_seconds": 30,
      "verification": "Check /health returns ok and auth flows use v1"
    },
    {
      "step": 2,
      "action": "verify_service_health",
      "description": "Verify all services healthy after rollback",
      "verification": "All services return 'ok' from /health endpoint"
    }
  ],
  "rollback_indicators": {
    "error_rate_threshold": "> 1% for 5 minutes",
    "monitoring_dashboard": "https://grafana.example.com/d/backend-overview",
    "alert_channel": "#backend-alerts"
  },
  "data_rollback": {
    "database_migrations": false,
    "migration_reversible": true,
    "data_loss_risk": "none",
    "backup_taken": true
  },
  "communication_plan": {
    "stakeholders": ["product-team"],
    "notification_template": "Rolling back v1.4.0 due to [REASON]. ETA: 5 minutes."
  }
}
```

## CLI Usage

```bash
# Generate template
ods generate rollback --version v1.4.0 --strategy feature_flag

# Validate plan
ods validate rollback --file rollback-v1.4.0.json
```
