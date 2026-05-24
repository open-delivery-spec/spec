# 02 — Commit Message

**Version:** 1.0.0  
**Schema:** [`schemas/commit-message.json`](../schemas/commit-message.json)  
**Based on:** [Conventional Commits 1.0.0](https://www.conventionalcommits.org)

## Overview

In the AI era, commits need to answer: *Who wrote this — human, AI, or both?* ODS extends Conventional Commits with AI attribution, change scope, and verification metadata, making every commit auditable.

## Specification

### Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

ODS adds AI-specific footer fields:

```
feat(auth): add OAuth 2.0 login flow

Implemented OAuth 2.0 authorization code flow with PKCE.
Supports Google, GitHub, and Microsoft providers.

AI-assisted: true
AI-tool: GitHub Copilot
AI-scope: auth module, token refresh logic
AI-review: pending
Co-authored-by: AI Assistant <ai@open-delivery-spec.dev>
```

### Standard Fields (from Conventional Commits)

| Field | Required | Description |
|-------|----------|-------------|
| `type` | **Yes** | `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert` |
| `scope` | No | Affected module or component (parentheses) |
| `description` | **Yes** | Short summary, imperative mood, lowercase |
| `body` | No | Detailed explanation, motivation, contrast |
| `footer` | No | Breaking changes, issue references |

### ODS-Extended Footer Fields

| Footer Field | Required | Values | Description |
|---|---|---|---|
| `AI-assisted` | If AI was used | `true` / `false` | Whether AI contributed to this commit |
| `AI-tool` | If `AI-assisted: true` | Name of AI tool | e.g., `GitHub Copilot`, `Cursor`, `Claude` |
| `AI-scope` | Recommended | Free text | What the AI specifically generated |
| `AI-review` | If `AI-assisted: true` | `pending` / `passed` / `failed` | Review status of AI-generated code |
| `AI-confidence` | Optional | `low` / `medium` / `high` | Author's confidence in AI-generated portion |
| `Ticket` | Recommended | Issue tracker ID | e.g., `PROJ-1234` |
| `Risk` | Optional | `low` / `medium` / `high` | Author-assessed deployment risk |

### Breaking Changes

Breaking changes MUST be indicated with `!` after the type/scope OR with `BREAKING CHANGE:` in the footer:

```
feat!: remove legacy auth endpoint

BREAKING CHANGE: The /v1/auth endpoint has been removed.
Migration guide: https://docs.example.com/migration/v2
```

### Examples

**AI-generated feature:**
```
feat(search): add semantic search capability

AI-assisted: true
AI-tool: Claude
AI-scope: embedding generation, query parser
AI-confidence: high
AI-review: pending
Ticket: SEARCH-42
```

**Human-written fix with AI assistance:**
```
fix(parser): handle empty input gracefully

Previously, empty input caused a null pointer exception.
Added guard clause at the top of parse().

AI-assisted: true
AI-tool: GitHub Copilot
AI-scope: null check suggestion
AI-review: passed
Ticket: BUG-891
```

**Pure human commit:**
```
chore(deps): bump lodash from 4.17.20 to 4.17.21

AI-assisted: false
```

## JSON Schema Validation

The [commit-message.json schema](../schemas/commit-message.json) enforces:

1. Type must be a valid Conventional Commit type
2. If `AI-assisted: true`, then `AI-tool` is required
3. `AI-review` must be one of: `pending`, `passed`, `failed`
4. `AI-confidence` must be one of: `low`, `medium`, `high`
5. Breaking changes require `!` or `BREAKING CHANGE:` footer

## Tooling

### CLI
```bash
# Validate the last commit
ods validate commit HEAD

# Validate from a message file
ods validate commit --file commit-msg.txt

# Generate a compliant commit template
ods generate commit --type feat --scope auth --ai-tool "GitHub Copilot"
```

### Pre-commit Hook
```bash
#!/bin/sh
# .git/hooks/commit-msg
ods validate commit --file "$1" || exit 1
```

## Relationship to Other Specs

- [01 — Branch Naming](01-branch-naming.md): Branch type should align with commit type
- [03 — PR Description](03-pr-description.md): PR body aggregates commits for review
- [04 — AI Change Review](04-ai-change-review.md): `AI-review: pending` triggers review workflow
