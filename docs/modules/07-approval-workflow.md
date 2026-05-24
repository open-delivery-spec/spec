---
title: "07 — Approval Workflow"
layout: default
nav_order: 8
parent: Modules
---

# 07 — Approval Workflow

Declarative approval policies that are AI-aware and context-sensitive.

## Policy Rules

Rules are evaluated top-to-bottom; first match wins.

```json
{
  "rule_id": "ai-review-required",
  "condition": {
    "field": "ai_contribution_percentage",
    "operator": "gte",
    "value": 80
  },
  "requires": {
    "approvals": [
      { "role": "tech-lead", "count": 1 },
      { "role": "security-reviewer", "count": 1 }
    ]
  }
}
```

## Condition Operators

| Operator | Example |
|----------|---------|
| `equals` | `target_environment == "production"` |
| `gte` | `ai_contribution >= 80` |
| `in` | `changed_modules in ["auth", "payment"]` |
| `contains` | `pr_title contains "BREAKING"` |

## CLI Usage

```bash
# Validate policy
ods validate approval-policy --file policy.json

# Check PR status
ods approval check --pr 42 --policy policy.json
```

[View full spec →](https://github.com/open-delivery-spec/spec/blob/main/spec/07-approval-workflow.md)
[View schema →](https://github.com/open-delivery-spec/spec/blob/main/schemas/approval-workflow.json)
