# 02 — Commit Message

**Version:** 1.0.0-draft  
**Status:** Candidate  
**Schema:** [`schemas/commit-message.json`](../schemas/commit-message.json)  
**Based on:** [Conventional Commits 1.0.0](https://www.conventionalcommits.org)

## Overview

In the AI era, commits need to answer: *Who wrote this — human, AI, or both?* ODS extends Conventional Commits with AI attribution metadata, making every commit auditable.

**Design principle:** ODS aligns with the git ecosystem rather than forking it. The `Co-Authored-By` trailer already emitted by Claude Code, GitHub Copilot, and Cursor is the **primary** AI attribution signal. ODS-specific trailer fields are supplemental.

## Specification

### Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### AI Attribution: Primary Signal — `Co-Authored-By`

AI coding tools already emit `Co-Authored-By` footers automatically. ODS treats these as first-class AI attribution:

```
feat(auth): add OAuth 2.0 login flow

Implemented OAuth 2.0 authorization code flow with PKCE.
Supports Google, GitHub, and Microsoft providers.

Co-Authored-By: Claude <noreply@anthropic.com>
```

A commit with a recognized AI tool in `Co-Authored-By` is already an ODS-compliant AI disclosure. No additional fields are required.

### Known AI Tool `Co-Authored-By` Formats

`ods detect` recognizes the following trailers as AI attribution:

| Tool | Emitted by | Example footer |
|------|-----------|----------------|
| Claude / Claude Code | Automatic | `Co-Authored-By: Claude <noreply@anthropic.com>` |
| GitHub Copilot | Automatic | `Co-Authored-By: GitHub Copilot <175728472+github-copilot[bot]@users.noreply.github.com>` |
| Cursor | Automatic | `Co-Authored-By: Cursor <cursor@cursor.sh>` |
| Custom | Team convention | Any `Co-Authored-By` whose name matches a known AI tool |

### ODS Supplemental Trailer Fields

For teams that want richer attribution metadata beyond `Co-Authored-By`, ODS defines optional supplemental footers:

```
feat(auth): add OAuth 2.0 login flow

Implemented OAuth 2.0 authorization code flow with PKCE.
Supports Google, GitHub, and Microsoft providers.

Co-Authored-By: Claude <noreply@anthropic.com>
AI-scope: auth module, token refresh logic
AI-review: pending
```

| Footer Field | Required | Values | Description |
|---|---|---|---|
| `Co-Authored-By` | **Yes, when AI used** | `<name> <email>` | Primary AI attribution signal — standard git convention |
| `AI-assisted` | Optional | `true` / `false` | Explicit flag; redundant when `Co-Authored-By` names an AI tool |
| `AI-tool` | Optional | Tool name | Redundant when `Co-Authored-By` already names the tool |
| `AI-scope` | Recommended | Free text | What the AI specifically generated |
| `AI-review` | Recommended | `pending` / `passed` / `failed` | Review status of AI-generated code |
| `AI-confidence` | Optional | `low` / `medium` / `high` | Author's confidence in AI-generated portion |
| `Ticket` | Recommended | Issue tracker ID | e.g., `PROJ-1234` |
| `Risk` | Optional | `low` / `medium` / `high` | Author-assessed deployment risk |

### Standard Fields (from Conventional Commits)

| Field | Required | Description |
|-------|----------|-------------|
| `type` | **Yes** | `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert` |
| `scope` | No | Affected module or component (parentheses) |
| `description` | **Yes** | Short summary, imperative mood, lowercase |
| `body` | No | Detailed explanation, motivation, contrast |
| `footer` | No | Breaking changes, issue references |

### Breaking Changes

Breaking changes MUST be indicated with `!` after the type/scope OR with `BREAKING CHANGE:` in the footer:

```
feat!: remove legacy auth endpoint

BREAKING CHANGE: The /v1/auth endpoint has been removed.
Migration guide: https://docs.example.com/migration/v2
```

### Examples

**AI-generated feature (Claude Code emits `Co-Authored-By` automatically):**
```
feat(search): add semantic search capability

Co-Authored-By: Claude <noreply@anthropic.com>
AI-scope: embedding generation, query parser
AI-review: pending
Ticket: SEARCH-42
```

**Human-written with Copilot assist:**
```
fix(parser): handle empty input gracefully

Previously, empty input caused a null pointer exception.
Added guard clause at the top of parse().

Co-Authored-By: GitHub Copilot <175728472+github-copilot[bot]@users.noreply.github.com>
AI-scope: null check suggestion
AI-review: passed
Ticket: BUG-891
```

**Pure human commit:**
```
chore(deps): bump lodash from 4.17.20 to 4.17.21
```

## JSON Schema Validation

The [commit-message.json schema](../schemas/commit-message.json) enforces:

1. Type must be a valid Conventional Commit type
2. If `AI-assisted: true`, then `AI-tool` is required (backward compatibility)
3. `AI-review` must be one of: `pending`, `passed`, `failed`
4. `AI-confidence` must be one of: `low`, `medium`, `high`
5. Breaking changes require `!` or `BREAKING CHANGE:` footer

## Tooling

```bash
# Validate the last commit
ods validate commit HEAD

# Validate from a message file
ods validate commit --file commit-msg.txt
```

`ods detect` reads both `Co-Authored-By` (primary) and `AI-assisted:` (supplemental) trailer fields when scanning commits.

## Relationship to Other Specs

- [01 — Branch Naming](01-branch-naming.md): Branch type should align with commit type
- [03 — PR Description](03-pr-description.md): PR body aggregates commits for review
