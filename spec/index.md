# Open Delivery Spec — Index

**Version:** 1.0.0  
**Status:** Working Draft

## Introduction

Open Delivery Spec (ODS) defines the AI code quality gate for software delivery. The core pipeline (`detect → analyze → score → check`) runs in CI to validate AI-generated code before merge.

See [ROADMAP.md](../ROADMAP.md) for the current milestone plan.

## Deprecated Modules

The original ODS module concept (branch naming, commit message, and PR description conventions) is retired as of June 2026. All 9 modules are deprecated. Schemas remain in `schemas/` for reference only.

| # | Module | Reason |
|---|--------|-------|
| 01 | Branch Naming | Superseded by the detect pipeline; not implemented in CLI |
| 02 | Commit Message | `Co-Authored-By` trailers (auto-emitted by Claude Code, Copilot, Cursor) are the attribution standard; custom fields are optional supplemental |
| 03 | PR Description | Superseded by the detect pipeline |
| 04 | AI Change Review | Recommendations folded into the score/check stages |
| 05 | CI Failure | Tool feature, not a delivery metadata spec; out of scope |
| 06 | Release Readiness | Overlaps with SLSA / in-toto; out of scope |
| 07 | Approval Workflow | Overlaps with SLSA / in-toto; out of scope |
| 08 | Rollback Plan | Overlaps with SLSA / in-toto; out of scope |
| 09 | Production Release Evidence | Overlaps with SLSA / in-toto; out of scope |

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

ODS-specific trailer fields (`AI-assisted:`, `AI-tool:`) are supplemental and optional. Teams using AI tools that already emit `Co-Authored-By` are already compliant.

### Machine-Parseable Schemas

Deprecated module schemas remain in `schemas/` for reference. Tools can validate artifacts without understanding the semantics — just validate against the schema.

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
