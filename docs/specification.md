---
title: Specification
nav_order: 4
has_children: true
has_toc: false
---

# Specification

{% include spec_status.html status="Stable" version="v1" %}

The specification is the set of **contracts** between the stages of an ODS
pipeline, the **repository convention** that holds a project's policy, and the
**conformance suite** an implementation must pass. The
[CLI](https://github.com/open-delivery-spec/cli) and the
[GitHub Action](https://github.com/open-delivery-spec/validate-action) are the
reference implementation; any tool that produces and consumes these documents
is an ODS implementation.

## Contracts

| Contract | Produced by | Consumed by |
|----------|-------------|-------------|
| [`policy-input/v1`](schemas.md) | the pipeline (`detect`, `analyze`, `score`, `check`) | Rego policies, `ods check --input` |
| [`check-output/v1`](schemas.md#per-command-output-schemas) | `ods check` | CI, the GitHub Action, the conformance suite |
| [`detect-output/v1`, `analyze-output/v1`, `score-output/v1`](schemas.md#per-command-output-schemas) | the corresponding command | CI, reports |
| [`review-verdict/v1`](schemas.md) | any AI or human reviewer | `ods check --ai-review` |

The JSON Schemas live in
[`schemas/`](https://github.com/open-delivery-spec/spec/tree/main/schemas).
Within a version, changes are additive only; a breaking change is a new
version directory, and the old one is served for six months after its
deprecation is announced. The rules are in
[SPEC_VERSIONING.md](https://github.com/open-delivery-spec/spec/blob/main/SPEC_VERSIONING.md).

## Conformance

Each scenario in
[`spec/conformance/`](https://github.com/open-delivery-spec/spec/tree/main/spec/conformance)
is a `policy-input/v1` document, a policy and the `check-output/v1` it must
produce. A conforming implementation returns that output, compares denials and
warnings as sets, and **exits non-zero when `allowed` is false**: the exit code
is what blocks a merge.

```bash
ods check --input spec/conformance/<scenario>/input.json \
          --policy spec/conformance/<scenario>/policy.rego --json
```

## In this section

- [Contracts & Schemas](schemas.md): every field of the policy input and the per-stage outputs.
- [The `.ods/` Convention](ods-artifacts.md): where a repository keeps its policy, and the environment the pipeline reads.
- [Proposal 001: AI Code Evidence](proposals/001-ai-code-evidence.md): the CycloneDX-aligned evidence document behind `ods attest`.
