---
title: "08 — Rollback Plan"
layout: default
nav_order: 9
parent: Modules
---

# 08 — Rollback Plan

Minimum requirements for valid, testable rollback plans.

## Strategies

| Strategy | Risk |
|----------|------|
| `feature_flag` | Low |
| `git_revert` | Low-Medium |
| `previous_deployment` | Medium |
| `database_restore` | High |
| `blue_green_switch` | Low |
| `config_revert` | Low |

## Minimum Requirements

A rollback plan is invalid without ALL:
1. ☐ Rollback strategy specified
2. ☐ Estimated time provided
3. ☐ At least one trigger indicator
4. ☐ Sequential steps with verification
5. ☐ Data impact assessed
6. ☐ Plan has been tested

## Required Structure

```json
{
  "release_id": "v1.4.0",
  "rollback_strategy": "feature_flag",
  "estimated_rollback_time_minutes": 5,
  "tested": true,
  "steps": [
    {
      "step": 1,
      "action": "disable_feature_flag",
      "verification": "Health check returns ok"
    }
  ],
  "rollback_indicators": {
    "error_rate_threshold": "> 1% for 5 minutes",
    "alert_channel": "#backend-alerts"
  },
  "data_rollback": {
    "database_migrations": false,
    "data_loss_risk": "none",
    "backup_taken": true
  },
  "communication_plan": {
    "notification_template": "Rolling back v1.4.0 due to [REASON]."
  }
}
```

## CLI Usage

```bash
ods generate rollback --version v1.4.0 --strategy feature_flag
ods validate rollback --file rollback.json
```

[View full spec →](https://github.com/open-delivery-spec/spec/blob/main/spec/08-rollback-plan.md)
[View schema →](https://github.com/open-delivery-spec/spec/blob/main/schemas/rollback-plan.json)
