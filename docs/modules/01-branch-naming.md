---
title: "01 — Branch Naming"
layout: default
nav_order: 2
parent: Modules
---

# 01 — Branch Naming

Standardized, machine-parseable branch names, extending [Conventional Branch 1.0.0](https://conventional-branch.github.io) with AI-specific metadata.

## Format

```
<type>/<description>
```

## Branch Types

| Type | Purpose | AI Use |
|------|---------|--------|
| `feature/` | New features | AI-generated features |
| `bugfix/` | Bug fixes | AI-assisted fixes |
| `hotfix/` | Urgent production fixes | Emergency patches |
| `release/` | Release prep | Automated releases |
| `chore/` | Non-code tasks | AI maintenance |

## Valid Examples

```
feature/add-login-page
feature/ai-add-oauth-provider
bugfix/fix-header-overflow
release/v1.2.0
chore/update-dependencies
```

## Naming Rules

- Lowercase only (`a-z`)
- Kebab-case (`add-oauth-login`)
- No underscores, spaces, or special characters
- No consecutive hyphens
- No leading/trailing hyphens

## AI Markers

AI-generated branches use `ai-` prefix in description:
```
feature/ai-add-payment
```

## Schema

```json
{
  "type": "feature",
  "description": "add-oauth-login",
  "ticket": "PROJ-1234",
  "ai_generated": true,
  "ai_tool": "GitHub Copilot",
  "base_branch": "main"
}
```

[View full spec →](https://github.com/open-delivery-spec/spec/blob/main/spec/01-branch-naming.md)
[View schema →](https://github.com/open-delivery-spec/spec/blob/main/schemas/branch-naming.json)
