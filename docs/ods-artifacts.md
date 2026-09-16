---
title: ODS Artifacts
nav_order: 7
---

# `.ods/` Artifact Directory Convention

ODS keeps its repository-local configuration under a `.ods/` directory at the repository root. The check works with **no configuration at all**; `.ods/` only exists when you want to enforce your own policy.

## Directory Layout

```
repository-root/
├── .ods/
│   └── policy.rego          # OPA Rego enforcement policy (optional)
└── ...
```

That's the whole convention: one optional file. If `.ods/policy.rego` is absent,
`ods check` applies a permissive default (only critical issues block).

`ods check` looks for the policy in this order, taking the first that exists —
`--policy` overrides the search entirely:

| Order | Path |
|-------|------|
| 1 | `.ods/policy.rego` (recommended) |
| 2 | `.ods.rego` |
| 3 | `policy.rego` |

## `.ods/policy.rego` — Enforcement Policy

The `check` stage evaluates each PR against an [OPA Rego](https://www.openpolicyagent.org/docs/latest/policy-language/) policy. Place it at `.ods/policy.rego`:

```rego
package ods.policy

default allow := true

# Block critical issues unconditionally
deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

# Block high-confidence AI code with low test coverage.
# -1 means "not measured": guard with >= 0 or the rule fires on every
# repository without coverage tooling.
deny[msg] {
    input.ai_confidence > 0.8
    input.test_coverage >= 0
    input.test_coverage < 0.3
    msg := "AI code with low test coverage"
}

# Warn on high-confidence AI with multiple quality issues
warn[msg] {
    input.ai_generated == true
    input.ai_confidence > 0.8
    count(input.issues) > 2
    msg := "High-confidence AI code with multiple quality issues"
}
```

### Policy Input Fields

Every field the policy can read, with its type, which stage produces it and
its sentinels, is in the [Policy Input Schema](schemas.md); the patterns for
using them are in [Writing Policies (Rego)](policy-authoring.md).

> [!TIP]
> Run `ods check` locally to evaluate the policy against the current diff before you push.

## Configuring the CLI

There is no ODS configuration file beyond the policy. The CLI is configured by
command-line flags, and by environment variables where CI needs to override what
the CLI would otherwise infer from the checkout:

| Variable | Effect |
|----------|--------|
| `ODS_DIFF_BASE` | Ref to diff against, instead of `HEAD~1`. CI sets it to the PR base so the whole PR is analysed, not just the last commit |
| `ODS_BRANCH` | Branch name, when the checkout does not carry it (`ODS_BRANCH_NAME` is accepted as an alias) |
| `ODS_HEAD_SHA` | Commit that AI review verdicts are matched against. On `pull_request` events CI checks out a synthetic merge commit, which is not the SHA reviewers stamped |
| `ODS_DEBUG` | Set to `1` to print decision diagnostics to stderr (same as `--debug`) |

Everything else — the policy path, SARIF and mutation reports, review verdicts —
is passed per invocation as a flag. See the
[CLI README](https://github.com/open-delivery-spec/cli#readme) for the full list.

## Should I commit `.ods/` ?

Yes. `.ods/policy.rego` is part of your repository's quality configuration and should be version-controlled like any other CI config. If your workflow generates transient files, ignore those specifically:

```gitignore
# ODS transient artifacts
.ods/tmp/
.ods/cache/
```

## Relationship to Other Standards

| Standard | Scope | Relationship |
|----------|-------|--------------|
| SLSA | Build provenance | Complementary — SLSA secures the build; ODS gates the change |
| in-toto | Supply-chain metadata | Complementary — different layer |
| OPA / Rego | Policy language | ODS uses Rego directly for `ods check` |

