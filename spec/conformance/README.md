# ODS Conformance Test Suite

This directory contains test cases for verifying that ODS pipeline implementations
correctly produce policy input matching the [Policy Input v1 schema](../../schemas/policy-input/v1.json).

## Test case format

Each subdirectory is one test scenario:

```
spec/conformance/<scenario>/
  input.json          # The policy input produced by the pipeline
  policy.rego         # The Rego policy to evaluate
  expected.json       # Expected check output (see schemas/check-output/v1.json):
                      #   {"allowed": bool, "denials": [...], "warnings": [...],
                      #    "review_tier": "auto|standard|elevated" (optional)}
```

When `expected.json` contains `review_tier`, a conforming implementation must
report that tier ([check output schema](../../schemas/check-output/v1.json));
implementations without review-routing support will fail those scenarios.

**Comparison semantics:** `denials` and `warnings` come from Rego partial sets
and are **unordered** — runners must compare them as sets, not ordered lists.
`allowed` and `review_tier` are scalar equality.

## Running the test suite

```bash
# Install ODS CLI
go install github.com/open-delivery-spec/cli/cmd/ods@latest

# Run a single scenario
ods check --policy spec/conformance/ai-no-tests/policy.rego  # run in a repo that matches the scenario

# Or validate with any OPA-compatible runner
opa eval -d spec/conformance/ai-no-tests/policy.rego \
         -I spec/conformance/ai-no-tests/input.json \
         'data.ods.policy'
```

## Scenarios

| Scenario | Description | Expected result |
|----------|-------------|-----------------|
| `pass-human-code` | Clean PR with no AI signals, no issues | PASS |
| `warn-ai-detected` | AI code detected but no quality issues | WARN |
| `block-critical-issue` | Critical quality issue → policy blocks | BLOCK |
| `block-ai-no-tests` | High-confidence AI code with low test coverage | BLOCK |
| `warn-detect-inconclusive` | Detection failed; pipeline degrades gracefully | WARN |
| `auto-clean-ai-change` | Clean, tested, low-debt AI change | PASS, `review_tier: auto` |
| `elevated-ai-high-issue` | AI change with a high finding — mergeable but risky | PASS, `review_tier: elevated` |
