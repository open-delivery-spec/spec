# Open Delivery Spec (ODS)

**An open specification for machine-readable delivery governance evidence in the AI era.**

[![ODS L1](https://img.shields.io/badge/ODS-L1%20Structured%20Delivery-blue)](docs/levels.md)

AI is writing more code than ever — [90% of developers use AI daily](https://cloud.google.com/blog/products/devops-sre/dora-2025-report), spending a median of 2 hours per day with AI tools. But delivery governance hasn't caught up. Faster coding doesn't mean safer shipping.

Open Delivery Spec is an early-stage open specification that defines **standardized, machine-parseable schemas** for delivery governance artifacts — so teams can answer questions like "what did AI write?", "who reviewed it?", and "what evidence existed before we deployed?"

> **ODS is early-stage** (2026). The spec defines 9 modules across 4 maturity levels. The MVP — [ODS L1](docs/levels.md) (structured branches, commits, PRs) + AI disclosure + PR review evidence — is the recommended starting point.
>
> **How ODS fits**: SLSA proves how artifacts were built. ODS proves how changes were delivered. See [ODS and SLSA](docs/comparison/slsa.md).
>
> **Why this exists**: See [Threats and Failure Modes](docs/threats-and-failure-modes.md).

## The Problem

AI makes coding faster. Everything after coding gets harder:

| Before Merge | At Merge | After Merge |
|---|---|---|
| Branch naming is ad-hoc | PR descriptions are inconsistent | CI failures lack structured explanation |
| Commit messages are low-quality | AI-generated changes lack review standards | Release readiness is a gut-feel decision |
| | Approval workflows are unclear | Rollback plans are missing |
| | | Production releases lack audit evidence |

## The Solution: Standardized Delivery Artifacts

ODS defines a **JSON Schema** for each delivery artifact. Tools validate artifacts against these schemas. AI agents produce compliant artifacts by default.

```
┌──────────────────────────────────────────────────────┐
│                  OPEN DELIVERY SPEC                  │
│                                                      │
│  Branch     Commit    PR         CI        Release   │
│  Naming ──► Message ─►Desc ──► Failure ──►Readiness  │
│    │          │        │         │           │       │
│    ▼          ▼        ▼         ▼           ▼       │
│  ┌──────────────────────────────────────────────┐    │
│  │         JSON Schema (machine-readable)       │    │
│  └──────────────────────────────────────────────┘    │
│    │          │        │         │           │       │
│    ▼          ▼        ▼         ▼           ▼       │
│  AI Review   Approval   Rollback   Production        │
│  Protocol    Workflow   Plan       Evidence          │
│                                                      │
└──────────────────────────────────────────────────────┘
```

## Specification Modules

> **Maturity**: Modules 01–03 are **Candidate**. 04–09 are **Draft**. See [ODS Levels](docs/levels.md) for the adoption path.

| # | Module | Summary | Stage |
|---|--------|---------|-------|
| 01 | [Branch Naming](spec/01-branch-naming.md) | Standardized, machine-parseable branch names | Candidate |
| 02 | [Commit Message](spec/02-commit-message.md) | AI-attributable, semantically rich commit format | Candidate |
| 03 | [PR Description](spec/03-pr-description.md) | Structured PR body with AI disclosure | Candidate |
| 04 | [AI Change Review](spec/04-ai-change-review.md) | Protocol for reviewing AI-generated changes | Draft |
| 05 | [CI Failure](spec/05-ci-failure.md) | Machine-parseable CI failure reports | Draft |
| 06 | [Release Readiness](spec/06-release-readiness.md) | Evidence-based release gate checklist | Draft |
| 07 | [Approval Workflow](spec/07-approval-workflow.md) | Declarative approval policy format | Draft |
| 08 | [Rollback Plan](spec/08-rollback-plan.md) | Required rollback plan structure | Draft |
| 09 | [Production Release Evidence](spec/09-prod-release-evidence.md) | Audit-ready deployment evidence | Draft |

## Getting Started

### Validate a branch name

```json
{
  "type": "feature",
  "description": "add-oauth-login",
  "ticket": "PROJ-1234"
}
```
→ Validates against [`schemas/branch-naming.json`](schemas/branch-naming.json)

### Write an AI-attributable commit

```
feat(auth): add OAuth login flow

AI-assisted: true
AI-tool: GitHub Copilot
AI-scope: auth module implementation
```
→ Validates against [`schemas/commit-message.json`](schemas/commit-message.json)

### Generate a release readiness report

```json
{
  "version": "v1.4.0",
  "checks": {
    "ci_passed": true,
    "security_scan_clean": true,
    "rollback_plan_exists": true,
    "required_approvals": 2,
    "actual_approvals": 2
  },
  "ready": true
}
```
→ Validates against [`schemas/release-readiness.json`](schemas/release-readiness.json)

## Tooling

| Tool | Repository | Description |
|------|-----------|-------------|
| ODS CLI | [open-delivery-spec/cli](https://github.com/open-delivery-spec/cli) | Reference CLI for validation and generation |
| GitHub Action | [open-delivery-spec/github-action](https://github.com/open-delivery-spec/github-action) | Automated compliance checks in CI |

## Design Principles

1. **Machine-first, human-readable.** Every artifact has a JSON Schema. Every schema has human docs.
2. **AI-native.** Schemas include fields for AI attribution, scope, and confidence.
3. **Composable.** Use one module or all. Each schema is independently useful.
4. **Tool-agnostic.** Works with any CI/CD, any AI coding tool, any VCS.
5. **Audit-ready.** Every artifact carries evidence for compliance and security review.

## Current Scope & Vision

ODS today provides:
- **9 JSON Schemas** defining the structure of every delivery artifact
- **Reference CLI** (`ods`) for validation and generation
- **GitHub Action** for automated CI compliance checks

We're building toward the vision of "OpenAPI for delivery governance" — a complete ecosystem including dashboards, code generators, multi-platform CI integrations, and compliance reporting. See [ROADMAP.md](ROADMAP.md) for what's next.

## Inspiration

- [Conventional Commits](https://www.conventionalcommits.org)
- [Conventional Branch](https://conventional-branch.github.io)
- [OpenAPI Specification](https://www.openapis.org)
- [DORA 2025 Report](https://cloud.google.com/blog/products/devops-sre/dora-2025-report)

## ODS Artifacts — Where Do They Live?

ODS supports two modes of operation:

### Mode 1 — Lightweight Validation (CI-native)

Validate artifacts directly from CI context. No files written to the repository. Ideal for branch naming, commit message, and PR description checks.

```yaml
- uses: open-delivery-spec/github-action@v1
  with:
    check: branch-naming
    branch_name: ${{ github.head_ref }}
```

### Mode 2 — Evidence Artifacts (audit trail)

Generate structured JSON evidence files and store them alongside the release. Evidence artifacts live in a `.ods/` directory at the repository root.

```
.ods/
  releases/
    v1.4.0/
      branch-meta.json
      pr-description.json
      ai-review.json
      release-readiness.json
      rollback-plan.json
      evidence-bundle.json
```

**Conventions:**
- `.ods/` is the canonical location for ODS-generated artifacts.
- Each release gets a subdirectory named by its version tag.
- Evidence bundles are immutable after generation (hash-verified).
- Add `.ods/` to `.gitignore` if artifacts are generated in CI; commit them if you want in-repo audit trail.

## License

[Apache License 2.0](LICENSE)
