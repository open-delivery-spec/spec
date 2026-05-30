# Roadmap

This document outlines the planned evolution of Open Delivery Spec. Priorities shift based on community feedback and real-world adoption.

## Status Legend

| Status | Meaning |
|--------|---------|
| **Experimental** | Direction-setting. Not recommended for production adoption. Breaking changes expected. |
| **Draft** | Scope and schema still forming. Breaking changes expected. |
| **Candidate** | Schema stable enough for tooling. Minor additions only. |
| **Stable** | Production-ready. Semver applies. |
| **Deprecated** | Being retired or replaced. |

---

## Current Status (June 2026)

> **Strategy**: Narrow focus on ODS L1 + AI Disclosure as the primary adoption path. Modules 04-09 are direction-setting experiments. The wedge is: make AI-generated PRs easier to review, not to prove a full governance framework.

| Module | Status | CLI Support |
|--------|--------|-------------|
| 01 — Branch Naming | 🟡 Candidate | ✅ validate |
| 02 — Commit Message | 🟡 Candidate | ✅ validate |
| 03 — PR Description | 🟡 Candidate | ✅ validate (section checks) |
| 04 — AI Change Review | 🧪 Experimental | ✅ generate + validate |
| 05 — CI Failure | 🧪 Experimental | ✅ parse + explain + fix-suggestions |
| 06 — Release Readiness | 🧪 Experimental | ⬜ validate schema only |
| 07 — Approval Workflow | 🧪 Experimental | ⬜ validate schema only |
| 08 — Rollback Plan | 🧪 Experimental | ⬜ validate schema only |
| 09 — Production Evidence | 🧪 Experimental | ⬜ validate schema only |

### Enterprise Policy & Compliance Tooling

These capabilities are now production-ready and run through the CLI and GitHub Action:

| Capability | Status |
|--------|--------|
| `.ods.yaml` enterprise policy with profiles (`oss` / `enterprise` / `regulated`) | ✅ Production |
| HTML/JSON/SVG/Markdown compliance report with scores and fix suggestions | ✅ Production |
| PR bot comment with copy-paste fix templates on failure | ✅ Production |
| AI review record generation (L1/L2/L3) with reviewer attestation | ✅ Production |
| `ods review validate` against AI Change Review schema | ✅ Production |

---

## Milestones

### M1 — First Trusted Checkpoint ✅

**Status: Complete (May 2026)**

- [x] CLI: `ods validate branch|commit|pr` passes against real projects
- [x] GitHub Action runs reliably with Go-based CLI (validate-action@v1 published)
- [x] End-to-end example with workflow files (see `examples/end-to-end/`)
- [x] `.ods/` artifact directory convention documented

### M2 — AI-Native Tooling ✅

**Status: Complete (May 2026)**

- [x] CLI: `ods ci parse` with hallucination detection
- [x] CLI: `ods review generate` producing L1/L2/L3 records
- [x] JSON Schemas for modules 04-09 published
- [x] Enterprise policy system: `.ods.yaml` with profiles, severity maps, configurable rules
- [x] Compliance report: `ods report` outputting HTML, JSON, SVG badge, Markdown with fix suggestions
- [x] PR bot comments with copy-paste fix templates on validation failure
- [ ] Adoption signal: 2+ teams using ODS L1 with positive feedback

### M3 — Enterprise Adoption Surface (Q3 2026)

**Goal:** Reduce friction for enterprise teams adopting ODS. Make the onboarding experience self-service.

- [ ] `ods init` command: one-command scaffolding of `.github/pull_request_template.md`, `.github/workflows/ods.yml`, `.ods.yaml`
- [ ] Adoption mode in policy: `mode: observe | warn | enforce` for progressive roll-out
- [ ] Multi-platform CI examples: GitLab CI, Bitbucket Pipelines, Jenkins (copy-paste templates)
- [ ] Agent instructions: `AGENTS.md` / `.claude.md` / Copilot instructions for ODS-compliant branch, commit, and PR creation
- [ ] Modules 01-03 promoted to Stable (1.0.0)

### M4 — Supply Chain & Compliance Bridge (Q3–Q4 2026)

**Goal:** Position ODS as the delivery-governance layer that complements SLSA and maps to AI regulations.

- [ ] SLSA evidence bridge: JSON mapping from ODS PR evidence → SLSA provenance link and guidance doc
- [ ] Control mapping doc: ODS fields → NIST AI RMF / EU AI Act / internal audit controls (traceability, human oversight, AI disclosure)
- [ ] At least one evidence module (04-06) promoted to Candidate based on adopter needs
- [ ] `ods-ai-review.json` artifact with AI tool, AI scope, human reviewer, review checklist, risk level

### M5 — Community & Governance (Q4 2026)

**Goal:** Formal governance and community adoption.

- [ ] Formal governance model operating (RFC process live)
- [ ] 3+ external adopters listed in ADOPTERS.md
- [ ] Remaining experimental modules promoted based on community demand

---

## Non-Goals (for now)

- A hosted dashboard / SaaS offering — focus is on the spec + CLI + CI integration
- Deep integrations with every CI platform — start with GitHub Actions, expand with copy-paste examples
- Runtime monitoring / observability standards — out of scope; ODS covers pre-deployment and deployment artifacts
- Replacing SLSA — ODS complements SLSA (delivery governance layer before build provenance layer)

## How to Influence

- Open a [GitHub Issue](https://github.com/open-delivery-spec/spec/issues) with a use case or proposal
- See [CONTRIBUTING.md](CONTRIBUTING.md) for the full process
- For new module proposals, use the [Module Proposal template](.github/ISSUE_TEMPLATE/module-proposal.md)
