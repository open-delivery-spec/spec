# Specification Versioning

This document defines how the ODS contracts are versioned and which changes are
allowed once a contract is stable.

## What is versioned

The machine-readable surface of ODS is a set of contracts published as JSON
Schemas under `schemas/<name>/v1.json`:

| Contract | Produced by | Consumed by |
|----------|-------------|-------------|
| `policy-input/v1` | the pipeline (`detect`, `analyze`, `score`, `check`) | Rego policies, `ods check --input` |
| `check-output/v1` | `ods check` | CI, the GitHub Action, the conformance suite |
| `detect-output/v1`, `analyze-output/v1`, `score-output/v1` | the corresponding command | CI, reports |
| `review-verdict/v1` | any AI or human reviewer | `ods check --ai-review` |

The version is the path segment. Within a version, changes are **additive
only**; a breaking change is a new directory (`v2/`), and the old one keeps
being served until its deprecation period ends. The spec repository as a whole
carries a semantic version in [CHANGELOG.md](CHANGELOG.md); its MAJOR follows
the contracts (2.0.0 replaced the 1.0.0 module system).

## Breaking changes

A change is **breaking** if it would make a previously conformant document
non-conformant, or make a previously valid policy read a different value:

| Change | Breaking? |
|--------|-----------|
| Adding a new required field | ✅ Breaking |
| Removing a field, required or optional | ✅ Breaking |
| Changing a field's type or its sentinel (for example `test_coverage`'s `-1`) | ✅ Breaking |
| Removing an enum value | ✅ Breaking |
| Adding a new optional field | ❌ Not breaking |
| Adding a new enum value | ❌ Not breaking |
| Relaxing a constraint | ❌ Not breaking |
| Documentation clarification | ❌ Not breaking |

Every new optional field is a new **check** and carries a maturity status
(Experimental → Candidate → Stable), tracked in [ROADMAP.md](ROADMAP.md) and
decided as described in [GOVERNANCE.md](GOVERNANCE.md). Experimental fields may
still change or disappear.

## Deprecation policy

1. A deprecated check or contract version stays documented and served for
   **6 months** after the deprecation is announced.
2. Deprecations are announced in [CHANGELOG.md](CHANGELOG.md), and the schema
   description of a deprecated field says what replaces it.

## Tooling compatibility

The reference CLI ([open-delivery-spec/cli](https://github.com/open-delivery-spec/cli))
and the GitHub Action ([validate-action](https://github.com/open-delivery-spec/validate-action))
follow their own semantic versions. Each CLI release implements exactly one
version of every contract; the Action's `v1` major tracks the current `v1`
contracts and would move to `v2` together with them. CI in this repository
runs the CLI's `main` against the schemas and the conformance suite on every
change, so drift between the two shows up here first.
