# Roadmap

This document outlines the planned evolution of Open Delivery Spec. Priorities shift based on community feedback and real-world adoption.

## Status Legend

| Status | Meaning |
|--------|-------|
| **Experimental** | Direction-setting. Not recommended for production adoption. Breaking changes expected. |
| **Candidate** | Stable enough for tooling. Minor additions only. |
| **Stable** | Production-ready. Semver applies. |
| **Deprecated** | Being retired or replaced. |

---

## Current Status (September 2026)

> **Strategy**: Zero-config governance and visibility for AI-assisted code. Claude Code, GitHub Copilot, and Cursor auto-emit `Co-Authored-By` trailers — ODS reads them in CI to attribute AI-assisted code, surface how much of delivery it is, route review attention, and enforce policy on every PR.

### Core Pipeline

| Command | What it does | Status |
|---------|-------------|--------|
| `ods detect` | Multi-source AI code detection | ✅ Stable |
| `ods analyze` | AI code quality analysis (5 rules) | ✅ Stable |
| `ods score` | 5-dimension technical debt scoring | ✅ Stable |
| `ods check` | OPA Rego policy enforcement | ✅ Stable |
| `ods init` | Scaffold CI workflow + `.ods/policy.rego` | ✅ Stable |
| `ods report` | AI attribution report (text / JSON / HTML dashboard); `ods report merge` for an organization | ✅ Candidate |
| `ods attest` | AI-code evidence document (CycloneDX 1.6), [proposal 001](docs/proposals/001-ai-code-evidence.md) phase 1 | 🧪 Experimental |
| `ods rules` | The analysis rule catalogue, machine-readable | ✅ Stable |

### Detection Signals

| Signal | Source | Confidence | Status |
|--------|--------|-----------|--------|
| `Co-Authored-By` commit trailers | Auto-emitted by Claude Code, GitHub Copilot, Cursor — **primary signal** | 90% | ✅ Stable |
| `Assisted-by` commit trailers | Linux kernel convention, `Assisted-by: AGENT:MODEL` | 90% | ✅ Stable |
| ODS trailer fields | `AI-assisted: true`, `AI-generated: true`, `AI-tool: name` — supplemental, optional | 90% | ✅ Stable |
| git-ai authorship notes | Line-level attribution recorded by git-ai under `refs/notes/ai` | 95% | ✅ Candidate |
| PR body AI disclosure | Ticked disclosure checkbox (85%) or disclosure text (80%) | 80–85% | ✅ Stable |
| Branch name prefix | `claude/`, `copilot/`, `cursor/`, `codeium/` (60%); `ai-` (50%); an `ai-` segment further down (35%) | 35–60% | ✅ Stable |
| Diff heuristics | Comment ratio, verbose naming, error patterns (per-file score) | ≥ 40% | ✅ Candidate |

### Analysis Rules

| Rule | Default severity | Status |
|------|------------------|---------|
| `ai-redundant-error-handling` | info | ✅ Stable |
| `ai-over-commenting` | info | ✅ Stable |
| `ai-unsafe-deserialization` | high | ✅ Stable |
| `ai-inconsistent-pattern` | medium | ✅ Candidate |
| `ai-hallucinated-api` | medium | ✅ Candidate |

### Scoring Dimensions

The technical-debt delta is `base_quality_debt × ai_risk_multiplier`. Quality
signals form the base debt; the AI ratio only amplifies it — **quantity of AI
code alone never creates debt** (a clean, fully-AI change scores ~0).

| Dimension | Role in the delta | Status |
|-----------|-------------------|--------|
| Critical / high issues | `+1.5` each — base debt | ✅ Stable |
| Test coverage gap | `+1.0 × (1 − coverage)` — skipped when coverage is unmeasured (−1) | ✅ Candidate |
| Code duplication rate | `+1.0 × rate` — base debt | 🧪 Experimental |
| AI code ratio | `×(1.0–1.5)` risk multiplier on the base debt | ✅ Stable |
| Defect density | Informational only — a per-KLOC rate, **not** part of the delta | ✅ Stable |

### Merge-Confidence Signals

Deterministic, diff-scoped facts fed to the policy gate — advisory by default
(they route review attention), attribution raises the bar for AI-authored
changes, and deny stays opt-in.

| Signal | What it checks | Status |
|--------|----------------|--------|
| `added_source_without_tests` / `tests_touched` | Source changed without a test added or updated | ✅ Stable |
| `risky_paths` | Diff touches CI config, dependency manifests/lockfiles, auth/crypto/security | ✅ Stable |
| Diff shape (`files_changed`, `net_added_lines`, …) | Wide-but-shallow change detection | ✅ Stable |
| `patch_coverage` | Coverage of the diff's *added* lines (Go / LCOV / Cobertura) | ✅ Candidate |
| `ai_reviews` (`--ai-review`) | AI code-reviewer verdicts — advisory, never auto-deny | ✅ Candidate |

---

## What was removed

