# 01 — Branch Naming

**Version:** 1.0.0-draft  
**Status:** Candidate  
**Schema:** [`schemas/branch-naming.json`](../schemas/branch-naming.json)  
**Based on:** [Conventional Branch 1.0.0](https://conventional-branch.github.io)

## Overview

Every code change starts with a branch. AI agents create branches automatically. Without a standard naming convention, branch names become inconsistent, unsearchable, and impossible to audit.

Open Delivery Spec extends [Conventional Branch](https://conventional-branch.github.io) with AI-specific metadata and stricter validation rules suitable for automated governance.

## Specification

### Branch Name Format

```
<type>/<description>
```

| Component | Format | Required | Example |
|-----------|--------|----------|---------|
| `type` | One of: `feature`, `bugfix`, `hotfix`, `release`, `chore` | **Yes** | `feature` |
| `description` | kebab-case, lowercase, alphanumeric + hyphens | **Yes** | `add-oauth-login` |

### Branch Types

| Type | Alias | Purpose | Typical AI Use |
|------|-------|---------|----------------|
| `feature/` | `feat/` | New features or enhancements | AI-generated feature implementation |
| `bugfix/` | `fix/` | Bug fixes | AI-assisted bug resolution |
| `hotfix/` | — | Urgent production fixes | Emergency patches |
| `release/` | — | Release preparation (dots allowed in version) | Automated release branches |
| `chore/` | — | Non-code tasks (deps, docs, config) | AI maintenance tasks |

### Trunk Branches

`main`, `master`, and `develop` are trunk branches — they do not use a prefix.

## Naming Rules (Strict)

- **Lowercase only** — `a-z` only (no uppercase)
- **Allowed characters** — `a-z`, `0-9`, `-`, `.` (dots only in `release/` version)
- **No underscores**, spaces, or special characters
- **No consecutive hyphens** (`--`), dots (`..`), or hyphen-dot adjacency (`-.`, `.-`)
- **No leading or trailing hyphens or dots**

### Formal Grammar (ABNF)

```abnf
branch-name     = trunk-branch / prefixed-branch
trunk-branch    = "main" / "master" / "develop"
prefixed-branch = type "/" description
type            = "feature" / "feat" / "bugfix" / "fix"
                / "hotfix" / "release" / "chore"
description     = desc-segment *("-" desc-segment)
desc-segment    = 1*(ALPHA / DIGIT) *("." 1*(ALPHA / DIGIT))
ALPHA           = %x61-7A
DIGIT           = %x30-39
```

### Examples

**Valid:**
```
feature/add-login-page
feat/add-login-page
bugfix/fix-header-overflow
fix/header-overflow
hotfix/critical-security-patch
release/v1.2.0
chore/update-dependencies
feature/issue-123-add-oauth
```

**Invalid:**
| Branch | Problem |
|--------|---------|
| `Feature/Add-Login` | Uppercase letters |
| `feature/new--login` | Consecutive hyphens |
| `feature/-new-login` | Leading hyphen |
| `fix/header_bug` | Underscore |
| `unknown/some-task` | Unknown type prefix |

## ODS Extensions

Beyond Conventional Branch, ODS adds:

### AI Attribution

AI attribution is supported via JSON metadata (primary) and optional branch name convention (secondary).

**Primary — JSON metadata (recommended):**

The [branch-naming.json schema](../schemas/branch-naming.json) includes `ai_generated` and `ai_tool` fields for machine-readable AI attribution. Tools should rely on this metadata, not branch name heuristics.

**Secondary — Branch name convention (optional):**

As a lightweight signal, teams MAY prefix the description with `ai-` when the branch was created by an AI agent:

```
feature/ai-add-oauth-provider
bugfix/ai-fix-null-pointer
```

> [!NOTE]
> This is purely a human-readable convention. The `ai-` prefix triggers a **warning** in ODS tooling (not an error), reminding reviewers to apply appropriate scrutiny. The primary AI attribution mechanism is the JSON metadata.

### Ticket Integration

When the change relates to an issue tracker ticket, include it in the description:

```
feature/proj-1234-add-oauth
bugfix/proj-5678-fix-header
```

### JSON Schema Metadata

The [branch-naming.json schema](../schemas/branch-naming.json) adds metadata that tools can use for automated governance:

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

## Tooling Validation

### CLI
```bash
ods validate branch feature/add-oauth-login
ods validate branch --json branch-metadata.json
```

### GitHub Action
```yaml
- uses: open-delivery-spec/github-action@v1
  with:
    check: branch-naming
```

## Relationship to Other Specs

- [02 — Commit Message](02-commit-message.md): Branch type should align with commit type
- [04 — AI Change Review](04-ai-change-review.md): AI-generated branches require enhanced review
- [06 — Release Readiness](06-release-readiness.md): Release branches must pass naming validation
