---
title: Levels
nav_order: 6
---

# ODS Levels

ODS defines a progressive adoption model for the **AI code quality gate**. Each level builds on the previous one, so teams can start with zero-friction visibility and tighten toward hard enforcement at their own pace.

Every level runs the same pipeline — `detect → analyze → score → check`. What changes is how much of it you act on.

## Level Summary

| Level | Name | Focus | What runs |
|-------|------|-------|-----------|
| **ODS L1** | Detect & Disclose | Surface AI involvement on every PR | `detect` |
| **ODS L2** | Analyze & Score | Surface AI-specific quality issues and technical-debt impact | `detect` + `analyze` + `score` |
| **ODS L3** | Enforce | Block merges that violate policy | `detect` + `analyze` + `score` + `check` |

---

## ODS L1 — Detect & Disclose

**The minimum adoption level.** The gate runs on every PR and reports which changes are AI-generated — but never blocks.

| What it ensures | How |
|-----------------|-----|
| AI involvement is visible | `detect` reads `Co-Authored-By` trailers, PR-body disclosure, branch prefixes, and diff heuristics |
| Reviewers know where to look | The PR comment flags AI-touched changes so scrutiny can be targeted |

**Outcome**: Every PR carries a machine-detectable answer to "was this AI-generated?" — with no friction for contributors.

> [!TIP]
> Start here. Run observe-only for a week so the team gets used to the report before anything blocks.

---

## ODS L2 — Analyze & Score

**For teams that want quality signal, not just disclosure.** On top of detection, the gate analyzes AI-generated code for known defect patterns and scores the technical-debt impact of the PR.

| What it ensures | How |
|-----------------|-----|
| AI-specific defects are surfaced | `analyze` applies the rule categories (redundant error handling, over-commenting, unsafe deserialization, missing edge cases, inconsistent patterns) |
| Debt impact is quantified | `score` produces a weighted technical-debt delta across detection confidence, defect density, and coverage gaps |

**Outcome**: You can answer "what quality issues does this AI code have?" and "how much technical debt does this PR add?" — programmatically, on every PR.

---

## ODS L3 — Enforce

**For teams that need a hard gate.** A policy at `.ods/policy.rego` decides what passes. CI exits non-zero on `BLOCK`, and branch protection prevents merge.

| What it ensures | How |
|-----------------|-----|
| Policy is code, not tribal knowledge | `check` evaluates the PR against an OPA Rego policy |
| Enforcement is consistent and auditable | The same policy runs identically in CI for every PR |

```rego
package ods.policy

default allow := true

# Block AI code with insufficient test coverage
deny[msg] {
    input.ai_confidence > 0.8
    input.test_coverage < 0.3
    msg := "AI code with low test coverage"
}
```

**Outcome**: Merges that violate your team's quality bar are blocked before they reach `main`.

---

## Using the Levels

You don't need to start at L3. Most teams start at L1 in observe-only mode:

```yaml
# .github/workflows/ods.yml
- uses: actions/checkout@v7
  with:
    fetch-depth: 0
- uses: open-delivery-spec/validate-action@v1
```

The Action runs the full pipeline and posts a report. To move from L1 to L3, add a `.ods/policy.rego` and require the check in branch protection — no workflow change needed.

## Conformance Language

| Term | Meaning |
|------|---------|
| **ODS L1 Compliant** | The gate runs on every PR and reports AI detection results |
| **ODS L2 Compliant** | L1 + analysis and scoring are surfaced on every PR |
| **ODS L3 Compliant** | L2 + an OPA Rego policy blocks non-conforming PRs |

## Further Reading

- [Get Started](get-started.md) — five-minute setup
- [`.ods/` Convention](ods-artifacts.md) — where the policy and config live
- [Threats and Failure Modes](threats-and-failure-modes.md) — what the gate prevents
