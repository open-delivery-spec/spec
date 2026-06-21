---
title: Before & After
nav_order: 3
parent: Home
---

# ODS: Before & After

ODS does not claim to make code correct. It claims to detect AI involvement, surface its quality signals, and give reviewers a targeted starting point — so less time is spent asking "which part is AI-generated?" and more time is spent actually reviewing it.

## Before ODS

A typical AI-assisted PR:

```
Title: fix stuff

Branch: fix-bug

PR body:
(empty)

Commits:
- fix
- wip
- update
Co-Authored-By: GitHub Copilot <...@github.com>
```

**Reviewer experience:**
1. Opens PR. Reads title "fix stuff." No idea what it fixes.
2. Scrolls through diff — 200 lines changed across 8 files. `Co-Authored-By` trailer is there, but nothing surfaces it.
3. Asks: "What does this fix? Which part is AI-generated? Was this tested?"
4. Waits for reply. Context-switches to another task.
5. Receives reply. Returns to PR. Finally starts actual code review.

**Time to first meaningful review: hours to days.**
**Clarification questions per PR: 3-5.**

## After ODS

The same change, with ODS running in CI:

```
Title: fix(auth): handle expired OAuth state parameter

Branch: bugfix/expired-oauth-state

Commits:
- fix(auth): handle expired OAuth state parameter
  Co-Authored-By: GitHub Copilot <...@github.com>

PR body:

## Summary
Fixes race condition where OAuth state parameter expires before
the callback arrives. Users saw 400 errors during login with slow
connections.

## AI Disclosure
- [x] This PR contains AI-generated code
- AI Tool: GitHub Copilot
- AI Scope: Token refresh logic, state validation
- Human Review: Verified OAuth spec compliance, PKCE flow,
  redirect URI handling
```

ODS detects AI involvement from the `Co-Authored-By` trailer and PR disclosure automatically, then posts this compliance report:

```
## ODS AI Code Quality Report

Result: ⚠️ WARN
AI Detected: Yes (confidence: 85%)
Tech Debt Delta: +2.1 (increase)
Policy: ✅ Allowed

### Detection
| Source       | Signal                                  | Confidence |
|--------------|-----------------------------------------|------------|
| Co-Authored-By | GitHub Copilot commit trailer          | 80%        |
| pr-body      | AI disclosure checkbox is checked       | 85%        |

### Analysis
1 issue found:
| Severity | Rule                   | Location           |
|----------|------------------------|--------------------|
| medium   | ai-missing-edge-case   | auth/token.go:142  |

### Score
AI Code Ratio: 78% | Defect Density: 0.8/KLOC | Test Coverage: 42%
```

**Reviewer experience:**
1. Reads title: knows it's a bugfix in auth module for OAuth state expiry.
2. Reads Summary: understands the race condition in one sentence.
3. Reads ODS report: AI was detected at high confidence; one specific issue flagged at `auth/token.go:142`.
4. Goes straight to `token.go:142` — reviews the missing edge case carefully.
5. Reads AI Disclosure: confirms what the AI touched and what the human verified.
6. Starts code review with full context. Zero clarification questions.

**Time to first meaningful review: minutes.**
**Clarification questions per PR: 0.**

## What ODS Signals — And What It Doesn't

ODS produces heuristic signals and policy verdicts. The numbers are indicators for policy thresholds — not precise measurements of code quality.

| What ODS produces | What it is not |
|---|---|
| AI detected at 85% confidence | Proof that exactly 85% of lines are AI-written |
| Issue: `ai-missing-edge-case` at `token.go:142` | Proof the code is broken — it is a heuristic pattern match |
| Technical debt delta: +2.1 | A precise measurement of future maintenance cost |
| Policy `PASS` — no deny rule fired | Proof the code has no bugs |
| Policy `BLOCK` — a deny rule fired | A permanent verdict — only that the change did not meet your policy thresholds |

The numbers exist for Rego policies to threshold on. `input.ai_confidence > 0.8` means "when we are highly confident this is AI code, apply extra scrutiny." The value 0.85 is not a scientific measurement — it is the weighted result of multiple independent signals (commit trailers, PR disclosure, branch prefix, diff heuristics). What matters is whether it crosses your team's threshold.

## Design Philosophy

> ODS is a signal producer, not a quality oracle. The pipeline generates structured, machine-readable signals about AI involvement, code patterns, and debt impact. Your policy decides what those signals mean for your team.

A smoke detector does not tell you whether there is a fire or how serious it is. It signals "smoke detected" so you can investigate. ODS signals "high-confidence AI code with a missing edge case at line 142" so reviewers know where to look. The reviewer decides whether the code is acceptable.

## Try It

1. Copy the [PR Template](https://github.com/open-delivery-spec/spec/blob/main/examples/ods-pr-template.md) into `.github/PULL_REQUEST_TEMPLATE.md`
2. Add the [ODS GitHub Action](https://github.com/open-delivery-spec/validate-action) to your CI
3. Compare your next 5 PRs to the previous 5

See [Get Started](get-started.md) for the full adoption guide.
