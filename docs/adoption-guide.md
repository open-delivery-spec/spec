# ODS Adoption Guide

**For teams that want to adopt ODS without reading the spec first.**

This guide walks through adopting ODS L1 in a real team, from zero to full enforcement. It is designed to be copied, adapted, and shared with your engineering organization.

---

## Overview

| Step | What you do | Time | Who |
|------|-------------|------|-----|
| [1](#step-1-add-the-pr-template) | Add PR template | 2 min | One person |
| [2](#step-2-add-the-validate-action) | Add CI validation | 5 min | One person |
| [3](#step-3-make-the-report-visible) | Badge, report, PR comment | 5 min | One person |
| [4](#step-4-team-rollout) | Progressive rollout | 1-2 weeks | Team lead |
| [5](#step-5-add-ai-disclosure) | AI disclosure (optional) | 5 min | Team |
| [6](#step-6-customize-policy) | Customize `.ods.yaml` | 15 min | Team lead |

---

## Step 1: Add the PR Template

**Goal:** Every new PR starts with the right structure.

Run `ods init` to scaffold everything, or copy just the PR template:

```bash
# One-command scaffold (recommended)
ods init github
```

Or manually:

```bash
# Copy the PR template
curl -o .github/PULL_REQUEST_TEMPLATE.md \
  https://raw.githubusercontent.com/open-delivery-spec/spec/main/examples/ods-pr-template.md
```

**What changes:**
- `.github/PULL_REQUEST_TEMPLATE.md` — developers see this when opening a PR
- Developers fill in Summary, Changes, Testing, AI Disclosure sections
- No CI enforcement yet — this is just a template

**Success check:** Open a test PR. The template appears in the description box.

---

## Step 2: Add the validate-action

**Goal:** CI validates that every PR has the required metadata before merge.

Add these two workflow files to `.github/workflows/`:

**`ods-l1.yml`** — validates branch name and PR description on every PR:

```yaml
name: ODS L1
on:
  pull_request:
    types: [opened, edited, synchronize, reopened]

permissions:
  contents: read
  pull-requests: write
  issues: write

jobs:
  ods:
    runs-on: ubuntu-latest
    steps:
      - uses: open-delivery-spec/validate-action@v1
        with:
          check: all
          branch_name: ${{ github.head_ref }}
          pr_body: ${{ github.event.pull_request.body }}
          strict: "true"
```

**`ods-commit-message.yml`** — validates commit messages on push:

```yaml
name: ODS Commit Message
on: [push]

jobs:
  ods-commit:
    runs-on: ubuntu-latest
    steps:
      - uses: open-delivery-spec/validate-action@v1
        with:
          check: commit-message
          commit_message: ${{ github.event.head_commit.message }}
          strict: "true"
```

> [!TIP]
> Start with `strict: "false"` to treat warnings as non-blocking. Switch to `"true"` after the team adjusts.

**What changes:**
- Every PR gets validated for branch naming and PR description
- Every push gets validated for commit message format
- Failed checks block merge (if branch protection is configured)

**Success check:** Open a PR with a branch like `fix-bug`. The check fails. Rename to `bugfix/fix-null-pointer`. The check passes.

---

## Step 3: Make the Report Visible

**Goal:** Developers see compliance status without digging into CI logs.

The validate-action outputs three surfaces by default:

1. **PR comment** — a compliance report is posted as a comment on every PR
2. **Job summary** — a Markdown summary appears in the Actions run page
3. **Workflow artifact** — HTML, JSON, SVG, and Markdown files downloadable from the run

Add an ODS badge to your README:

```markdown
[![ODS L1](https://img.shields.io/badge/ODS-L1%20Structured%20Delivery-blue)](https://github.com/open-delivery-spec/spec)
```

**Success check:** Open a PR. The ODS bot posts a compliance comment. The Actions run shows the summary.

---

## Step 4: Team Rollout

**Goal:** Adopt ODS across the team without friction.

Use progressive enforcement:

### Week 1: Observe

```yaml
strict: "false"
```

- All checks run but warnings don't block merge
- Team gets used to the PR template and branch naming
- Review the ODS compliance report in PR comments — note common failures

### Week 2: Warn

Enable branch protection:

- Require the ODS L1 check to pass before merge
- Team chat: share the most common failures and how to fix them
- Keep `strict: "false"` so only hard errors block

### Week 3+: Enforce

```yaml
strict: "true"
```

- Warnings become errors
- AI disclosure becomes mandatory (if enabled)
- All PRs are fully ODS L1 compliant before merge

**Team communication template:**

> We're adopting [Open Delivery Spec](https://github.com/open-delivery-spec/spec) (ODS) to make our PRs easier to review — especially for AI-assisted changes. Starting this week, CI will check that every PR has a structured description and follows branch/commit conventions. The ODS bot posts a compliance report on each PR. This week is observe-only; next week we'll require the check to pass. Questions? See [our adoption guide](.github/ODS-ADOPTION.md).

---

## Step 5: Add AI Disclosure

**Goal:** Make AI involvement in code changes explicit and machine-checkable.

If your team uses AI coding tools (Copilot, Cursor, Claude, etc.), enable AI disclosure:

### Commit messages

Add AI attribution trailers to commit messages:

```text
feat(auth): add OAuth login

AI-assisted: true
AI-tool: GitHub Copilot
AI-scope: token exchange, session management
AI-review: pending
```

### PR descriptions

The PR template already includes the AI Disclosure section:

```markdown
## AI Disclosure
- [x] This PR contains AI-generated code
- **AI Tool:** GitHub Copilot
- **AI Scope:** Provider abstraction, token exchange
- **Human Review:** Verified OAuth flow, redirect validation
```

### Configure enforcement

In `.ods.yaml`:

```yaml
policy:
  ai_disclosure:
    required: true
    strict_tool_name: true
    require_human_review: true
```

**Success check:** Create a PR with AI-generated code but no disclosure. The check warns or fails.

---

## Step 6: Customize Policy

**Goal:** Tune ODS to your team's conventions.

Create or edit `.ods.yaml` in your repo root:

```yaml
profile: enterprise

policy:
  branch:
    allowed_types:
      - feature
      - bugfix
      - hotfix
      - release
      - chore
      - docs       # add your team's types
    require_ticket: false   # set true if you use Jira tickets in branch names
    max_description_length: 100

  commit:
    allowed_types:
      - feat
      - fix
      - docs
      - refactor
      - test
      - chore
    require_scope: true
    max_subject_length: 72

  pr:
    required_sections:
      - "## Summary"
      - "## Changes"
      - "## Testing"
      - "## Checklist"
      # remove sections your team doesn't need

  severity:
    branch_type: error
    branch_format: error
    pr_sections: error
    commit_type: error
    commit_scope: warning    # treat missing scope as a warning
```

Available profiles:
- `oss` — no AI disclosure required, relaxed rules
- `enterprise` — full L1 + AI disclosure (recommended)
- `regulated` — maximum enforcement with ticket requirements

---

## Troubleshooting

### "My branch name fails but our convention uses a different prefix"

Add your prefix to `.ods.yaml`:

```yaml
policy:
  branch:
    allowed_types: [feature, bugfix, hotfix, release, chore, exp]
```

### "My commit messages don't use scopes"

Either add scopes, or relax the rule:

```yaml
policy:
  commit:
    require_scope: false
  severity:
    commit_scope: warning
```

### "The PR template has too many sections"

Remove sections from `required_sections` in `.ods.yaml`:

```yaml
policy:
  pr:
    required_sections:
      - "## Summary"
      - "## Changes"
      - "## Testing"
```

### "I want to disable PR comments (too noisy)"

```yaml
- uses: open-delivery-spec/validate-action@v1
  with:
    check: all
    comment: "false"
```

---

## Next Steps

- [Read the spec](https://github.com/open-delivery-spec/spec) to understand the schema details
- [Explore scenarios](https://open-delivery-spec.github.io/spec/scenarios/) for your project type
- [Check the roadmap](https://github.com/open-delivery-spec/spec/blob/main/ROADMAP.md) for upcoming features
- [Contribute](https://github.com/open-delivery-spec/spec/blob/main/CONTRIBUTING.md) — ODS is open source
