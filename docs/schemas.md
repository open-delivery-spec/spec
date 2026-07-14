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
| `ai_reviews` | array | | `check --ai-review` | AI code-reviewer verdicts (advisory by default — see below) |

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

### `ai_reviews[]` item shape

| Field | Type | Description |
|-------|------|-------------|
| `tool` | string | The reviewing tool, e.g. `claude-code`, `coderabbit` |
| `model` | string | Model used for the review, when known |
| `verdict` | string | `approve` \| `request_changes` \| `comment` |
| `findings` | array | Semantic findings: `{file, line, severity, category, message}` |

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

## AI Reviewer Verdicts: `input.ai_reviews`

Static analysis answers "does this code violate known rules?" — an AI code
reviewer answers a different question: "does this change look *correct*?"
ODS ingests those opinions as gate input without letting them take the gate
over. Reviewers (Claude Code `/review`, CodeRabbit, Copilot code review, …)
emit a **review verdict** document:

**[`schemas/review-verdict/v1.json`](https://github.com/open-delivery-spec/spec/blob/main/schemas/review-verdict/v1.json)**
(`$id`: `https://open-delivery-spec.dev/schemas/review-verdict/v1.json`)

```json
{
  "schema": "ods.dev/review-verdict/v1",
  "reviewer": { "tool": "claude-code", "model": "claude-opus-4-8" },
  "head_sha": "b8b56bd",
  "verdict": "request_changes",
  "findings": [
    {
      "file": "internal/auth/session.go",
      "line": 42,
      "severity": "high",
      "category": "correctness",
      "message": "Token expiry compared with local time; server skew bypasses the check"
    }
  ]
}
```

The reference implementation feeds these to the policy via
`ods check --ai-review verdict.json` (repeatable, one file per reviewer).

Semantics (normative):

- **Probabilistic signals only tighten, never loosen.** Deterministic
  findings (`input.issues`) may deny; an LLM verdict by default only routes
  more human attention. A `request_changes` verdict SHOULD raise
  `review_tier` to `elevated`; an `approve` MUST NOT loosen the gate — it
  must never qualify a change for the `auto` tier by itself. This keeps the
  gate safe even against a prompt-injected or over-optimistic reviewer.
- **Blocking is opt-in.** A team that wants LLM findings to deny writes it
  explicitly in its own policy over `input.ai_reviews`:

  ```rego
  deny[msg] {
      rev := input.ai_reviews[_]
      f := rev.findings[_]
      f.severity == "high"
      msg := sprintf("AI reviewer %s: %s (%s:%d)", [rev.tool, f.message, f.file, f.line])
  }
  ```

- **Stale verdicts never enter the gate.** Implementations MUST skip a
  verdict whose `head_sha` does not match the evaluated HEAD (SHA
  abbreviations of one another match, case-insensitively). An omitted
  `head_sha` means unstamped and applicable.
- **Malformed verdicts degrade safely.** A file that fails to parse or
  validate MUST be skipped with a warning, not fail the gate.

The `elevated-ai-review-requests-changes` and `standard-ai-review-approve`
[conformance scenarios](https://github.com/open-delivery-spec/spec/tree/main/spec/conformance)
exercise both directions: `request_changes` elevates without denying, and
`approve` does not unlock `auto`.

## Inspecting the Input

To see the exact object for the current diff, run the pipeline locally:

```bash
ods detect && ods analyze && ods score
ods check   # evaluates input against .ods/policy.rego
```
