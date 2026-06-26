---
title: Writing Policies (Rego)
layout: default
nav_order: 11
has_children: false
---

# Writing Policies in Rego

ODS enforces quality gates with [OPA Rego](https://www.openpolicyagent.org/docs/latest/policy-language/)
policies. The `ods check` stage evaluates your policy against the
[policy input](schemas.md) and decides whether a change is allowed.

This guide takes you from zero to a working custom policy. You don't need prior
Rego experience — the patterns here cover the large majority of real gates.

## Where the policy lives

Put your policy at **`.ods/policy.rego`**. ODS discovers it automatically; if no
file is found it falls back to a built-in default. Every policy starts the same way:

```rego
package ods.policy

default allow := true
```

- `package ods.policy` — required; ODS reads rules from this package.
- `default allow := true` — changes pass unless a `deny` rule fires.

## The three rule types

| Rule | Effect | Use for |
|------|--------|---------|
| `deny[msg]` | **Blocks** the change (check exits non-zero) | Hard gates — critical issues, untested sensitive code |
| `warn[msg]` | Surfaces a warning, does **not** block | Advisory signals — "consider adding tests" |
| `allow` | Defaults to `true`; a `deny` overrides it | Leave as the default in most policies |

Each `deny`/`warn` is a *set rule*: it can fire zero or more times, once per
matching item, and each produces a message string.

## Your first rule

Block any change that contains a critical-severity issue:

```rego
package ods.policy

default allow := true

deny[msg] {
    issue := input.issues[_]          # iterate every issue
    issue.severity == "critical"      # match critical ones
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}
```

`input.issues[_]` iterates the array; `[_]` binds each element in turn. When the
body holds for an element, `msg` is added to the `deny` set. Any non-empty `deny`
set blocks the change.

## The input you can read

Policies read from `input.*`. The full contract is the
[Policy Input Schema](schemas.md); the fields you'll use most:

| Field | Type | Example check |
|-------|------|---------------|
| `input.ai_generated` | bool | `input.ai_generated == true` |
| `input.ai_confidence` | 0.0–1.0 | `input.ai_confidence > 0.8` |
| `input.technical_debt_delta` | float | `input.technical_debt_delta > 5.0` |
| `input.test_coverage` | −1 or 0.0–1.0 | `input.test_coverage < 0.6` |
| `input.issues[_]` | array | `.severity`, `.rule`, `.file`, `.line` |
| `input.ai_files[_]` | array | `.path`, `.confidence`, `.ai_lines` |
| `input.changed_files[_]` | string[] | `endswith(input.changed_files[_], ".go")` |
| `input.branch` | string | `startswith(input.branch, "hotfix/")` |

## ⚠️ The test_coverage sentinel

`input.test_coverage` is **−1 when coverage was not measured** (no coverage file
found). A naive comparison treats "not measured" as 0% and produces false blocks:

```rego
# ❌ WRONG — fires on every PR that has no coverage tooling
deny[msg] {
    input.test_coverage < 0.6
    msg := "insufficient coverage"
}

# ✅ RIGHT — only enforce coverage when it was actually measured
deny[msg] {
    input.test_coverage >= 0
    input.test_coverage < 0.6
    msg := sprintf("coverage %.0f%% below 60%%", [input.test_coverage * 100])
}
```

Always guard coverage comparisons with `input.test_coverage >= 0`.

## Common patterns

**Sensitive modules need tests.** Block AI code in payment/auth paths unless
coverage is adequate:

```rego
deny[msg] {
    file := input.ai_files[_]
    regex.match(".*(payment|auth|billing|security).*", file.path)
    file.confidence > 0.5
    input.test_coverage >= 0
    input.test_coverage < 0.6
    msg := sprintf("AI code in sensitive module %s under 60%% coverage", [file.path])
}
```

**Cap technical debt.** Block large debt increases:

```rego
deny[msg] {
    input.technical_debt_delta > 5.0
    msg := sprintf("tech debt +%.1f exceeds threshold 5.0", [input.technical_debt_delta])
}
```

**Advise, don't block.** Warn on high-confidence AI with little testing:

```rego
warn[msg] {
    input.ai_generated == true
    input.ai_confidence > 0.7
    input.test_coverage >= 0
    input.test_coverage < 0.3
    msg := sprintf("AI code (%.0f%%) with low coverage", [input.ai_confidence * 100])
}
```

## Testing your policy locally

Run the pipeline against your working tree — no push required:

```bash
ods detect && ods analyze && ods score
ods check                 # evaluates .ods/policy.rego, exits non-zero if denied
ods check --json          # machine-readable result
ods check --debug         # prints every input value and each deny/warn (see why it fired)
```

`--debug` is the fastest way to understand a decision: it logs the detection
signals, score breakdown, coverage source, and every denial/warning to stderr
while keeping `--json` output clean.

## Ready-made starting points

Copy one of these to `.ods/policy.rego` and adapt:

- [`examples/ods-policy-oss.rego`](https://github.com/open-delivery-spec/spec/blob/main/examples/ods-policy-oss.rego) — permissive; blocks only critical issues
- [`examples/ods-policy-enterprise.rego`](https://github.com/open-delivery-spec/spec/blob/main/examples/ods-policy-enterprise.rego) — strict; sensitive-module and debt gates

The [conformance suite](https://github.com/open-delivery-spec/spec/tree/main/spec/conformance)
contains small policy + input + expected-output triples that double as worked examples.
