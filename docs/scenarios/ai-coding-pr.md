---
title: Scenario: AI-Heavy Team
nav_order: 13
---

# Scenario: AI-Heavy Coding Team

**Use case:** A startup team of 4 engineers uses AI coding tools (Cursor, Copilot, Claude) for 60-80% of their code. They ship fast but are losing track of what AI wrote and where its quality defects hide. They want to keep the speed but add an automated guardrail.

## Profile

- Team: 4 engineers
- Repo: Private on GitHub
- AI tools: Cursor (primary), GitHub Copilot (secondary), Claude (architecture)
- AI usage: 60-80% of code is AI-generated or AI-assisted
- Goal: Detect AI code per PR, surface its quality issues, and block the worst before merge

## The problem they faced

> "We shipped a payment integration in 2 days. It passed CI, passed tests, went to production. Two weeks later we found a race condition in the token refresh logic — AI had hallucinated a non-existent API method. No one reviewed that specific function because the PR was 800 lines and looked fine at a glance."

**Root cause:** No automated way to know *where* AI contributed or *what quality issues* it introduced, so reviewers couldn't apply targeted scrutiny.

## Configuration

### `.github/workflows/ods.yml`

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
          fetch-depth: 0
      - uses: open-delivery-spec/validate-action@v1
```

The Action runs the full pipeline — `detect → analyze → score → check` — and posts a compliance report comment on every PR.

### `.ods/policy.rego`

Block the highest-risk AI changes; warn on the rest:

```rego
package ods.policy

default allow := true

# Block AI code that introduces unsafe deserialization or other critical issues
deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

# Block high-confidence AI code with low test coverage
deny[msg] {
    input.ai_confidence > 0.8
    input.test_coverage < 0.3
    msg := "AI code with low test coverage"
}

# Warn on AI changes carrying several quality issues
warn[msg] {
    input.ai_generated == true
    count(input.issues) > 2
    msg := "AI change with multiple quality issues — review carefully"
}
```

### Agent instructions

Add to `.cursorrules`, `AGENTS.md`, or `.github/copilot-instructions.md` so AI tools disclose their work by default:

```markdown
## ODS

- Keep commit `Co-Authored-By` trailers intact so ODS can detect AI involvement.
- In the PR description, state what the AI generated and what you personally verified.
- Add tests for AI-generated logic — the ODS policy blocks high-confidence AI code with low coverage.
```

## Before / After

### Before ODS — a typical AI-assisted PR

```
Title: add payment integration
Branch: payment-integration
PR body: Added the new payment provider integration. Works on my machine.
```

**Result:** Reviewer skims an 800-line diff, approves. The hallucinated API method and its race condition ship to production.

### After ODS — same change, gated

```
Title: feat(payments): add Stripe payment provider integration
Branch: feature/stripe-payment-provider
Commit trailer: Co-Authored-By: Cursor <...>
```

The ODS bot comments on the PR:

```
## ODS Compliance Report — WARN

AI detected: yes (confidence 0.91, source: Co-Authored-By + diff heuristics)
Technical-debt delta: +6.2

| Severity | Rule | Location |
|----------|------|----------|
| high     | ai-unsafe-deserialization | payments/webhook.go:88 |
| medium   | ai-inconsistent-pattern   | payments/token.go:142  |

Policy: WARN — AI change with multiple quality issues. Review carefully.
```

**Result:** The reviewer goes straight to `token.go:142` and `webhook.go:88`, catches the hallucinated API method before merge. Review takes 15 minutes instead of 5 — but the bug never reaches production.

## What changes for the team

1. **Engineer ships AI code** → commits keep their `Co-Authored-By` trailers.
2. **CI runs the gate** → `detect → analyze → score → check` on every PR.
3. **ODS bot comments** → AI detection, quality issues, and debt delta, with pass/warn/block.
4. **Reviewer reads the report first** → focuses on the flagged AI-generated lines.
5. **Policy blocks the worst** → critical issues and untested high-confidence AI code can't merge.

| Before | After |
|--------|-------|
| Read entire diff top to bottom | Read the ODS report, then review flagged AI lines closely |
| Assume all code is hand-written | Know exactly what AI contributed and where its issues are |
| Quality bar varies by reviewer | Policy enforces the same bar on every PR |

## Lessons learned

1. **The quality report changes reviewer behavior immediately** — they stop skimming and start targeting.
2. **Keep commit trailers.** `Co-Authored-By` is the highest-confidence detection signal and survives squash merges.
3. **Start with WARN, then BLOCK.** Observe the findings for a week, then turn on the blocking policy once the team trusts it.

## Next steps after adoption

1. Tighten `.ods/policy.rego` as the team's quality bar rises (e.g. lower the debt-delta tolerance).
2. Require the ODS check in branch protection to make the gate mandatory.
3. See [ODS Levels](../levels.md) to plan the L1 → L3 progression.
