# Examples: Approval Workflow

## Production approval policy

```json
{
  "policy_id": "production-release-v1",
  "version": "1.0.0",
  "description": "Production release approval policy for backend services",
  "rules": [
    {
      "rule_id": "ai-review-required",
      "description": "AI-assisted PRs require enhanced review",
      "condition": { "field": "ai_contribution_percentage", "operator": "gte", "value": 20 },
      "requires": {
        "approvals": [{ "role": "tech-lead", "count": 1, "allow_same_as_author": false }],
        "checks": ["ai_review_checklist_l2"]
      }
    },
    {
      "rule_id": "full-audit-required",
      "description": "Heavy AI contribution requires full audit",
      "condition": { "field": "ai_contribution_percentage", "operator": "gte", "value": 80 },
      "requires": {
        "approvals": [
          { "role": "tech-lead", "count": 1, "allow_same_as_author": false },
          { "role": "security-reviewer", "count": 1, "allow_same_as_author": false }
        ],
        "checks": ["ai_review_checklist_l3", "second_independent_review"]
      }
    },
    {
      "rule_id": "default-approval",
      "condition": { "field": "always", "operator": "equals", "value": true },
      "requires": {
        "approvals": [{ "role": "developer", "count": 1, "allow_same_as_author": false }]
      }
    }
  ],
  "roles": [
    { "role": "developer", "description": "Any team developer", "members": ["@team-developers"] },
    { "role": "tech-lead", "description": "Technical lead", "members": ["jane-doe", "bob-smith"] },
    { "role": "security-reviewer", "description": "Security team member", "members": ["@team-security"] }
  ],
  "escalation": {
    "timeout_hours": 4,
    "escalate_to": ["manager"],
    "auto_approve_after": null
  }
}
```

## CLI Usage

```bash
# Validate policy
ods validate approval-policy --file policy.json

# Check PR against policy
ods approval check --pr 42 --policy policy.json

# Check release status
ods approval status --release v1.4.0
```
