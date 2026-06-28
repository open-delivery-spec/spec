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

## Current Status (June 2026)

> **Strategy**: Zero-config AI code quality gate. Claude Code, GitHub Copilot, and Cursor auto-emit `Co-Authored-By` trailers — ODS reads them in CI to attribute, analyze, score, and enforce policy on every PR.

### Core Pipeline

| Command | What it does | Status |
|---------|-------------|--------|
| `ods detect` | Multi-source AI code detection | ✅ Stable |
| `ods analyze` | AI code quality analysis (5 rule categories) | ✅ Stable |
| `ods score` | 5-dimension technical debt scoring | ✅ Stable |
| `ods check` | OPA Rego policy enforcement | ✅ Stable |
| `ods hook install` | Pre-commit / prepare-commit-msg / pre-push hooks | ✅ Stable |
| `ods init` | Scaffold CI workflow + `.ods/policy.rego` | ✅ Stable |

### Detection Signals

| Signal | Source | Confidence | Status |
|--------|--------|-----------|--------|
| `Co-Authored-By` commit trailers | Auto-emitted by Claude Code, GitHub Copilot, Cursor — **primary signal** | 90% | ✅ Stable |
| ODS trailer fields | `AI-assisted: true`, `AI-tool: name` — supplemental, optional | 85% | ✅ Stable |
| PR body AI disclosure | Checkbox and section parsing | 75% | ✅ Stable |
| Branch name prefix | `ai-*` convention | 35–50% | ✅ Stable |
| Diff heuristics | Comment ratio, verbose naming, error patterns | 40% | ✅ Candidate |

### Analysis Rules

| Rule | Severity | Status |
|------|----------|---------|
| `ai-redundant-error-handling` | medium | ✅ Stable |
| `ai-over-commenting` | medium-high | ✅ Stable |
| `ai-missing-edge-case` | low | ✅ Stable |
| `ai-unsafe-deserialization` | high | ✅ Stable |
| `ai-inconsistent-pattern` | medium-low | ✅ Candidate |

### Scoring Dimensions

| Dimension | Weight | Status |
|-----------|--------|--------|
| AI code ratio | 3.0 | ✅ Stable |
| Defect density | 2.0 | ✅ Stable |
| Critical issues | 1.5 each | ✅ Stable |
| Test coverage gap | 1.0 | ✅ Candidate |
| Code duplication rate | 1.0 | 🧪 Experimental |

---

## Deprecated Modules (v1.0.0)

The original 01–09 module system has been **deprecated and removed** as of June 2026 — from the CLI, the spec documents, and the JSON Schemas. Their definitions remain available in git history. Tooling no longer supports them.

| Module | Deprecation Date |
|--------|------------------|
| 01 — Branch Naming | June 2026 |
| 02 — Commit Message | June 2026 |
| 03 — PR Description | June 2026 |
| 04 — AI Change Review | June 2026 |
| 05 — CI Failure | June 2026 |
| 06 — Release Readiness | June 2026 |
| 07 — Approval Workflow | June 2026 |
| 08 — Rollback Plan | June 2026 |
| 09 — Production Evidence | June 2026 |

---

## Milestones

### M1 — AI Detection & Analysis ✅

**Status: Complete (June 2026)**

- [x] CLI: `ods detect` with multi-source AI detection (Co-Authored-By trailers, ODS trailer fields, PR body, branch prefix, diff heuristics)
- [x] CLI: `ods analyze` with 5 rule categories for AI code quality defects
- [x] CLI: `ods score` with 5-dimension weighted technical debt scoring
- [x] CLI: `ods check` with OPA Rego policy engine and policy tests
- [x] CLI: `ods hook install` and `ods init` for pre-commit governance
- [x] Removal of legacy delivery governance code (modules 01–09)

### M2 — CI Integration & Enterprise Surface (Q3 2026)

**Goal:** Make ODS seamless in CI and self-service for enterprise teams.

- [x] Adoption signal: 3+ ODS-org repos running the gate (dogfooding completed June 2026)
- [ ] SARIF output for GitHub Code Scanning integration
- [ ] Multi-platform CI examples: GitLab CI, Bitbucket Pipelines, Jenkins (copy-paste templates)
- [ ] `ods init` expanded: one-command scaffolding for any CI platform
- [ ] Policy library: pre-built Rego policies for common enterprise requirements (regulated, fintech, healthcare)
- [ ] `ods report` command: aggregate reports across repos / teams

### M3 — Advanced Detection & Scoring (Q3–Q4 2026)

**Goal:** Deepen AI code analysis and expand detection surface.

> **Next focus**: Deepen the analysis rules and scoring accuracy. Build adoption outside the ODS org.

- [ ] Additional analysis rules (hallucinated API detection, AI-generated config drift)
- [ ] Language-specific analysis (Go, Python, TypeScript, Java in first wave)
- [ ] `ods score` with repo-level trend tracking (PR-over-PR technical debt trajectory)
- [ ] AI model attribution: detect which AI tool generated the code (Copilot vs. Cursor vs. Claude Code)
- [ ] Test coverage gap analysis from actual coverage data (not just heuristics)

### M4 — Compliance & Audit Trail (Q4 2026)

**Goal:** Make ODS an auditable evidence system for AI governance.

- [ ] Immutable audit log: every detection, analysis, and enforcement decision recorded
- [ ] Compliance mapping: ODS checks → NIST AI RMF / EU AI Act controls
- [ ] SLSA integration: ODS evidence as input to SLSA provenance
- [ ] Signed attestations for AI code provenance
- [ ] At least one scoring dimension promoted from Experimental to Stable

### M5 — Community & Governance (Q4 2026)

**Goal:** Formal governance and community adoption.

- [ ] Formal governance model operating (RFC process live)
- [ ] 3+ external adopters listed in ADOPTERS.md
- [ ] Community-contributed analysis rules and Rego policies
- [ ] Experimental checks promoted based on community demand

---

## Non-Goals (for now)

- A hosted dashboard / SaaS offering — focus is on the spec + CLI + CI integration
- Deep integrations with every CI platform — start with GitHub Actions, expand with copy-paste examples
- Runtime monitoring / observability standards — out of scope; ODS covers pre-merge and CI gates
- Replacing any existing tool (Scorecard, SLSA, linters) — ODS focuses on AI-specific code quality gaps

## How to Influence

- Open a [GitHub Issue](https://github.com/open-delivery-spec/spec/issues) with a use case or proposal
- See [CONTRIBUTING.md](CONTRIBUTING.md) for the full process
