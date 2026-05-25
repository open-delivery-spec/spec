# Open Delivery Spec (ODS)

**Machine-readable delivery governance evidence for the AI era.**

[![CI](https://github.com/open-delivery-spec/spec/actions/workflows/ci.yml/badge.svg)](https://github.com/open-delivery-spec/spec/actions/workflows/ci.yml)
[![ODS L1](https://img.shields.io/badge/ODS-L1%20Structured%20Delivery-blue)](docs/levels.md)

AI now participates in everyday software delivery. Teams still need to answer basic governance questions before a change ships:

- What did AI generate or substantially modify?
- Which human reviewed that work?
- What evidence existed before merge or release?
- Can CI/CD tools verify those answers automatically?

Open Delivery Spec defines standardized, machine-parseable artifacts for those answers. Think of it as a delivery-governance layer that starts small with branch, commit, and PR checks, then grows into review and release evidence as teams need it.

> [!NOTE]
> **ODS is early-stage** (2026). The recommended starting point is **ODS L1 + AI Disclosure**: structured branch names, Conventional-Commit-compatible messages, PR descriptions with explicit AI disclosure, and CI validation through the ODS GitHub Action.
>
> Modules 04-09 are intentionally draft. They describe the direction for AI review, CI failure records, release readiness, rollback plans, approval policies, and production evidence, but they are not the first adoption path.
>
> **How ODS fits**: SLSA proves how artifacts were built. ODS proves how changes were delivered. See [ODS and SLSA](docs/comparison/slsa.md).

## Why This Exists

AI makes coding faster. Everything after coding gets harder:

| Question | Why it matters |
|---|---|
| Was this code AI-assisted? | Reviewers need to know where to apply extra scrutiny. |
| Was AI-generated code reviewed by a human? | Teams need accountability, not just fast diffs. |
| Did the PR include the expected delivery metadata? | CI should catch missing context before merge. |
| What evidence existed before release? | Audit and incident review need structured records. |

## Start With ODS L1

ODS L1 is the minimum useful checkpoint:

| Module | What it checks | Status |
|---|---|---|
| 01 | [Branch Naming](spec/01-branch-naming.md) uses `<type>/<description>` | Candidate |
| 02 | [Commit Message](spec/02-commit-message.md) uses Conventional Commits plus optional AI attribution | Candidate |
| 03 | [PR Description](spec/03-pr-description.md) includes summary, type, AI disclosure, changes, testing, and checklist sections | Candidate |

Run the CLI locally:

```bash
go install github.com/open-delivery-spec/cli/cmd/ods@latest

ods validate branch feature/add-oauth-login
ods validate commit --file commit-msg.txt
ods validate pr --file PR_BODY.md
```

Add the GitHub Action to PRs:

```yaml
name: ODS L1
on:
  pull_request:
    types: [opened, edited, synchronize, reopened]

jobs:
  ods:
    runs-on: ubuntu-latest
    steps:
      - uses: open-delivery-spec/validate-action@v1
        with:
          check: all
          branch_name: ${{ github.head_ref }}
          pr_body: ${{ github.event.pull_request.body }}
          strict: "true"
```

For commit-message checks, pass the commit body from your workflow context or a preceding checkout/log step:

```yaml
- uses: open-delivery-spec/validate-action@v1
  with:
    check: commit-message
    commit_message: ${{ github.event.head_commit.message }}
```

## AI Disclosure Example

Commit footer:

```text
feat(auth): add OAuth login flow

AI-assisted: true
AI-tool: GitHub Copilot
AI-scope: auth module implementation
AI-review: pending
```

PR section:

```markdown
## AI Disclosure
- [x] This PR contains AI-generated code
- AI Tool: GitHub Copilot
- AI Scope: Provider abstraction, token exchange, session management
- Human Review: Verified OAuth flow, redirect validation, and token handling
```

## Full Module Map

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

## Tooling Status

| Tool | Repository | Current production surface |
|------|------------|----------------------------|
| ODS CLI | [open-delivery-spec/cli](https://github.com/open-delivery-spec/cli) | `ods validate branch`, `commit`, `pr` |
| GitHub Action | [open-delivery-spec/validate-action](https://github.com/open-delivery-spec/validate-action) | `branch-naming`, `commit-message`, `pr-description`, `all` |

Draft modules can still be explored through schemas and examples, but they should not be treated as production gates yet. See [ROADMAP.md](ROADMAP.md) for the maturity path.

## ODS Artifacts

ODS supports two modes of operation:

### Lightweight Validation

Validate delivery metadata directly from CI context. No files are written to the repository. This is the recommended L1 adoption mode.

### Evidence Artifacts

As draft release-governance modules mature, teams can store structured records in `.ods/`. See [`.ods/` Convention](docs/ods-artifacts.md) for the full layout.

```text
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

## Design Principles

1. **Machine-first, human-readable.** Every artifact has a JSON Schema. Every schema has human docs.
2. **AI-native.** Delivery metadata records AI attribution, scope, and review state.
3. **Composable.** Start with one check or all L1 checks.
4. **Tool-agnostic.** Works with any CI/CD, AI coding tool, or VCS.
5. **Audit-ready over time.** L1 creates structure now; later levels add release evidence.

## Inspiration

- [Conventional Commits](https://www.conventionalcommits.org)
- [Conventional Branch](https://conventional-branch.github.io)
- [OpenAPI Specification](https://www.openapis.org)
- [DORA 2025 Report](https://cloud.google.com/blog/products/devops-sre/dora-2025-report)

## License

[Apache License 2.0](LICENSE)
