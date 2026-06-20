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

## Policy Input Fields

| Field | Type | Produced by | Description |
|-------|------|-------------|-------------|
| `ai_generated` | bool | `detect` | Whether AI code was detected in the diff |
| `ai_confidence` | float (0.0–1.0) | `detect` | Aggregate detection confidence |
| `issues` | array | `analyze` | Quality issues found; each item has `rule`, `severity`, `file`, `line` |
| `technical_debt_delta` | float | `score` | Weighted technical-debt impact of the PR |
| `test_coverage` | float (0.0–1.0) | `score` | Test coverage ratio for the change |
| `branch` | string | context | The PR's head branch name |

### `issues[]` item shape

| Field | Type | Description |
|-------|------|-------------|
| `rule` | string | Rule id, e.g. `ai-unsafe-deserialization` |
| `severity` | string | `low` \| `medium` \| `high` \| `critical` |
| `file` | string | Path to the affected file |
| `line` | integer | Line number of the finding |

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

## Inspecting the Input

To see the exact object for the current diff, run the pipeline locally:

```bash
ods detect && ods analyze && ods score
ods check   # evaluates input against .ods/policy.rego
```
