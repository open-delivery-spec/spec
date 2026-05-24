---
title: "02 — Commit Message"
layout: default
nav_order: 3
parent: Modules
---

# 02 — Commit Message

AI-attributable, semantically rich commit format, extending [Conventional Commits 1.0.0](https://www.conventionalcommits.org).

## Format

```
<type>[scope]: <description>

[body]

[footer]
```

## ODS AI Footer Fields

```
feat(auth): add OAuth 2.0 login flow

AI-assisted: true
AI-tool: GitHub Copilot
AI-scope: auth module, token refresh logic
AI-review: pending
AI-confidence: high
Ticket: PROJ-1234
Risk: medium
```

| Field | Required | Values |
|-------|----------|--------|
| `AI-assisted` | Yes | `true` / `false` |
| `AI-tool` | If AI true | e.g., `GitHub Copilot` |
| `AI-scope` | Recommended | Free text |
| `AI-review` | If AI true | `pending` / `passed` / `failed` |
| `AI-confidence` | Optional | `low` / `medium` / `high` |
| `Ticket` | Recommended | Issue ID |
| `Risk` | Optional | `low` / `medium` / `high` |

## CLI Usage

```bash
# Validate
git log -1 --format=%B | ods validate commit --stdin

# Generate
ods generate commit --type feat --scope auth --ai-tool "Copilot"
```

[View full spec →](https://github.com/open-delivery-spec/spec/blob/main/spec/02-commit-message.md)
[View schema →](https://github.com/open-delivery-spec/spec/blob/main/schemas/commit-message.json)
