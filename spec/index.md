# Open Delivery Spec — Index

**Version:** 1.0.0  
**Status:** Working Draft

## Introduction

Open Delivery Spec (ODS) defines standards for software delivery artifacts in the AI era. Each module below specifies a **format**, provides a **JSON Schema**, and includes **examples** that tools can validate against.

## Module Status

| Acronym | Meaning | Description |
|---------|---------|-------------|
| **Draft** | Work in progress | Scope and schema may change. Feedback welcome. |
| **Candidate** | Implementation-validated | Schema is stable enough for tooling. Minor additions only. |
| **Stable** | Production-ready | Schema follows semver. Breaking changes require a new major version. |
| **Deprecated** | To be removed | Superseded by another module or retired. |

## Modules

| # | Module | Schema | Status |
|---|--------|--------|--------|
| 01 | [Branch Naming](01-branch-naming.md) | [`branch-naming.json`](../schemas/branch-naming.json) | 🟡 Candidate |
| 02 | [Commit Message](02-commit-message.md) | [`commit-message.json`](../schemas/commit-message.json) | 🟡 Candidate |
| 03 | [PR Description](03-pr-description.md) | [`pr-description.json`](../schemas/pr-description.json) | 🟡 Candidate |
| 04 | [AI Change Review](04-ai-change-review.md) | [`ai-change-review.json`](../schemas/ai-change-review.json) | 🔵 Draft |
| 05 | [CI Failure](05-ci-failure.md) | [`ci-failure.json`](../schemas/ci-failure.json) | 🔵 Draft |
| 06 | [Release Readiness](06-release-readiness.md) | [`release-readiness.json`](../schemas/release-readiness.json) | 🔵 Draft |
| 07 | [Approval Workflow](07-approval-workflow.md) | [`approval-workflow.json`](../schemas/approval-workflow.json) | 🔵 Draft |
| 08 | [Rollback Plan](08-rollback-plan.md) | [`rollback-plan.json`](../schemas/rollback-plan.json) | 🔵 Draft |
| 09 | [Production Release Evidence](09-prod-release-evidence.md) | [`prod-release-evidence.json`](../schemas/prod-release-evidence.json) | 🔵 Draft |

## The Delivery Lifecycle

```
Developer / AI Agent
    │
    ▼
┌─ 01 Branch Naming ──────────────────────────────┐
│  feature/ai-add-oauth                            │
└──────────────────────┬───────────────────────────┘
                       ▼
┌─ 02 Commit Message ─────────────────────────────┐
│  feat(auth): add OAuth flow                     │
│  AI-assisted: true | AI-tool: Copilot            │
└──────────────────────┬───────────────────────────┘
                       ▼
┌─ 03 PR Description ─────────────────────────────┐
│  Summary, AI Disclosure, Risk Assessment         │
└──────────────────────┬───────────────────────────┘
                       ▼
┌─ 04 AI Change Review ───────────────────────────┐
│  L2 Enhanced / L3 Full Audit                     │
└──────────────────────┬───────────────────────────┘
           ┌───────────┴───────────┐
           ▼                       ▼
┌─ 05 CI Failure ───┐   ┌─ 07 Approval Workflow ──┐
│  Failure reports   │   │  Who approves what?     │
│  AI explanations   │   │  AI-aware policies      │
└────────┬───────────┘   └───────────┬─────────────┘
         └───────────┬───────────────┘
                     ▼
┌─ 06 Release Readiness ──────────────────────────┐
│  Gates, Scores, AI Risk Assessment               │
└──────────────────────┬───────────────────────────┘
         ┌─────────────┼─────────────┐
         ▼             ▼             ▼
┌─ 08 Rollback ─┐ ┌─ 09 Evidence ─┐  Deploy
│  Plan, test   │ │  Audit trail  │──────▶ Production
└───────────────┘ └───────────────┘
```

## Key Concepts

### AI Attribution

Every artifact carries an **AI attribution flag** that indicates whether AI contributed. This enables automated workflows to apply appropriate scrutiny levels without requiring human triage.

### Machine-Parseable Schemas

Each module defines a JSON Schema. Tools can validate artifacts without understanding the semantics — just validate against the schema. This makes ODS compatible with any language, any CI/CD, any AI tool.

### Composable Design

Use one module or all nine. Each schema is independently useful:
- Need better branch names? → Use only Module 01
- Want AI review standards? → Add Module 04
- Need SOC2 compliance evidence? → Adopt Module 09

### Governance as Code

Approval policies (Module 07) are declarative JSON. They're stored in version control, reviewed like code, and enforced by automation — not by remembering who needs to approve what.

## Versioning

ODS follows [Semantic Versioning](https://semver.org):

- **MAJOR** — Breaking changes to schema structure or required fields
- **MINOR** — New modules, new optional fields, new enum values
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
- [GitHub Action](https://github.com/open-delivery-spec/github-action) — CI integration
- Schema validation: Use any JSON Schema validator with our [schemas](../schemas/)

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for the proposal and review process.
