# 08 — Rollback Plan

**Version:** 1.0.0  
**Schema:** [`schemas/rollback-plan.json`](../schemas/rollback-plan.json)

## Overview

Every production deployment needs a rollback plan. Not a vague "we'll revert the PR" — a concrete, tested, time-bounded plan. ODS defines the minimum structure for a valid rollback plan that automated release gates can verify.

## Specification

### Rollback Plan Structure

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
      "command": "curl -s https://api.example.com/health | jq .status",
      "executor": "any-team-member",
      "expected_duration_seconds": 60,
      "verification": "All services return 'ok'"
    },
    {
      "step": 3,
      "action": "notify_team",
      "description": "Notify team of rollback in Slack",
      "command": "/rollback-notify v1.4.0 #backend-alerts",
      "executor": "any-team-member",
      "expected_duration_seconds": 30,
      "verification": "Acknowledgement from at least 1 team member"
    }
  ],
  "rollback_indicators": {
    "error_rate_threshold": "> 1% for 5 minutes",
    "latency_threshold": "p99 > 500ms for 5 minutes",
    "monitoring_dashboard": "https://grafana.example.com/d/backend-overview",
    "alert_channel": "#backend-alerts",
    "auto_rollback": false,
    "auto_rollback_condition": null
  },
  "data_rollback": {
    "database_migrations": true,
    "migration_reversible": true,
    "reverse_migration": "V14__reverse_oauth_tables.sql",
    "data_loss_risk": "none",
    "backup_taken": true,
    "backup_location": "s3://backups/db/pre-v1.4.0-20260115.dump"
  },
  "dependencies": {
    "upstream_services": [],
    "downstream_services": ["frontend-web", "mobile-api"],
    "downstream_rollback_required": false,
    "downstream_compatibility": "backward-compatible"
  },
  "communication_plan": {
    "stakeholders": ["product-team", "customer-support"],
    "notification_template": "Rolling back v1.4.0 due to [REASON]. ETA: 5 minutes.",
    "post_rollback_actions": [
      "Create post-mortem ticket",
      "Schedule root cause analysis",
      "Update release notes"
    ]
  }
}
```

### Rollback Strategies

| Strategy | Best For | Risk Level |
|----------|----------|------------|
| `feature_flag` | New features, UI changes | Low |
| `git_revert` | Small code changes, bugfixes | Low-Medium |
| `previous_deployment` | Full service rollback (e.g., k8s rollback) | Medium |
| `database_restore` | Schema changes, data migrations | High |
| `blue_green_switch` | Infrastructure changes | Low |
| `canary_scale_down` | Gradual rollouts | Low |
| `traffic_shift` | API gateway/load balancer changes | Low-Medium |
| `config_revert` | Config-only changes | Low |
| `multi_step` | Complex releases with multiple components | High |

### Minimum Requirements

A rollback plan is **invalid** if ANY of these are missing:

1. ☐ Rollback strategy is specified
2. ☐ Estimated rollback time is provided
3. ☐ At least one indicator for triggering rollback is defined
4. ☐ Steps are sequential and include verification
5. ☐ Data impact is assessed (even if "no data changes")
6. ☐ Rollback has been tested (or `tested: false` with `untested_reason`)
7. ☐ Communication plan exists (even if "no stakeholders to notify")

### Testing the Rollback Plan

Rollback plans MUST be tested:
- Before the first production deployment using this plan
- After any change to the rollback procedure
- At least once per release cycle

Test results:

```json
{
  "test_result": {
    "tested_by": "jane-doe",
    "tested_at": "2026-01-14T10:00:00Z",
    "passed": true,
    "actual_duration_seconds": 180,
    "issues_encountered": [
      "Step 1 took longer than expected due to LD propagation delay"
    ],
    "notes": "Actual rollback took 3 minutes vs 2 estimated. LD propagation added 60 seconds."
  }
}
```

### Rollback Execution Record

After rollback:

```json
{
  "execution_record": {
    "rollback_triggered": false,
    "trigger_reason": null,
    "triggered_by": null,
    "triggered_at": null,
    "duration_seconds": null,
    "successful": null,
    "post_rollback_issues": null
  }
}
```

## Tooling

### CLI
```bash
# Validate a rollback plan
ods rollback validate --file rollback-v1.4.0.json

# Generate a rollback plan template
ods rollback generate --version v1.4.0 --strategy feature_flag

# Record a rollback test
ods rollback test --record --version v1.4.0 --result passed
```

## Relationship to Other Specs

- [06 — Release Readiness](06-release-readiness.md): Rollback plan is a required gate
- [07 — Approval Workflow](07-approval-workflow.md): Rollback may require specific approvals
- [09 — Production Release Evidence](09-prod-release-evidence.md): Rollback plan is part of deployment evidence
