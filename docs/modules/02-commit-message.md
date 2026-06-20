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

## Primary Signal — `Co-Authored-By`

AI coding tools already emit `Co-Authored-By` trailers automatically. ODS treats these as first-class AI attribution — no additional fields required:

```
feat(auth): add OAuth 2.0 login flow

Co-Authored-By: Claude <noreply@anthropic.com>
```

| Tool | Example trailer |
|------|----------------|
| Claude / Claude Code | `Co-Authored-By: Claude <noreply@anthropic.com>` |
| GitHub Copilot | `Co-Authored-By: GitHub Copilot <175728472+github-copilot[bot]@users.noreply.github.com>` |
| Cursor | `Co-Authored-By: Cursor <cursor@cursor.sh>` |

## ODS Supplemental Footer Fields (Optional)

For richer attribution metadata beyond `Co-Authored-By`, ODS defines optional supplemental footers:

```
feat(auth): add OAuth 2.0 login flow

Co-Authored-By: GitHub Copilot <175728472+github-copilot[bot]@users.noreply.github.com>
AI-scope: auth module, token refresh logic
AI-review: pending
AI-confidence: high
Ticket: PROJ-1234
Risk: medium
```

| Field | Required | Values |
|-------|----------|---------|
| `Co-Authored-By` | **Yes, when AI used** | `<name> <email>` |
| `AI-assisted` | Optional | `true` / `false` |
| `AI-tool` | Optional | e.g., `GitHub Copilot` |
| `AI-scope` | Recommended | Free text |
| `AI-review` | Recommended | `pending` / `passed` / `failed` |
| `AI-confidence` | Optional | `low` / `medium` / `high` |
| `Ticket` | Recommended | Issue ID |
| `Risk` | Optional | `low` / `medium` / `high` |

## CLI Usage

```bash
# Detect AI code (reads Co-Authored-By from recent commits automatically)
ods detect --commits 5
```

[View full spec →](https://github.com/open-delivery-spec/spec/blob/main/spec/02-commit-message.md)
[View schema →](https://github.com/open-delivery-spec/spec/blob/main/schemas/commit-message.json)
