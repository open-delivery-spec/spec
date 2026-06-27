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
③ Score   — How much technical debt does this PR add? (quality-driven score, AI-risk weighted)
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

Built-in heuristics flag known AI failure patterns. They are deliberately
conservative **hints** — for authoritative, multi-language analysis, import
findings from a dedicated scanner (Semgrep, CodeQL, golangci-lint, …) as SARIF.

| Rule | What it detects | Severity |
|---|---|---|
| `ai-unsafe-deserialization` | json.Unmarshal into interface{} | high |
| `ai-inconsistent-pattern` | Mixed naming conventions / indentation | medium |
| `ai-redundant-error-handling` | Dense clusters of if-err-nil blocks | info |
| `ai-over-commenting` | Comment-to-code ratio ≥40% | info |

Imported SARIF findings keep their tool's own rule IDs and severities, and feed
the score and policy gate alongside the built-in rules. The full, machine-readable
catalogue is `ods rules --json`.

### 3. Score — Technical Debt Impact

Technical debt is driven by code **quality**, not by how much of the change is
AI-written. Quality signals form the base debt:

| Quality dimension | Weight |
|---|---|
| Defect density (high/critical per KLOC) | 2.0 |
| Critical + high issues | 1.5 each |
| Test coverage gap (when measured) | 1.0 |
| Code duplication | 1.0 |

The **AI code ratio** is then applied as a bounded risk multiplier
(`1.0 + 0.5 × ai_ratio`, i.e. 1.0–1.5×): AI-authored defects and untested AI
code carry more risk because no human reasoned through them. But AI quantity
**alone never creates debt** — a clean, fully-AI change scores ~0.

```
technical_debt_delta = quality_debt × (1 + 0.5 × ai_code_ratio)
```

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
