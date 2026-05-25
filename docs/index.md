---
title: Home
layout: home
nav_order: 1
---

# Open Delivery Spec

**An open specification for machine-readable delivery governance evidence in the AI era.**

AI is writing more code than ever — [90% of developers use AI daily](https://cloud.google.com/blog/products/devops-sre/dora-2025-report), spending a median of 2 hours per day with AI tools. But delivery governance hasn't caught up. Faster coding doesn't mean safer shipping.

Open Delivery Spec (ODS) is an early-stage open specification that defines **standardized, machine-parseable schemas** for core delivery governance artifacts — so teams can answer questions like "what did AI write?", "who reviewed it?", and "what evidence existed before we deployed?"

> **Start here**: [ODS Levels](levels) → [Get Started](get-started).  
> **Why this exists**: [Threats & Failure Modes](threats-and-failure-modes).  
> **How it fits**: [ODS and SLSA](comparison/slsa).

## The Problem

AI makes coding faster. Everything after coding gets harder:

| Before Merge | At Merge | After Merge |
|---|---|---|
| Branch naming is ad-hoc | PR descriptions are inconsistent | CI failures lack structured explanation |
| Commit messages are inconsistent | AI-generated changes lack review standards | Release readiness is a gut-feel decision |
| | Approval workflows are unclear | Rollback plans are missing |
| | | Production releases lack audit evidence |

## The Solution: Standardized Delivery Artifacts

ODS defines a **JSON Schema** for each delivery artifact. Tools validate artifacts against these schemas. AI agents produce compliant artifacts by default.

```
Branch Naming → Commit Message → PR Description → AI Review
                                                      ↓
Production Evidence ← Rollback Plan ← Release ← CI Failure
                                    Readiness   Approval Flow
```

## Quick Start

```bash
# Install CLI
go install github.com/open-delivery-spec/cli/cmd/ods@latest

# Validate branch naming
ods validate branch feature/add-oauth-login
# ✅ conformant

# Use GitHub Action
- uses: open-delivery-spec/validate-action@v1
  with:
    check: branch-naming
    branch_name: ${{ github.head_ref }}
```

## Modules

| # | Module | Purpose |
|---|--------|---------|
| 01 | [Branch Naming](modules/01-branch-naming) | Standardized branch names with AI markers |
| 02 | [Commit Message](modules/02-commit-message) | AI-attributable commit format |
| 03 | [PR Description](modules/03-pr-description) | Structured PR body with AI disclosure |
| 04 | [AI Change Review](modules/04-ai-change-review) | L1/L2/L3 review protocol |
| 05 | [CI Failure](modules/05-ci-failure) | Machine-parseable failure reports |
| 06 | [Release Readiness](modules/06-release-readiness) | Evidence-based release gates |
| 07 | [Approval Workflow](modules/07-approval-workflow) | Declarative approval policies |
| 08 | [Rollback Plan](modules/08-rollback-plan) | Rollback plan requirements |
| 09 | [Production Release Evidence](modules/09-prod-release-evidence) | Audit-ready evidence bundles |

## Design Principles

1. **Machine-first, human-readable.** Every artifact has a JSON Schema. Every schema has human docs.
2. **AI-native.** Schemas include fields for AI attribution, scope, and confidence.
3. **Composable.** Use one module or all. Each schema is independently useful.
4. **Tool-agnostic.** Works with any CI/CD, any AI tool, any VCS.
5. **Audit-ready.** Every artifact carries evidence for compliance.

## Inspiration

- [Conventional Commits](https://www.conventionalcommits.org)
- [Conventional Branch](https://conventional-branch.github.io)
- [OpenAPI Specification](https://www.openapis.org)
- [DORA 2025 Report](https://cloud.google.com/blog/products/devops-sre/dora-2025-report)
