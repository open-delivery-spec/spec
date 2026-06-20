# Specification Versioning

This document defines how Open Delivery Spec is versioned and what changes are allowed at each maturity level.

## Semantic Versioning

ODS modules follow [Semantic Versioning 2.0.0](https://semver.org/) with extensions for pre-release maturity markers.

### Version Format

```
MAJOR.MINOR.PATCH[-draft|-candidate]
```

| Component | Meaning |
|-----------|---------|
| **MAJOR** | Breaking changes to schema (removed required fields, changed field types, removed enum values) |
| **MINOR** | New optional fields, new enum values, new modules |
| **PATCH** | Documentation fixes, example updates, non-semantic clarifications |

### Pre-release Markers

| Marker | Meaning | Example |
|--------|---------|---------|
| `-draft` | Schema is not yet stable. Breaking changes allowed without major bump. | `1.0.0-draft` |
| (none) | Stable release. Semver strictly enforced. | `1.0.0` |

Modules in **Candidate** status carry `-draft` marker until promoted to Stable, at which point the marker is dropped and the version resets to `1.0.0`.

### Transition Example

```
Draft phase:
  0.1.0-draft → 0.2.0-draft → 1.0.0-draft

Candidate phase (schema stabilizing):
  1.0.0-draft → 1.0.1-draft → 1.1.0-draft

Stable promotion:
  1.0.0-draft → 1.0.0  (drop marker, start semver)
```

## Breaking Changes

A change is **breaking** if it would cause a previously conformant artifact to become non-conformant:

| Change | Breaking? |
|--------|-----------|
| Adding a new required field | ✅ Breaking |
| Removing a required field | ✅ Breaking |
| Changing a field type (string → integer) | ✅ Breaking |
| Removing an enum value | ✅ Breaking |
| Adding a new optional field | ❌ Not breaking |
| Adding a new enum value | ❌ Not breaking |
| Relaxing a constraint (max → higher max) | ❌ Not breaking |
| Documentation clarification | ❌ Not breaking |

## Check-Level Maturity

Each check (analysis rule, scoring dimension, detection signal) carries its own maturity status: **Experimental**, **Candidate**, or **Stable**. These statuses are documented in [ROADMAP.md](ROADMAP.md).

The spec as a whole carries a single aggregate version. This is the version referenced by tooling (CLI, GitHub Action).

## Deprecation Policy

1. Deprecated checks remain documented for **6 months** after deprecation announcement.
2. Deprecation notices are published in [CHANGELOG.md](CHANGELOG.md).

### Module Deprecation (June 2026)

The original modules (01–09: Branch Naming, Commit Message, PR Description, AI Change Review, CI Failure, Release Readiness, Approval Workflow, Rollback Plan, Production Evidence) and their JSON Schemas have been **removed**. The CLI never shipped support for most of them, and the survivors were superseded by the AI code quality pipeline (`detect → analyze → score → check`). Their definitions remain available in git history.

## Tooling Compatibility

| Spec Surface | CLI Version | Action Version |
|--------------|-------------|----------------|
| AI code quality pipeline (`detect → analyze → score → check`) | `>= 1.0.0` | `@v1` |

The CLI and GitHub Action track the spec's aggregate version. `validate-action@v1` runs the current AI code quality pipeline. Breaking changes to tooling follow their own semver; a future `@v2` would accompany a `2.0.0` spec.
