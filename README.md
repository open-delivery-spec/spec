# Open Delivery Spec (ODS)

> **Zero-config governance and visibility for AI-assisted code — on every pull request.** Claude Code, Copilot, and Cursor already stamp `Co-Authored-By` trailers on every commit, so ODS shows how much of your delivery is AI-assisted, routes review attention to the changes that need it, and enforces your policy in CI — no disclosure forms, no manual tagging. It governs the AI you can see; it's a signal producer, not a quality oracle.

[![CI](https://github.com/open-delivery-spec/spec/actions/workflows/ci.yml/badge.svg)](https://github.com/open-delivery-spec/spec/actions/workflows/ci.yml)
[![Spec](https://img.shields.io/badge/spec-read-blue?logo=readthedocs&logoColor=white)](https://open-delivery-spec.github.io/spec/)


---

## What ODS Does

Enterprises are adopting AI coding tools at speed. ODS is the CI layer that makes that adoption **visible and governable** — it attributes AI-assisted code from the trailers the tools already emit, surfaces how much of your delivery is AI-assisted, routes review attention to the risky changes, and enforces your policy on every PR.

```
PR arrived
   │
   ▼
① Detect  — Which code is AI-generated? (Co-Authored-By trailers, PR disclosure, branch prefix, diff heuristics)
   │
   ▼
② Analyze — What quality defects does the AI code have? (built-in AI heuristics + imported SARIF)
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
```

The same four stages run in CI through the [GitHub Action](https://github.com/open-delivery-spec/validate-action); `ods report` and `ods attest` answer the questions that span more than one pull request (below).

---

## The Four Commands

### 1. Detect — AI Code Attribution

Attributes AI-generated code from signals the tools volunteer. `Co-Authored-By`
trailers — automatically emitted by Claude Code, GitHub Copilot, and Cursor — are
the primary signal, so attribution is zero-config. This is **attribution, not
forensic detection**: it reads what the tools disclose; an author who strips the
trailer can evade it, and the diff heuristics are only a low-confidence fallback.
The trailers also have to survive the merge: a squash merge whose message keeps
only the pull request title erases them from `main`, so configure squash merging
to include the commit details, or use rebase or merge commits (see
[Reading the numbers](docs/org-view.md#reading-the-numbers)).
The aggregate confidence is the strongest signal plus a small boost per additional
independent source, capped at 95% — ODS never reports certainty about authorship.

| Signal | Source | Confidence |
|---|---|---|
| **`Co-Authored-By` commit trailers** | Auto-emitted by Claude Code, GitHub Copilot, Cursor — primary signal | high |
| `Assisted-by` commit trailers | The Linux kernel convention, `Assisted-by: AGENT:MODEL` | high |
| ODS trailer fields | `AI-assisted: true`, `AI-tool: name` — supplemental, optional | high |
| git-ai authorship notes | Line-level attribution recorded by [git-ai](https://github.com/git-ai-project/git-ai) under `refs/notes/ai` | highest (measured) |
| PR body AI disclosure | Checkbox and section parsing | high |
| Branch name prefix | `claude/`, `copilot/`, `cursor/`, `codeium/`, `ai-*` prefixes | medium |
| Diff heuristics | Comment ratio, verbose naming, error patterns | low (fallback) |

### 2. Analyze — Quality Defect Detection

Built-in heuristics flag known AI failure patterns. They are deliberately
conservative **hints** — for authoritative, multi-language analysis, import
findings from a dedicated scanner (Semgrep, CodeQL, golangci-lint, …) as SARIF.

| Rule | What it detects | Severity |
|---|---|---|
| `ai-unsafe-deserialization` | json.Unmarshal into interface{} | high |
| `ai-inconsistent-pattern` | Mixed naming conventions / indentation | medium |
| `ai-hallucinated-api` | Removed or deprecated API usage | medium |
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
| Critical + high issues | 1.5 each |
| Test coverage gap (when measured) | 1.0 |
| Code duplication | 1.0 |

Defect density (high/critical findings per KLOC) is reported in the breakdown
for information only; it is not part of the delta, because a per-KLOC rate
charges the same finding far more in a small change than in a large one.

The **AI code ratio** is then applied as a bounded risk multiplier
(`1.0 + 0.5 × ai_ratio`, i.e. 1.0–1.5×): AI-authored defects and untested AI
code carry more risk because no human reasoned through them. But AI quantity
**alone never creates debt** — a clean, fully-AI change scores ~0.

```
technical_debt_delta = quality_debt × (1 + 0.5 × ai_code_ratio)
```

Verdict: the delta's direction (**increase** / **neutral** / **decrease**). Risk: the
band it falls in (**low** ≤ 1.0 < **moderate** ≤ 3.0 < **high** ≤ 5.0 < **critical**).
The AI code ratio is AI lines over the change's added code lines, and it states its
provenance — `git-ai` (measured), `commit-trailer` (the lines AI-attributed commits
added), `diff-heuristics` (estimated), or `unknown`, in which case no ratio is claimed.

### 4. Enforce — OPA Policy Engine

Write enterprise policies in Rego:

```rego
# .ods/policy.rego
package ods.policy

default allow := true

deny[msg] {
    input.ai_confidence > 0.8
    input.test_coverage >= 0      # -1 means coverage was not measured
    input.test_coverage < 0.3
    msg = "AI code with low test coverage"
}
```

Maintaining an open-source project with an AI clause in CONTRIBUTING? The
[Open-Source AI Policy](docs/oss-ai-policy.md) guide and
[`examples/ods-policy-oss-disclosure.rego`](examples/ods-policy-oss-disclosure.rego)
turn "disclose it, test it, own it" into this check.

## Beyond One Pull Request

- **`ods report`** turns the same attribution into a per-repository view over git history (text, JSON, HTML), and **`ods report merge`** combines repositories into an [organization-wide view](docs/org-view.md).
- **`ods attest`** emits an AI-code evidence document as a CycloneDX 1.6 BOM, for audit trails and customer questionnaires ([proposal 001](docs/proposals/001-ai-code-evidence.md)).
- **`ods rules`** prints the analysis rule catalogue, machine-readable.

---

## Tooling

| Tool | Repository |
|------|------------|
| ODS CLI | [open-delivery-spec/cli](https://github.com/open-delivery-spec/cli) |
| GitHub Action | [open-delivery-spec/validate-action](https://github.com/open-delivery-spec/validate-action) |
| Organization report workflow | [open-delivery-spec/.github](https://github.com/open-delivery-spec/.github/blob/main/.github/workflows/org-ai-report.yml) — every repository, one dashboard ([guide](docs/org-view.md)) |
| Examples | [`examples/`](examples/) — policy templates and a [worked walkthrough](examples/walkthrough/) in which Semgrep finds a bug in an AI-assisted change and the policy blocks it |

---

## Design Principles

1. **Zero-config attribution.** AI tools emit `Co-Authored-By` trailers automatically, so ODS attributes AI code with no disclosure forms or manual tagging. It reads signals the tools volunteer — this is attribution, not forensic detection: stripping the trailer evades it, and diff heuristics are only a low-confidence fallback.
2. **Deterministic rules, probabilistic signals.** Quality rules are yes/no. Detection confidence is a signal for policy thresholds, not a verdict.
3. **Tool-agnostic.** Works with GitHub, GitLab, Jenkins, or any CI/CD that can run a binary.
4. **Policy as code.** Enterprise rules written in Rego, version-controlled alongside code.
5. **Prevent, don’t just report.** The policy gate runs the same way locally and in CI (`ods check`), and the built-in analysis also runs as a [pre-commit](https://pre-commit.com) hook (`ods analyze --fail-on high`) before a change is pushed.
6. **Consume AI review, don’t become an AI reviewer.** ODS is the governance layer that turns attribution, static findings, and any AI reviewer's verdict into one auditable "can this merge?" decision — it does not reproduce CodeRabbit/Copilot. See [POSITIONING.md](POSITIONING.md).

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
