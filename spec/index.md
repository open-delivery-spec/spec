# Open Delivery Spec — Index

**Version:** 2.0.0  
**Status:** Working Draft

## Introduction

Open Delivery Spec (ODS) defines the AI code quality gate for software delivery. Each module specifies a **format**, provides a **JSON Schema**, and includes **examples** that tools can validate against.

## Module Status

| Status | Meaning |
|--------|--------|
| **Candidate** | Implementation-validated. Schema stable enough for tooling. Minor additions only. |
| **Deprecated** | Retired. Schemas remain in `schemas/` for reference; no new tooling. |

## Active Modules

| # | Module | Schema | Status |
|---|--------|--------|--------|
| 01 | [Branch Naming](01-branch-naming.md) | [`branch-naming.json`](../schemas/branch-naming.json) | 🟡 Candidate |
| 02 | [Commit Message](02-commit-message.md) | [`commit-message.json`](../schemas/commit-message.json) | 🟡 Candidate |
| 03 | [PR Description](03-pr-description.md) | [`pr-description.json`](../schemas/pr-description.json) | 🟡 Candidate |

## Deprecated Modules

The following modules are retired as of June 2026. Schemas remain in `schemas/` for reference only.

| # | Module | Reason |
|---|--------|-------|
| 04 | [AI Change Review](04-ai-change-review.md) | Recommendations folded into Module 03 PR Description |
| 05 | [CI Failure](05-ci-failure.md) | Tool feature, not a delivery metadata spec; out of scope |
| 06 | [Release Readiness](06-release-readiness.md) | Overlaps with SLSA / in-toto; out of scope |
| 07 | [Approval Workflow](07-approval-workflow.md) | Overlaps with SLSA / in-toto; out of scope |
| 08 | [Rollback Plan](08-rollback-plan.md) | Overlaps with SLSA / in-toto; out of scope |
| 09 | [Production Release Evidence](09-prod-release-evidence.md) | Overlaps with SLSA / in-toto; out of scope |

See [ROADMAP.md](../ROADMAP.md) for context on the deprecations.

---

## The AI Code Quality Pipeline

```
PR arrives
   │
   ▼
① Detect  — Is there AI code? (Co-Authored-By, PR disclosure, branch prefix, diff heuristics)
   │
   ▼
② Analyze — What quality issues does it have? (5 rule categories)
   │
   ▼
③ Score   — How much technical debt does this PR add? (5-dimension weighted score)
   │
   ▼
④ Enforce — Should this PR be blocked? (OPA Rego policy)
   │
   ▼
PASS / WARN / BLOCK
```

---

## Key Concepts

### AI Attribution

ODS reads `Co-Authored-By` trailers — already emitted by Claude Code, GitHub Copilot, and Cursor — as the **primary** AI attribution signal. A commit with a recognized AI tool in `Co-Authored-By` is an ODS-compliant disclosure without any additional fields.

ODS-specific trailer fields (`AI-assisted:`, `AI-tool:`) are supplemental and optional. Teams using AI tools that already emit `Co-Authored-By` are already compliant with Module 02.

### Machine-Parseable Schemas

Each active module defines a JSON Schema. Tools can validate artifacts without understanding the semantics — just validate against the schema.

### Composable Design

Use one module or all three:
- Branch names with AI context? → Module 01
- AI-attributed commit messages? → Module 02
- Structured AI disclosure in PRs? → Module 03

## Versioning

ODS follows [Semantic Versioning](https://semver.org):

- **MAJOR** — Breaking changes to schema structure or required fields
- **MINOR** — New optional fields, new enum values
- **PATCH** — Documentation fixes, example updates, clarifications

## Conformance

An artifact **conforms** to ODS when:
1. It validates against the corresponding JSON Schema
2. All required fields are present and valid
3. All conditional requirements are satisfied

Tools that validate ODS compliance SHALL report:
- ✅ `conformant` — All requirements satisfied
- ⚠️ `conformant with warnings` — Non-required fields missing or invalid
- ❌ `non-conformant` — Required fields missing or invalid

## Tooling

- [ODS CLI](https://github.com/open-delivery-spec/cli) — Reference implementation
- [GitHub Action](https://github.com/open-delivery-spec/validate-action) — CI integration
- Schema validation: Use any JSON Schema validator with our [schemas](../schemas/)

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for the proposal and review process.
