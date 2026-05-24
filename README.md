# Open Delivery Spec (ODS)

**The open standard for AI-era software delivery governance.**

AI is writing more code than ever — [90% of developers use AI daily](https://cloud.google.com/blog/products/devops-sre/dora-2025-report), spending a median of 2 hours per day with AI tools. But delivery governance hasn't caught up. Faster coding doesn't mean safer shipping.

Open Delivery Spec defines **standardized, machine-parseable schemas** for every artifact in the software delivery lifecycle — from branch naming to production release evidence. Think of it as "OpenAPI for delivery governance."

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
┌─────────────────────────────────────────────────────┐
│                  OPEN DELIVERY SPEC                  │
│                                                      │
│  Branch     Commit    PR         CI        Release   │
│  Naming ──► Message ─►Desc ──► Failure ──►Readiness │
│    │          │        │         │           │       │
│    ▼          ▼        ▼         ▼           ▼       │
│  ┌──────────────────────────────────────────────┐   │
│  │         JSON Schema (machine-readable)       │   │
│  └──────────────────────────────────────────────┘   │
│    │          │        │         │           │       │
│    ▼          ▼        ▼         ▼           ▼       │
│  AI Review   Approval   Rollback   Production        │
│  Protocol    Workflow   Plan       Evidence          │
│                                                      │
└─────────────────────────────────────────────────────┘
```

## Specification Modules

| # | Module | Summary |
|---|--------|---------|
| 01 | [Branch Naming](spec/01-branch-naming.md) | Standardized, machine-parseable branch names |
| 02 | [Commit Message](spec/02-commit-message.md) | AI-attributable, semantically rich commit format |
| 03 | [PR Description](spec/03-pr-description.md) | Structured PR body with AI disclosure |
| 04 | [AI Change Review](spec/04-ai-change-review.md) | Protocol for reviewing AI-generated changes |
| 05 | [CI Failure](spec/05-ci-failure.md) | Machine-parseable CI failure reports |
| 06 | [Release Readiness](spec/06-release-readiness.md) | Evidence-based release gate checklist |
| 07 | [Approval Workflow](spec/07-approval-workflow.md) | Declarative approval policy format |
| 08 | [Rollback Plan](spec/08-rollback-plan.md) | Required rollback plan structure |
| 09 | [Production Release Evidence](spec/09-prod-release-evidence.md) | Audit-ready deployment evidence |

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

## Inspiration

- [Conventional Commits](https://www.conventionalcommits.org)
- [Conventional Branch](https://conventional-branch.github.io)
- [OpenAPI Specification](https://www.openapis.org)
- [DORA 2025 Report](https://cloud.google.com/blog/products/devops-sre/dora-2025-report)

## License

[Apache License 2.0](LICENSE)
