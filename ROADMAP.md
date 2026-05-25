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

## Current Status (May 2026)

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

---

## Milestones

### M1 — First Trusted Checkpoint (Q3 2026)

**Goal:** Prove the loop works end-to-end for the simplest modules.

- [x] CLI: `ods validate branch|commit|pr` passes against real projects
- [x] GitHub Action runs reliably with Go-based CLI (validate-action@v1 published)
- [x] End-to-end example with workflow files (see `examples/end-to-end/`)
- [x] `.ods/` artifact directory convention documented

### M2 — AI-Native Tooling (Q4 2026)

**Goal:** Build the CLI tools for AI review and CI failure analysis. Keep modules experimental pending adoption signal.

- [x] CLI: `ods ci parse` with hallucination detection
- [x] CLI: `ods review generate` producing L1/L2/L3 records
- [x] JSON Schemas for modules 04-09 published
- [ ] Adoption signal: 2+ teams using ODS L1 with positive feedback

### M3 — L1 Stable + Early Evidence (Q1 2027)

**Goal:** Promote ODS L1 to Stable. Begin evidence module maturation based on real-world feedback.

- [ ] Modules 01-03 promoted to Stable (1.0.0)
- [ ] At least one evidence module (04-06) promoted to Candidate based on adopter needs
- [ ] Multi-platform CI examples (GitLab CI, Bitbucket Pipelines)

### M4 — Governance Model (Q2 2027)

**Goal:** Formal governance and community adoption.

- [ ] Formal governance model operating (RFC process live)
- [ ] 3+ external adopters listed in ADOPTERS.md
- [ ] Remaining experimental modules promoted based on community demand

---

## Non-Goals (for now)

- A hosted dashboard / SaaS offering — focus is on the spec + CLI + CI integration
- Deep integrations with every CI platform — start with GitHub Actions, expand later
- Runtime monitoring / observability standards — out of scope; ODS covers pre-deployment and deployment artifacts

## How to Influence

- Open a [GitHub Issue](https://github.com/open-delivery-spec/spec/issues) with a use case or proposal
- See [CONTRIBUTING.md](CONTRIBUTING.md) for the full process
- For new module proposals, use the [Module Proposal template](.github/ISSUE_TEMPLATE/module-proposal.md)
