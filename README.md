# Open Delivery Spec (ODS)

**A lightweight, machine-readable standard for AI-aware pull request and delivery metadata.**

[![CI](https://github.com/open-delivery-spec/spec/actions/workflows/ci.yml/badge.svg)](https://github.com/open-delivery-spec/spec/actions/workflows/ci.yml)
[![ODS L1](https://img.shields.io/badge/ODS-L1%20Structured%20Delivery-blue)](docs/levels.md)

> **ODS does not prove the code is correct. It proves the delivery process contains the minimum structured evidence needed for humans and machines to review the change responsibly.**

AI makes coding faster. Everything after coding — review, verification, audit — gets harder. Teams need structured answers to basic delivery governance questions:

- What did AI generate or substantially modify?
- Which human reviewed that work?
- What evidence existed before merge?
- Can CI/CD tools verify those answers automatically?

ODS defines a small set of machine-readable metadata conventions — starting with branch names, commit messages, and PR descriptions — that CI tools and AI agents can validate before merge.

> [!NOTE]
> **The recommended starting point is ODS L1 + AI Disclosure**: structured branch names, Conventional-Commit-compatible messages, PR descriptions with explicit AI disclosure, and CI validation through the ODS GitHub Action. This takes ~5 minutes to adopt.
>
> **How ODS fits**: SLSA proves how artifacts were built. ODS proves how changes were delivered — the delivery-governance layer before the build-provenance layer. See [ODS and SLSA](docs/comparison/slsa.md).
>
> Modules 04-09 are experimental. They describe the direction for AI review records, CI failure reports, release readiness, and production evidence, but they are not the recommended adoption path today.

## Why This Exists

AI makes coding faster. Everything after coding gets harder:

| Question | Why it matters |
|---|---|
| Was this code AI-assisted? | Reviewers need to know where to apply extra scrutiny. |
| Was AI-generated code reviewed by a human? | Teams need accountability, not just fast diffs. |
| Did the PR include the expected delivery metadata? | CI should catch missing context before merge. |
| What evidence existed before release? | Audit and incident review need structured records. |

These problems are real and documented: [Threats & Failure Modes](docs/threats-and-failure-modes.md).

## Before / After

**Before ODS — a typical AI-assisted PR:**

```
Title: fix stuff
Branch: fix-bug
PR body: (empty)

Reviewer questions:
  - "What does this fix?"
  - "Which part did AI write?"
  - "Was this tested?"
  - "What's the rollback plan?"
```

**After ODS L1 + AI Disclosure:**

```
Title: fix(auth): handle expired OAuth state parameter

Branch: bugfix/expired-oauth-state

PR body:
  ## Summary
  Fixes race condition where OAuth state parameter expires before callback.

  ## AI Disclosure
  - [x] This PR contains AI-generated code
  - AI Tool: GitHub Copilot
  - AI Scope: Token refresh logic, state validation
  - Human Review: Verified OAuth spec compliance, PKCE flow, redirect URI handling

  ## Changes
  - Added state expiry check in callback handler
  - Added token refresh fallback

  ## Testing
  - [x] Unit tests for state expiry
  - [x] Integration test for full OAuth flow

  ## Risk Assessment
  - Deployment risk: Medium
  - Rollback plan: Feature-flag gated

  Reviewer: 0 clarification questions needed.
```

This is the core value proposition: structured metadata that answers reviewer questions before they need to ask. See the [PR Template](examples/ods-pr-template.md) for a copy-paste version.

## Start With ODS L1

ODS L1 is the minimum useful checkpoint — three checks that run in CI:

| Module | What it checks | Status |
|---|---|---|
| 01 | [Branch Naming](spec/01-branch-naming.md) uses `<type>/<description>` | Candidate |
| 02 | [Commit Message](spec/02-commit-message.md) uses Conventional Commits plus optional AI attribution | Candidate |
| 03 | [PR Description](spec/03-pr-description.md) includes Summary, Type, AI Disclosure, Changes, Testing, Risk Assessment, Checklist | Candidate |

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

For commit-message checks:

```yaml
- uses: open-delivery-spec/validate-action@v1
  with:
    check: commit-message
    commit_message: ${{ github.event.head_commit.message }}
```

## AI Disclosure

The AI Disclosure section is the key differentiator. It makes AI involvement explicit and machine-checkable.

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
- **AI Tool:** GitHub Copilot
- **AI Scope:** Provider abstraction, token exchange, session management
- **Human Review:** Verified OAuth flow, redirect validation, and token handling
```

AI disclosure is intentionally **qualitative**, not percentage-based. The goal is to tell the reviewer *where* to look, not to compute a number.

## Full Module Map

| # | Module | Summary | Stage |
|---|--------|---------|-------|
| 01 | [Branch Naming](spec/01-branch-naming.md) | Standardized, machine-parseable branch names | 🟡 Candidate |
| 02 | [Commit Message](spec/02-commit-message.md) | AI-attributable, semantically rich commit format | 🟡 Candidate |
| 03 | [PR Description](spec/03-pr-description.md) | Structured PR body with AI disclosure | 🟡 Candidate |
| 04 | [AI Change Review](spec/04-ai-change-review.md) | Protocol for reviewing AI-generated changes | 🧪 Experimental |
| 05 | [CI Failure](spec/05-ci-failure.md) | Machine-parseable CI failure reports | 🧪 Experimental |
| 06 | [Release Readiness](spec/06-release-readiness.md) | Evidence-based release gate checklist | 🧪 Experimental |
| 07 | [Approval Workflow](spec/07-approval-workflow.md) | Declarative approval policy format | 🧪 Experimental |
| 08 | [Rollback Plan](spec/08-rollback-plan.md) | Required rollback plan structure | 🧪 Experimental |
| 09 | [Production Release Evidence](spec/09-prod-release-evidence.md) | Audit-ready deployment evidence | 🧪 Experimental |

> **The wedge is ODS L1 + AI Disclosure.** Modules 04-09 are direction-setting. They exist as schemas and examples for teams that need them, but they are not the recommended adoption path today. See [ROADMAP.md](ROADMAP.md).

## Tooling

| Tool | Repository | Production surface |
|------|------------|-------------------|
| ODS CLI | [open-delivery-spec/cli](https://github.com/open-delivery-spec/cli) | `ods validate branch`, `commit`, `pr` |
| GitHub Action | [open-delivery-spec/validate-action](https://github.com/open-delivery-spec/validate-action) | `branch-naming`, `commit-message`, `pr-description`, `all` |
| PR Template | [examples/ods-pr-template.md](examples/ods-pr-template.md) | Copy-paste PR description template |

## ODS Artifacts

ODS supports two modes:

### Lightweight Validation (Recommended)

Validate delivery metadata directly from CI context. No files written to the repository. This is the recommended L1 adoption mode — install the Action and you're done.

### Evidence Artifacts (Experimental)

For teams exploring release-governance modules, structured records can be stored in `.ods/`. See [`.ods/` Convention](docs/ods-artifacts.md).

## Design Principles

1. **Machine-first, human-readable.** Every artifact has a JSON Schema. Every schema has human docs.
2. **AI-aware, not AI-obsessed.** Metadata records AI involvement where it helps reviewers, without over-indexing on percentage metrics.
3. **Composable.** Start with one check or all L1 checks. Adopt experimental modules when they mature.
4. **Tool-agnostic.** Works with any CI/CD, AI coding tool, or VCS.
5. **Honest about scope.** ODS proves delivery metadata exists — it does not prove code correctness, architecture quality, or security. That's the reviewer's job.

## Inspiration

- [Conventional Commits](https://www.conventionalcommits.org)
- [Conventional Branch](https://conventional-branch.github.io)
- [OpenAPI Specification](https://www.openapis.org)
- [DORA 2025 Report](https://cloud.google.com/blog/products/devops-sre/dora-2025-report)

## License

[Apache License 2.0](LICENSE)
