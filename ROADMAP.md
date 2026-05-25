# Roadmap

This document outlines the planned evolution of Open Delivery Spec. Priorities shift based on community feedback and real-world adoption.

## Status Legend

| Status | Meaning |
|--------|---------|
| **Draft** | Scope and schema still forming. Breaking changes expected. |
| **Candidate** | Schema stable enough for tooling. Minor additions only. |
| **Stable** | Production-ready. Semver applies. |
| **Deprecated** | Being retired or replaced. |

---

## Current Status (May 2026)

| Module | Status | CLI Support |
|--------|--------|-------------|
| 01 — Branch Naming | 🟡 Candidate | ✅ validate |
| 02 — Commit Message | 🟡 Candidate | ✅ validate |
| 03 — PR Description | 🟡 Candidate | ✅ validate (section checks) |
| 04 — AI Change Review | 🔵 Draft | ⬜ generate only |
| 05 — CI Failure | 🔵 Draft | ⬜ |
| 06 — Release Readiness | 🔵 Draft | ⬜ |
| 07 — Approval Workflow | 🔵 Draft | ⬜ |
| 08 — Rollback Plan | 🔵 Draft | ⬜ |
| 09 — Production Evidence | 🔵 Draft | ⬜ |

---

## Milestones

### M1 — First Trusted Checkpoint (Q3 2026)

**Goal:** Prove the loop works end-to-end for the simplest modules.

- [x] CLI: `ods validate branch|commit|pr` passes against real projects
- [x] GitHub Action runs reliably with Go-based CLI
- [x] One end-to-end example repo (branch → commit → PR → passing Action)
- [x] `.ods/` artifact directory convention documented

### M2 — CI Failure & AI Review (Q4 2026)

**Goal:** Demonstrate the AI-native value proposition.

- [ ] Module 05 (CI Failure) promoted to Candidate
- [ ] CLI: `ods ci parse` with hallucination detection
- [ ] Module 04 (AI Change Review) promoted to Candidate
- [ ] CLI: `ods review generate` producing L1/L2/L3 records

### M3 — Release Governance (Q1 2027)

**Goal:** Full release readiness evidence chain.

- [ ] Module 06 (Release Readiness) promoted to Candidate
- [ ] Modules 08 & 09 connected into release evidence chain
- [ ] CLI: `ods release check` and `ods evidence generate`
- [ ] Multi-platform CI examples (GitLab CI, Bitbucket Pipelines)

### M4 — Stable Core (Q2 2027)

**Goal:** First stable release of the core modules.

- [ ] Modules 01-03 promoted to Stable (1.0.0)
- [ ] Modules 04-06 promoted to Candidate
- [ ] Formal governance model operating (RFC process live)
- [ ] 3+ external adopters listed in ADOPTERS.md

---

## Non-Goals (for now)

- A hosted dashboard / SaaS offering — focus is on the spec + CLI + CI integration
- Deep integrations with every CI platform — start with GitHub Actions, expand later
- Runtime monitoring / observability standards — out of scope; ODS covers pre-deployment and deployment artifacts

## How to Influence

- Open a [GitHub Issue](https://github.com/open-delivery-spec/spec/issues) with a use case or proposal
- See [CONTRIBUTING.md](CONTRIBUTING.md) for the full process
- For new module proposals, use the [Module Proposal template](.github/ISSUE_TEMPLATE/module-proposal.md)
