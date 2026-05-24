# Specification Versioning

This document defines how Open Delivery Spec modules are versioned and what changes are allowed at each maturity level.

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

## Module-Level Versioning

Each module is versioned independently. A breaking change to Module 03 does not force a major bump for Module 01.

The spec as a whole carries an aggregate version that reflects the highest maturity level achieved across modules. This is the version referenced by tooling.

## Deprecation Policy

1. Deprecated modules remain in the spec for **6 months** after deprecation announcement.
2. Deprecated fields remain in schemas for at least **1 minor version** after deprecation.
3. Deprecation notices are published in [CHANGELOG.md](CHANGELOG.md).

## Tooling Compatibility

| Spec Version | CLI Version | Action Version |
|-------------|-------------|----------------|
| `1.0.0-draft` | `>= 1.0.0` | `@v1` |

CLI and GitHub Action versions track the aggregate spec version. Breaking changes to tooling follow their own semver.
