---
title: JSON Schemas
layout: default
nav_order: 10
has_children: false
---

# JSON Schemas

Each Open Delivery Spec module has a JSON Schema ([Draft 2020-12](https://json-schema.org/specification-links.html#2020-12)) that defines the canonical, machine-validatable structure for that artifact type.

## Using Schemas

Tools and AI agents can validate artifacts against these schemas:

```bash
# With ODS CLI
ods validate branch feature/add-oauth-login

# With any JSON Schema validator
ajv validate -s schemas/branch-naming.json -d my-branch.json

# With Python
pip install jsonschema
jsonschema -i my-branch.json schemas/branch-naming.json
```

## Schema Index

| # | Module | Schema | Raw |
|---|--------|--------|-----|
| 01 | Branch Naming | `branch-naming.json` | [Download](https://raw.githubusercontent.com/open-delivery-spec/spec/main/schemas/branch-naming.json) |
| 02 | Commit Message | `commit-message.json` | [Download](https://raw.githubusercontent.com/open-delivery-spec/spec/main/schemas/commit-message.json) |
| 03 | PR Description | `pr-description.json` | [Download](https://raw.githubusercontent.com/open-delivery-spec/spec/main/schemas/pr-description.json) |
| 04 | AI Change Review | `ai-change-review.json` | [Download](https://raw.githubusercontent.com/open-delivery-spec/spec/main/schemas/ai-change-review.json) |
| 05 | CI Failure | `ci-failure.json` | [Download](https://raw.githubusercontent.com/open-delivery-spec/spec/main/schemas/ci-failure.json) |
| 06 | Release Readiness | `release-readiness.json` | [Download](https://raw.githubusercontent.com/open-delivery-spec/spec/main/schemas/release-readiness.json) |
| 07 | Approval Workflow | `approval-workflow.json` | [Download](https://raw.githubusercontent.com/open-delivery-spec/spec/main/schemas/approval-workflow.json) |
| 08 | Rollback Plan | `rollback-plan.json` | [Download](https://raw.githubusercontent.com/open-delivery-spec/spec/main/schemas/rollback-plan.json) |
| 09 | Production Release Evidence | `prod-release-evidence.json` | [Download](https://raw.githubusercontent.com/open-delivery-spec/spec/main/schemas/prod-release-evidence.json) |

## Schema Structure

Every ODS schema follows this convention:

```jsonc
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://open-delivery-spec.dev/schemas/<module>.json",
  "title": "ODS <Module>",
  "description": "...",
  "required": ["..."],
  "properties": {
    // module-specific fields
  }
}
```

Fields common across many schemas:

- **`ai_generated`** / **`ai_tool`** — AI attribution (required when AI was involved)
- **`version`** / **`spec_version`** — Spec version for forward compatibility
- **`timestamp`** — ISO 8601 timestamp of artifact creation

## Versioning

Schemas follow [SemVer](https://semver.org) aligned with [SPEC_VERSIONING.md](https://github.com/open-delivery-spec/spec/blob/main/SPEC_VERSIONING.md). The `$id` URI reflects the spec version:

- `v1.0.0` schemas use `https://open-delivery-spec.dev/schemas/` (no version in path)
- Future breaking changes will increment the major version in `$id`.