The 1.0.0 module system (branch naming, commit message, PR description, review,
CI failure, release readiness, approval, rollback, production evidence) was
removed in 2.0.0 (June 2026) from the CLI, the spec and the schemas; the
definitions remain in git history. See [CHANGELOG.md](CHANGELOG.md).

---

## Milestones

### M1 — AI Detection & Analysis ✅

**Status: Complete (June 2026)**

- [x] CLI: `ods detect` with multi-source AI detection (Co-Authored-By trailers, ODS trailer fields, PR body, branch prefix, diff heuristics)
- [x] CLI: `ods analyze` with 5 rule categories for AI code quality defects
- [x] CLI: `ods score` with 5-dimension weighted technical debt scoring
- [x] CLI: `ods check` with OPA Rego policy engine and policy tests
- [x] CLI: `ods init` for scaffolding; a pre-commit-framework hook for local runs
- [x] Removal of legacy delivery governance code (modules 01–09)

### M2 — CI Integration & Enterprise Surface (Q3 2026)

**Goal:** Make ODS seamless in CI and self-service for enterprise teams.

- [x] Adoption signal: 3+ ODS-org repos running the gate (dogfooding completed June 2026)
- [ ] SARIF output for GitHub Code Scanning integration
- [ ] Multi-platform CI examples: GitLab CI, Bitbucket Pipelines, Jenkins (copy-paste templates)
- [ ] `ods init` expanded: one-command scaffolding for any CI platform
- [ ] Policy library: pre-built Rego policies for common enterprise requirements (regulated, fintech, healthcare)
- [x] `ods report` command: per-repo AI attribution report (text / JSON / HTML dashboard)
- [x] Aggregate reporting across repos: `ods report merge` + the `org-ai-report` reusable workflow (dashboard, job summary, GitHub Pages); per-team grouping pending

### M3 — Advanced Detection & Scoring (Q3–Q4 2026)

**Goal:** Deepen AI code analysis and expand detection surface.

> **Next focus**: Deepen the analysis rules and scoring accuracy. Build adoption outside the ODS org.

- [x] Hallucinated / deprecated API detection rule (`ai-hallucinated-api`)
- [ ] AI-generated config drift detection
- [ ] Language-specific analysis (Go, Python, TypeScript, Java in first wave)
- [ ] `ods score` with repo-level trend tracking (PR-over-PR technical debt trajectory)
- [x] AI tool attribution: identify which AI tool generated the code (from trailers; per-tool breakdown in `ods report`)
- [x] Test coverage gap analysis from actual coverage data — real coverage parsing (Go / LCOV / Cobertura / NYC), plus diff-scoped `patch_coverage`
- [x] Deterministic merge-confidence signals (added-source-without-tests, risky paths, diff shape, patch coverage) with `review_tier` routing

### M4 — Compliance & Audit Trail (Q4 2026)

**Goal:** Make ODS an auditable evidence system for AI governance.

- [ ] Immutable audit log: every detection, analysis, and enforcement decision recorded
- [x] Evidence document: `ods attest` emits CycloneDX 1.6 ([proposal 001](docs/proposals/001-ai-code-evidence.md), phase 1)
- [ ] Signed evidence: GitHub artifact attestations / sigstore in validate-action (proposal 001, phase 2)
- [ ] Release-level evidence: `ods attest --range` (proposal 001, phase 3)
- [ ] Compliance mapping: the ODS-R1…R6 requirements → SOC 2 change management, ISO 42001, NIST AI RMF; the EU AI Act as a reference for providers of high-risk systems, not a driver
- [ ] SLSA integration: ODS evidence as input to SLSA provenance
- [ ] At least one scoring dimension promoted from Experimental to Stable

### M5 — Community & Governance (Q4 2026)

**Goal:** Formal governance and community adoption.

- [ ] Formal governance model operating (RFC process live)
- [ ] 3+ external adopters listed in ADOPTERS.md
- [ ] Community-contributed analysis rules and Rego policies
- [ ] Experimental checks promoted based on community demand

---

## Non-Goals

The single most important boundary — **ODS consumes AI review, it does not try
to be an AI reviewer** — is argued in full in [POSITIONING.md](POSITIONING.md).
In short, ODS will **not** build its own LLM code-review engine (it ingests any
reviewer's output via `review-verdict/v1`), will not restructure into an
agent/skill framework, and does not aim to remove humans from consequential
merges — only to route their attention. This is a hard boundary, not a "for
now."

The following are "for now" — deferred, not ruled out:

- A hosted dashboard / SaaS offering — focus is on the spec + CLI + CI integration
- Deep integrations with every CI platform — start with GitHub Actions, expand with copy-paste examples
- Runtime monitoring / observability standards — out of scope; ODS covers pre-merge and CI gates
- Replacing any existing tool (Scorecard, SLSA, linters) — ODS focuses on AI-specific code quality gaps

## How to Influence

- Open a [GitHub Issue](https://github.com/open-delivery-spec/spec/issues) with a use case or proposal
- See [CONTRIBUTING.md](CONTRIBUTING.md) for the full process
