---
title: Home
layout: home
nav_order: 1
---

# Open Delivery Spec

**A lightweight, machine-readable standard for AI-aware pull request delivery.**

> ODS does not prove the code is correct. It proves the delivery process contains the minimum structured evidence needed for humans and machines to review the change responsibly.

AI coding tools make changes faster than delivery processes can explain them. ODS defines a CI quality gate that answers: what did AI generate, how much risk does it add, and does it meet your policy before merge?

> **Start here**: [Get Started](get-started.md) → [Adoption Guide](adoption-guide.md)  
> **Real-world scenarios**: [Open-source](scenarios/open-source-project.md) · [Enterprise](scenarios/enterprise-service.md) · [AI coding team](scenarios/ai-coding-pr.md)  
> **Policy customization**: [`.ods/` Convention](ods-artifacts.md)  
> **How it fits**: [ODS and SLSA](comparison/slsa.md) — SLSA proves how artifacts were built; ODS proves how changes were delivered.  
> **Threats & Failure Modes**: [Why this exists](threats-and-failure-modes.md)

## Quick Start

```bash
# Install CLI
go install github.com/open-delivery-spec/cli/cmd/ods@latest

# Initialize your repo (creates the CI workflow + .ods/policy.rego)
ods init

# Run the pipeline locally
ods detect && ods analyze && ods score && ods check
```

Add the GitHub Action to your CI:

```yaml
- uses: actions/checkout@v7
  with:
    fetch-depth: 0
- uses: open-delivery-spec/validate-action@v1
  with:
    diff-base: ${{ github.event.pull_request.base.sha }}
    pr-body: ${{ github.event.pull_request.body }}
    branch: ${{ github.head_ref }}
    commits: ${{ github.event.pull_request.commits }}
```

## The AI Code Quality Pipeline

ODS runs four stages on every PR:

```
PR arrives
   │
   ▼
① detect  — Is there AI code?
   │         (Co-Authored-By trailers, branch prefix, diff heuristics)
   ▼
② analyze — What quality issues does it have?
   │         (built-in AI heuristics + imported SARIF findings)
   ▼
③ score   — How much technical debt does this PR add?
   │         (quality-driven, weighted by AI risk)
   ▼
④ check   — Should this PR be blocked?
             (OPA Rego policy: PASS / WARN / BLOCK)
```

## What ODS Detects

| Signal | How it works |
|--------|-------------|
| `Co-Authored-By` trailer | Primary — emitted automatically by Claude Code, Copilot, Cursor |
| Branch prefix | `claude/`, `copilot/`, `cursor/`, `codeium/` branches |
| PR body | `AI-assisted: true` or `AI-tool:` disclosure fields |
| Diff heuristics | Patterns in changed files consistent with AI generation |

## Why This Matters

| Question | Why it matters |
|---|---|
| Was this code AI-assisted? | Reviewers need to know where to apply extra scrutiny. |
| Was AI-generated code reviewed by a human? | Teams need accountability, not just fast diffs. |
| What technical debt does this PR introduce? | CI should catch quality regressions before merge. |
| What evidence existed before release? | Audit and incident review need structured records. |

## Design Principles

1. **Machine-first, human-readable.** Every output has structured JSON. Every JSON has human docs.
2. **AI-aware, not AI-obsessed.** ODS detects AI involvement — it does not block it by default.
3. **Policy-driven.** Teams define what passes via OPA Rego in `.ods/policy.rego`.
4. **Tool-agnostic.** Works with any CI/CD, AI coding tool, or VCS.
5. **Honest about scope.** ODS proves delivery metadata exists — it does not prove code correctness.

## Inspiration

- [Conventional Commits](https://www.conventionalcommits.org)
- [OpenAPI Specification](https://www.openapis.org)
- [DORA 2025 Report](https://cloud.google.com/blog/products/devops-sre/dora-2025-report)
