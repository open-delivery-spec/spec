# Open Delivery Spec (ODS)

> **Zero-config AI code detection for teams using Claude Code, Copilot, or Cursor.** These tools already write `Co-Authored-By` trailers to every commit. ODS reads them automatically in CI — detecting AI-generated code, analyzing quality, scoring technical debt, and enforcing policy on every PR.

[![CI](https://github.com/open-delivery-spec/spec/actions/workflows/ci.yml/badge.svg)](https://github.com/open-delivery-spec/spec/actions/workflows/ci.yml)
[![Spec](https://img.shields.io/badge/spec-read-blue?logo=readthedocs&logoColor=white)](https://open-delivery-spec.github.io/spec/)


---

## What ODS Does

Enterprises are adopting AI coding tools at speed — but AI-generated code increases technical debt in predictable, detectable ways. ODS is the CI gate that stops this.

```
PR arrived
   │
   ▼
① Detect  — Which code is AI-generated? (Co-Authored-By trailers, PR disclosure, branch prefix, diff heuristics)
   │
   ▼
② Analyze — What quality defects does the AI code have? (5 rule categories)
   │
   ▼
③ Score   — How much technical debt does this PR add? (5-dimension weighted score)
   │
   ▼
④ Enforce — Should this PR be blocked? (OPA Rego policies)
   │
   ▼
PASS / WARN / BLOCK
```

---

## Quick Start

```bash
# Install CLI
go install github.com/open-delivery-spec/cli/cmd/ods@latest

# Detect AI code in your PR
ods detect

# Analyze AI code quality
ods analyze

# Score technical debt impact
ods score

# Enforce enterprise policy
ods check

# Install pre-commit hooks
ods hook install
```

---

## The Four Commands

### 1. Detect — AI Code Detection

Finds AI-generated code using multiple independent signals. `Co-Authored-By` trailers — automatically emitted by Claude Code, GitHub Copilot, and Cursor — are the primary signal. No configuration required.

| Signal | Source |
|---|---|
| **`Co-Authored-By` commit trailers** | Auto-emitted by Claude Code, GitHub Copilot, Cursor — primary signal |
| ODS trailer fields | `AI-assisted: true`, `AI-tool: name` — supplemental, optional |
| PR body AI disclosure | Checkbox and section parsing |
| Branch name prefix | `claude/`, `copilot/`, `cursor/`, `ai-*` prefixes |
| Diff heuristics | Comment ratio, verbose naming, error patterns |

### 2. Analyze — Quality Defect Detection

Checks AI code for known failure patterns:

| Rule | What it detects |
|---|---|
| `ai-redundant-error-handling` | Dense clusters of if-err-nil blocks |
| `ai-over-commenting` | Comment-to-code ratio >40% |
| `ai-missing-edge-case` | if-statements without else branches |
| `ai-unsafe-deserialization` | json.Unmarshal into interface{} |
| `ai-inconsistent-pattern` | Mixed naming conventions / indentation |

### 3. Score — Technical Debt Impact

Computes a 5-dimension weighted score:

| Dimension | Weight |
|---|---|
| AI code ratio | 3.0 |
| Defect density | 2.0 |
| Critical issues | 1.5 each |
| Test coverage gap | 1.0 |
| Code duplication | 1.0 |

Verdict: **decrease** / **neutral** / **increase**

### 4. Enforce — OPA Policy Engine

Write enterprise policies in Rego:

```rego
# .ods/policy.rego
package ods.policy

default allow := true

deny[msg] {
    input.ai_confidence > 0.8
    input.test_coverage < 0.3
    msg = "AI code with low test coverage"
}
```

---

## Tooling

| Tool | Repository |
|------|------------|
| ODS CLI | [open-delivery-spec/cli](https://github.com/open-delivery-spec/cli) |
| GitHub Action | [open-delivery-spec/validate-action](https://github.com/open-delivery-spec/validate-action) |

---

## Design Principles

1. **Detect, don’t rely on disclosure.** `Co-Authored-By` trailers are emitted automatically — detection works even without developer cooperation.
2. **Deterministic rules, probabilistic signals.** Quality rules are yes/no. Detection confidence is a signal for policy thresholds, not a verdict.
3. **Tool-agnostic.** Works with GitHub, GitLab, Jenkins, or any CI/CD that can run a binary.
4. **Policy as code.** Enterprise rules written in Rego, version-controlled alongside code.
5. **Prevent, don’t just report.** Pre-commit hooks block problems before they reach CI.

---

## Ecosystem / Related Standards

See [docs/ecosystem.md](docs/ecosystem.md) for how ODS relates to:
- **APP / C2PA** — content provenance (complementary)
- **SLSA** — supply chain integrity (co-deployable)
- **Conventional Commits / Conventional Branch** — extended by ODS
- **AI code linters and platform review** — augmented by ODS

---

## License

[Apache License 2.0](LICENSE)
