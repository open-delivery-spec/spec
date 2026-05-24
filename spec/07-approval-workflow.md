# 07 — Approval Workflow

**Version:** 1.0.0  
**Schema:** [`schemas/approval-workflow.json`](../schemas/approval-workflow.json)

## Overview

Who approves what? In AI-era development, approval policies need to be explicit, automatable, and context-aware. A PR with 90% AI-generated code needs different approval than a one-line config fix. ODS defines a declarative approval policy format that tools can enforce.

## Specification

### Approval Policy

```json
{
  "policy_id": "production-release-v1",
  "version": "1.0.0",
  "description": "Production release approval policy for backend services",
  "rules": [
    {
      "rule_id": "ai-review-required",
      "description": "AI-assisted PRs require enhanced review",
      "condition": {
        "field": "ai_contribution_percentage",
        "operator": "gte",
        "value": 20
      },
      "requires": {
        "approvals": [
          {
            "role": "tech-lead",
            "count": 1,
            "allow_same_as_author": false
          }
        ],
        "checks": [
          "ai_review_checklist_l2"
        ]
      }
    },
    {
      "rule_id": "full-audit-required",
      "description": "Heavy AI contribution requires full audit",
      "condition": {
        "field": "ai_contribution_percentage",
        "operator": "gte",
        "value": 80
      },
      "requires": {
        "approvals": [
          {
            "role": "tech-lead",
            "count": 1,
            "allow_same_as_author": false
          },
          {
            "role": "security-reviewer",
            "count": 1,
            "allow_same_as_author": false
          }
        ],
        "checks": [
          "ai_review_checklist_l3",
          "second_independent_review"
        ]
      }
    },
    {
      "rule_id": "breaking-change-approval",
      "description": "Breaking changes require architect approval",
      "condition": {
        "field": "has_breaking_changes",
        "operator": "equals",
        "value": true
      },
      "requires": {
        "approvals": [
          {
            "role": "architect",
            "count": 1,
            "allow_same_as_author": false
          }
        ],
        "checks": [
          "breaking_change_migration_guide",
          "deprecation_notice_published"
        ]
      }
    },
    {
      "rule_id": "hotfix-approval",
      "description": "Hotfixes require manager approval",
      "condition": {
        "field": "branch_type",
        "operator": "equals",
        "value": "hotfix"
      },
      "requires": {
        "approvals": [
          {
            "role": "manager",
            "count": 1,
            "allow_same_as_author": false
          }
        ],
        "checks": [
          "hotfix_justification"
        ]
      }
    },
    {
      "rule_id": "production-release",
      "description": "Production releases always need tech lead approval",
      "condition": {
        "field": "target_environment",
        "operator": "equals",
        "value": "production"
      },
      "requires": {
        "approvals": [
          {
            "role": "tech-lead",
            "count": 1,
            "allow_same_as_author": false
          }
        ]
      }
    },
    {
      "rule_id": "default-approval",
      "description": "Default: standard PR review",
      "condition": {
        "field": "always",
        "operator": "equals",
        "value": true
      },
      "requires": {
        "approvals": [
          {
            "role": "developer",
            "count": 1,
            "allow_same_as_author": false
          }
        ]
      }
    }
  ],
  "roles": [
    {
      "role": "developer",
      "description": "Any developer on the team",
      "members": ["@team-developers"]
    },
    {
      "role": "tech-lead",
      "description": "Technical lead for the project",
      "members": ["jane-doe", "bob-smith"]
    },
    {
      "role": "security-reviewer",
      "description": "Security team member",
      "members": ["@team-security"]
    },
    {
      "role": "architect",
      "description": "System architect",
      "members": ["alice-architect"]
    },
    {
      "role": "manager",
      "description": "Engineering manager",
      "members": ["mike-manager"]
    }
  ],
  "escalation": {
    "timeout_hours": 4,
    "escalate_to": ["manager"],
    "auto_approve_after": null
  }
}
```

### Condition Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `equals` | Exact match | `field: "target_environment", value: "production"` |
| `not_equals` | Not equal | `field: "branch_type", value: "hotfix"` |
| `gte` | Greater than or equal | `field: "ai_contribution_percentage", value: 80` |
| `lte` | Less than or equal | `field: "risk_score", value: 3` |
| `gt` | Greater than | `field: "changed_files", value: 50` |
| `lt` | Less than | `field: "test_coverage", value: 70` |
| `in` | Value in list | `field: "changed_modules", value: ["auth", "payment"]` |
| `contains` | Contains substring | `field: "pr_title", value: "BREAKING"` |
| `always` | Always matches | Used for default rule |

### Rule Evaluation

1. Rules are evaluated in order (top to bottom)
2. First matching rule wins
3. `always` rules should be placed last as defaults
4. Multiple matching conditions within a rule are AND-ed together
5. Result: list of required approvers and checks

### Approval Definitions

```json
{
  "approval": {
    "approved_by": "jane-doe",
    "role": "tech-lead",
    "timestamp": "2026-01-15T15:00:00Z",
    "type": "explicit",
    "comment": "Reviewed AI-generated OAuth flow. Changes look correct.",
    "checks_completed": [
      "ai_review_checklist_l2",
      "breaking_change_migration_guide"
    ]
  }
}
```

### Blocking Conditions

Approval is BLOCKED when:
1. Required number of approvals per role not met
2. Same person attempts to approve their own PR (unless `allow_same_as_author: true`)
3. Required checks are not completed
4. Escalation timeout reached without approval

## Tooling

### CLI
```bash
# Validate approval policy
ods approval validate-policy --file policy.json

# Check if PR meets approval requirements
ods approval check --pr 42 --policy policy.json

# Generate approval status report
ods approval status --release v1.4.0
```

### Configuration File

Place `ods-approval.json` in the repository root:

```json
{
  "$schema": "https://open-delivery-spec.dev/schemas/approval-workflow.json",
  "policy_id": "repo-policy-v1",
  "extends": "org-default-policy",
  ...
}
```

## Relationship to Other Specs

- [04 — AI Change Review](04-ai-change-review.md): AI contribution percentage drives approval rules
- [06 — Release Readiness](06-release-readiness.md): Approvals are a required gate
- [08 — Rollback Plan](08-rollback-plan.md): Rollback plan may require specific approvals
- [09 — Production Release Evidence](09-prod-release-evidence.md): Approval records are part of evidence
