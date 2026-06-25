# Open Delivery Spec — Index

**Version:** 1.0.0  
**Status:** Working Draft

## Introduction

Open Delivery Spec (ODS) defines the AI code quality gate for software delivery. The core pipeline (`detect → analyze → score → check`) runs in CI to validate AI-generated code before merge.

See [ROADMAP.md](../ROADMAP.md) for the current milestone plan.

## Deprecated Modules

The original ODS module concept (branch naming, commit message, PR description, and the release-governance modules) is retired as of June 2026. All 9 modules and their JSON Schemas have been **removed** from the repository. Their definitions remain available in git history.

| # | Module | Why it was removed |
|---|--------|-------|
| 01 | Branch Naming | Superseded by the `detect` pipeline; never implemented in the CLI |
| 02 | Commit Message | `Co-Authored-By` trailers (auto-emitted by Claude Code, Copilot, Cursor) are the attribution standard; custom fields were optional supplemental |
| 03 | PR Description | Superseded by the `detect` pipeline |
| 04 | AI Change Review | Recommendations folded into the `analyze`/`score`/`check` stages |
| 05 | CI Failure | Tool feature, not a delivery-metadata spec; out of scope |
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

### Machine-Parseable Output

The pipeline emits structured JSON at every stage (`detect`, `analyze`, `score`), and `check` evaluates that output against an OPA Rego policy. The policy input contract — the fields a policy can read — is documented in the [Policy Input Schema](../docs/schemas.md).

## Versioning

ODS follows [Semantic Versioning](https://semver.org):

- **MAJOR** — Breaking changes to schema structure or required fields
- **MINOR** — New optional fields, new enum values
- **PATCH** — Documentation fixes, example updates, clarifications

## Conformance

A change **conforms** to ODS when the pipeline runs on it and the policy is satisfied. Tools that implement ODS SHALL report one of:
- ✅ `PASS` — No `deny` rule fired
- ⚠️ `WARN` — A `warn` rule fired, but no `deny` rule
- ❌ `BLOCK` — At least one `deny` rule fired (CI exits non-zero)

### Conformance Test Scenarios

The [`spec/conformance/`](conformance/) directory contains reference scenarios — each with an `input.json`, `policy.rego`, and `expected.json` — that any ODS-compatible implementation must pass:

| Scenario | Expected result |
|----------|----------------|
| `pass-human-code` | PASS — human PR, no issues |
| `warn-ai-detected` | WARN — AI detected, policy fires `warn` |
| `block-critical-issue` | BLOCK — critical issue found |
| `block-ai-no-tests` | BLOCK — AI code with < 30% test coverage |
| `warn-detect-inconclusive` | WARN — detection error, `_ods_detect_error` sentinel set |

See [`spec/conformance/README.md`](conformance/README.md) for how to run the suite.

### Policy Input Schema

The machine-readable contract for what fields a policy can read is published as a versioned JSON Schema:
[`schemas/policy-input/v1.json`](../schemas/policy-input/v1.json) — full field reference in [Policy Input Schema](../docs/schemas.md).

## Tooling

- [ODS CLI](https://github.com/open-delivery-spec/cli) — Reference implementation
- [GitHub Action](https://github.com/open-delivery-spec/validate-action) — CI integration
- [Policy Input Schema](../docs/schemas.md) — the machine-readable contract for `ods check`

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for the proposal and review process.
