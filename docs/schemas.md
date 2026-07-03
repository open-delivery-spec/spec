---
title: Policy Input Schema
layout: default
nav_order: 10
has_children: false
---

# Policy Input Schema

ODS's machine-readable contract is the **policy input** — the structured object the pipeline feeds to your OPA Rego policy at the `check` stage. Any policy you write reads from these fields.

> [!NOTE]
> ODS previously published per-module JSON Schemas (branch naming, commit message, release evidence, etc.). Those modules were deprecated in June 2026 and their schemas removed. The pipeline's policy input below is the current machine contract. See [ROADMAP.md](https://github.com/open-delivery-spec/spec/blob/main/ROADMAP.md).

## Machine-Readable Schema

The policy input contract is published as a versioned JSON Schema:

**[`schemas/policy-input/v1.json`](https://github.com/open-delivery-spec/spec/blob/main/schemas/policy-input/v1.json)**
(`$id`: `https://open-delivery-spec.dev/schemas/policy-input/v1.json`)

You can use it to validate policy inputs or generate typed bindings in your language of choice:

```bash
# Validate a local policy input against the schema
npx ajv-cli validate -s schemas/policy-input/v1.json -d .ods/out/detect.json
```

## Per-Command Output Schemas

Each pipeline stage emits a JSON document with `--json`. These outputs are the
building blocks the `check` stage assembles into the policy input above, and each
has its own versioned schema so tools can consume stage output directly:

| Command | Schema | `$id` |
|---------|--------|-------|
| `ods detect --json` | [`schemas/detect-output/v1.json`](https://github.com/open-delivery-spec/spec/blob/main/schemas/detect-output/v1.json) | `…/schemas/detect-output/v1.json` |
| `ods analyze --json` | [`schemas/analyze-output/v1.json`](https://github.com/open-delivery-spec/spec/blob/main/schemas/analyze-output/v1.json) | `…/schemas/analyze-output/v1.json` |
| `ods score --json` | [`schemas/score-output/v1.json`](https://github.com/open-delivery-spec/spec/blob/main/schemas/score-output/v1.json) | `…/schemas/score-output/v1.json` |
| `ods check --json` | [`schemas/check-output/v1.json`](https://github.com/open-delivery-spec/spec/blob/main/schemas/check-output/v1.json) | `…/schemas/check-output/v1.json` |

```bash
# Validate real stage output against its schema
ods detect --json > detect.json
npx ajv-cli validate -s schemas/detect-output/v1.json -d detect.json
```

## Policy Input Fields

| Field | Type | Required | Produced by | Description |
|-------|------|----------|-------------|-------------|
| `ai_generated` | bool | ✅ | `detect` | Whether AI code was detected in the diff |
| `ai_confidence` | float (0.0–1.0) | ✅ | `detect` | Aggregate detection confidence |
| `issues` | array | | `analyze` | Quality issues found |
| `technical_debt_delta` | float | | `score` | Weighted technical-debt impact of the PR |
| `test_coverage` | float (−1 or 0.0–1.0) | | `score` | Test coverage ratio; **−1 means not measured** |
| `test_coverage_source` | string | | `score` | How coverage was measured (`go`/`lcov`/`cobertura`/`nyc`/`estimated`/`unknown`) |
| `branch` | string | | context | The PR's head branch name |
| `changed_files` | string[] | | context | Paths of files changed in the PR |
| `ai_files` | array | | `detect` | Per-file AI attribution detail |

> **`test_coverage` sentinel:** A value of `−1` means coverage was not measured (no coverage file found). Policies that check coverage MUST guard with `input.test_coverage >= 0` to avoid false positives on PRs where coverage is unavailable.

### `issues[]` item shape

| Field | Type | Description |
|-------|------|-------------|
| `rule` | string | Rule id, e.g. `ai-unsafe-deserialization` |
| `severity` | string | `low` \| `medium` \| `high` \| `critical` |
| `file` | string | Path to the affected file |
| `line` | integer | Line number of the finding |
| `message` | string | Human-readable description |

### `ai_files[]` item shape

| Field | Type | Description |
|-------|------|-------------|
| `path` | string | File path |
| `ai_lines` | integer | Lines attributed to AI |
| `total_lines` | integer | Total changed lines in the file |
| `confidence` | float | Per-file confidence (0.0–1.0) |

## Using the Input in a Policy

```rego
package ods.policy

default allow := true

deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}
```

See the [`.ods/` Convention](ods-artifacts.md) for where the policy lives and [Get Started](get-started.md) for the full setup.

## Review Routing: the `review_tier` Output

Beyond allow/deny, a policy may answer a second question — **how much human
attention does this change need?** — by defining a `review_tier` rule that
returns one of:

| Tier | Meaning |
|------|---------|
| `auto` | Low risk — eligible for expedited review or (opt-in) auto-merge |
| `standard` | Normal review. The default when the policy defines no rule |
| `elevated` | High risk — request extra reviewers or senior attention |

```rego
default review_tier := "standard"

review_tier := "auto" {
    input.technical_debt_delta <= 1.0
    not has_high_or_critical
}

review_tier := "elevated" {
    input.ai_generated == true
    has_high_or_critical
}
```

Semantics (normative):

- **Deny always wins.** `review_tier` is advisory routing for changes that may
  merge; it never affects `allowed` or the gate's exit code, and a blocked PR
  is never routed.
- **Absent rule = `standard`.** Policies without `review_tier` behave exactly
  as before; consumers treat the omitted field as `standard`.
- **Unknown values degrade safely.** An implementation MUST fall back to
  `standard` (with a warning) when a policy returns a value outside the enum,
  rather than failing the gate.

The tier appears in the [check output](https://github.com/open-delivery-spec/spec/blob/main/schemas/check-output/v1.json)
and is exercised by the `auto-clean-ai-change` and `elevated-ai-high-issue`
[conformance scenarios](https://github.com/open-delivery-spec/spec/tree/main/spec/conformance).

## Inspecting the Input

To see the exact object for the current diff, run the pipeline locally:

```bash
ods detect && ods analyze && ods score
ods check   # evaluates input against .ods/policy.rego
```
