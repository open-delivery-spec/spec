---
title: Home
layout: home
nav_order: 1
---

# Open Delivery Spec

**A lightweight, machine-readable standard for AI-aware pull request and delivery metadata.**

> ODS does not prove the code is correct. It proves the delivery process contains the minimum structured evidence needed for humans and machines to review the change responsibly.

AI coding tools make changes faster than delivery processes can explain them. Teams need a standard way to answer: what did AI generate, who reviewed it, and what evidence existed before merge or release?

Open Delivery Spec (ODS) defines a small set of **machine-readable metadata conventions** that CI tools and AI agents can validate before merge. The starting point is **ODS L1 + AI Disclosure**: branch, commit, and PR checks that run in CI today.

> **Start here**: [Get Started](get-started) → [PR Template](../examples/ods-pr-template).  
> **See the difference**: [Before & After](case-study).  
> **Why this exists**: [Threats & Failure Modes](threats-and-failure-modes).  
> **Why this exists**: [Threats & Failure Modes](threats-and-failure-modes).  
> **How it fits**: [ODS and SLSA](comparison/slsa) — SLSA proves how artifacts were built; ODS proves how changes were delivered.  
> **Artifact storage**: [`.ods/` Convention](ods-artifacts).

## The Problem

AI makes coding faster. Everything after coding gets harder:

| Question | Why it matters |
|---|---|
| Was this code AI-assisted? | Reviewers need to know where to apply extra scrutiny. |
| Was AI-generated code reviewed by a human? | Teams need accountability, not just fast diffs. |
| Did the PR include expected delivery metadata? | CI should catch missing context before merge. |
| What evidence existed before release? | Audit and incident review need structured records. |

## Before / After

| Before ODS | After ODS L1 + AI Disclosure |
|---|---|
| `Title: fix stuff` | `fix(auth): handle expired OAuth state parameter` |
| Empty PR body | Summary, Type, AI Disclosure, Changes, Testing, Risk Assessment |
| "What does this do? Which part is AI? Was it tested?" | Reviewer has answers before opening the PR |
| No CI validation of PR metadata | CI blocks merges with missing sections |

See the [PR Template](../examples/ods-pr-template.md) for a copy-paste version.

## The Solution: ODS L1 + AI Disclosure

ODS L1 defines three checks that run in CI:

```
Branch Naming → Commit Message → PR Description
       ↓               ↓                ↓
  type/description  Conventional     Summary, Type,
                    Commits + AI     AI Disclosure,
                    attribution      Changes, Testing
```

Experimental modules (04-09) define direction for AI review records, CI failure reports, release readiness, and production evidence. They are **not the recommended adoption path today**.

## Quick Start

```bash
# Install CLI
go install github.com/open-delivery-spec/cli/cmd/ods@latest

# Validate branch naming
ods validate branch feature/add-oauth-login
# ✅ conformant

# Use GitHub Action for the L1 checks available today
- uses: open-delivery-spec/validate-action@v1
  with:
    check: all
    branch_name: ${{ github.head_ref }}
    pr_body: ${{ github.event.pull_request.body }}
    strict: "true"
```

## Modules

### Production (L1)

| # | Module | Purpose |
|---|--------|---------|
| 01 | [Branch Naming](modules/01-branch-naming) | Standardized `<type>/<description>` branch names |
| 02 | [Commit Message](modules/02-commit-message) | Conventional Commits + optional AI attribution |
| 03 | [PR Description](modules/03-pr-description) | Structured PR body with AI disclosure |

### Experimental (04-09)

| # | Module | Purpose |
|---|--------|---------|
| 04 | [AI Change Review](modules/04-ai-change-review) | Review protocol for AI-generated changes |
| 05 | [CI Failure](modules/05-ci-failure) | Machine-parseable failure reports |
| 06 | [Release Readiness](modules/06-release-readiness) | Evidence-based release gates |
| 07 | [Approval Workflow](modules/07-approval-workflow) | Declarative approval policies |
| 08 | [Rollback Plan](modules/08-rollback-plan) | Rollback plan requirements |
| 09 | [Production Release Evidence](modules/09-prod-release-evidence) | Audit-ready evidence bundles |

## Design Principles

1. **Machine-first, human-readable.** Every artifact has a JSON Schema. Every schema has human docs.
2. **AI-aware, not AI-obsessed.** Metadata records AI involvement qualitatively — where and how, not what percentage.
3. **Composable.** Start with one L1 check. Adopt experimental modules when they mature.
4. **Tool-agnostic.** Works with any CI/CD, AI coding tool, or VCS.
5. **Honest about scope.** ODS proves delivery metadata exists — it does not prove code correctness. That's the reviewer's job.

## Inspiration

- [Conventional Commits](https://www.conventionalcommits.org)
- [Conventional Branch](https://conventional-branch.github.io)
- [OpenAPI Specification](https://www.openapis.org)
- [DORA 2025 Report](https://cloud.google.com/blog/products/devops-sre/dora-2025-report)
