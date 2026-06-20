---
title: Adoption Guide
nav_order: 5
---

# ODS Adoption Guide

**For teams that want to adopt ODS without reading the spec first.**

This guide walks through adopting ODS in a real team, from zero to full enforcement. It is designed to be copied, adapted, and shared with your engineering organization.

---

## Overview

| Step | What you do | Time | Who |
|------|-------------|------|-----|
| [1](#step-1-add-the-pr-template) | Add PR template | 2 min | One person |
| [2](#step-2-add-the-validate-action) | Add CI validation | 5 min | One person |
| [3](#step-3-make-the-report-visible) | Badge, report, PR comment | 5 min | One person |
| [4](#step-4-team-rollout) | Progressive rollout | 1-2 weeks | Team lead |
| [5](#step-5-add-ai-disclosure) | AI disclosure (optional) | 5 min | Team |
| [6](#step-6-customize-policy) | Customize `.ods/policy.rego` | 15 min | Team lead |

---

## Step 1: Add the PR Template

**Goal:** Every new PR starts with the right structure.

Run `ods init` to scaffold everything, or copy just the PR template:

```bash
# One-command scaffold (recommended)
ods init
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

**Goal:** CI runs the ODS AI quality gate on every PR before merge.

Add this workflow file to `.github/workflows/`:

**`ods-ai-quality.yml`** — runs the full ODS pipeline on every PR:

```yaml
name: ODS AI Quality Gate
on:
  pull_request:
    types: [opened, synchronize, reopened]

permissions:
  contents: read
  pull-requests: write

jobs:
  ods:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
        with:
          fetch-depth: 0  # required for git diff against base
      - uses: open-delivery-spec/validate-action@v1
```

The Action:
1. **Detects** AI code from `Co-Authored-By` trailers, PR disclosure, branch names, and diff heuristics
2. **Analyzes** code quality for AI-specific defects
3. **Scores** technical debt impact
4. **Enforces** your `.ods/policy.rego` policy (if present) — exits non-zero on `BLOCK`

**What changes:**
- Every PR gets the ODS quality gate
- A compliance report is posted as a PR comment
- Custom policy blocks (defined in `.ods/policy.rego`) prevent merge when branch protection is configured

**Success check:** Open a PR. The ODS bot posts a compliance report comment. The Actions run shows detect → analyze → score → check steps.

---

## Step 3: Make the Report Visible

**Goal:** Developers see compliance status without digging into CI logs.

The validate-action outputs three surfaces by default:

1. **PR comment** — a compliance report is posted as a comment on every PR
2. **Job summary** — a Markdown summary appears in the Actions run page
3. **Workflow artifact** — HTML, JSON, SVG, and Markdown files downloadable from the run

Add an ODS badge to your README:

```markdown
[![ODS](https://img.shields.io/badge/ODS-AI%20Quality%20Gate-blue)](https://github.com/open-delivery-spec/spec)
```

**Success check:** Open a PR. The ODS bot posts a compliance comment. The Actions run shows the summary.

---

## Step 4: Team Rollout

**Goal:** Adopt ODS across the team without friction.

Use progressive enforcement:

### Week 1: Observe

- The ODS workflow runs but branch protection does not yet require it
- Team gets used to the PR template and seeing the ODS report
- Review the ODS compliance report in PR comments — note common patterns

### Week 2: Require the check

Enable branch protection:

- Require the ODS workflow check to pass before merge
- Team chat: share the most common ODS findings and how to address them

### Week 3+: Add blocking policy

Create `.ods/policy.rego` for custom enforcement:

```rego
package ods.policy

default allow := true

# Block AI code with insufficient test coverage
deny[msg] {
    input.ai_generated == true
    input.ai_confidence > 0.8
    input.test_coverage < 0.3
    msg = "AI code with low test coverage"
}
```

**Team communication template:**

> We're adopting [Open Delivery Spec](https://github.com/open-delivery-spec/spec) (ODS) to make our PRs easier to review — especially for AI-assisted changes. Starting this week, CI will run an AI quality check on every PR. The ODS bot posts a report on each PR. This week is observe-only; next week we'll require the check to pass. Questions? See the [ODS adoption guide](https://open-delivery-spec.github.io/spec/adoption-guide.html).

---

## Step 5: Add AI Disclosure

**Goal:** Make AI involvement in code changes explicit and machine-checkable.

### Commit messages

The easiest path: use a tool that emits `Co-Authored-By` automatically (Claude Code, GitHub Copilot, Cursor). ODS detects these without any configuration.

For tools that don't emit `Co-Authored-By`, add it manually:

```text
feat(auth): add OAuth login

Co-Authored-By: GitHub Copilot <175728472+github-copilot[bot]@users.noreply.github.com>
AI-scope: token exchange, session management
AI-review: pending
```

### PR descriptions

The PR template already includes the AI Disclosure section:

```markdown
## AI Disclosure
- [x] This PR contains AI-generated code
- AI Tool: GitHub Copilot
- AI Scope: Provider abstraction, token exchange
- Human Review: Verified OAuth flow, redirect validation
```

**Success check:** Open a PR where commits have `Co-Authored-By` with a recognized AI tool name. The ODS report shows AI detected.

---

## Step 6: Customize Policy

**Goal:** Tune enforcement to your team's conventions using OPA Rego.

Create or edit `.ods/policy.rego` in your repo root:

```rego
package ods.policy

default allow := true

# Block critical issues unconditionally
deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg = sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

# Block AI code with low test coverage
deny[msg] {
    input.ai_confidence > 0.8
    input.test_coverage < 0.3
    msg = "AI code with low test coverage"
}

# Block large tech debt increase with serious issues present
deny[msg] {
    input.technical_debt_delta > 5.0
    some issue in input.issues
    issue.severity == "critical"
    msg = sprintf("Technical debt delta %.1f with critical issues", [input.technical_debt_delta])
}

# Warn on high-confidence AI with multiple quality issues
warn[msg] {
    input.ai_generated == true
    input.ai_confidence > 0.8
    count(input.issues) > 2
    msg = "High-confidence AI code with multiple quality issues"
}
```

Available policy input fields:

| Field | Type | Description |
|-------|------|-------------|
| `input.ai_generated` | bool | Whether AI code was detected |
| `input.ai_confidence` | float | Detection confidence (0.0–1.0) |
| `input.issues` | array | Quality issues found |
| `input.technical_debt_delta` | float | Technical debt impact score |
| `input.test_coverage` | float | Test coverage ratio (0.0–1.0) |
| `input.branch` | string | Branch name |

---

## Troubleshooting

### "My PR comment is too noisy"

Turn off PR comments:

```yaml
- uses: open-delivery-spec/validate-action@v1
  with:
    comment: "false"
```

### "I want to diff against a different base"

By default the Action diffs against `origin/main`. Override it:

```yaml
- uses: open-delivery-spec/validate-action@v1
  with:
    diff-base: origin/develop
```

### "I want to use a specific ODS CLI version"

```yaml
- uses: open-delivery-spec/validate-action@v1
  with:
    cli-ref: v1.2.0
```

### "I want to provide the PR body explicitly"

```yaml
- uses: open-delivery-spec/validate-action@v1
  with:
    pr-body: ${{ github.event.pull_request.body }}
```

---

## Next Steps

- [Read the spec](https://github.com/open-delivery-spec/spec) to understand the schema details
- [Explore scenarios](https://open-delivery-spec.github.io/spec/scenarios/) for your project type
- [Check the roadmap](https://github.com/open-delivery-spec/spec/blob/main/ROADMAP.md) for upcoming features
- [Contribute](https://github.com/open-delivery-spec/spec/blob/main/CONTRIBUTING.md) — ODS is open source
