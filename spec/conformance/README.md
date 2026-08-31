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

A conforming implementation must also **exit non-zero when `allowed` is false**.
The exit code is what blocks a merge in CI, so it is part of conformance, not an
implementation detail.

Fields a scenario's `input.json` omits are **not measured**, which the input
schema represents as the `-1` sentinel (`test_coverage`, `patch_coverage`,
`mutation_score`). An implementation that reads an absent field as `0` will fire
coverage rules the scenario never intended.

**Comparison semantics:** `denials` and `warnings` come from Rego partial sets
and are **unordered** — runners must compare them as sets, not ordered lists.
`allowed` and `review_tier` are scalar equality.

## Running the test suite

A scenario is a policy input plus a policy, so it runs without a matching
repository. `ods check --input` evaluates the prepared input directly:

```bash
# Install ODS CLI
go install github.com/open-delivery-spec/cli/cmd/ods@latest

# Run a single scenario
ods check --input spec/conformance/block-ai-no-tests/input.json \
          --policy spec/conformance/block-ai-no-tests/policy.rego \
          --json

# Run every scenario
for dir in spec/conformance/*/; do
  [ -f "$dir/input.json" ] || continue
  echo "== $(basename "$dir")"
  ods check --input "$dir/input.json" --policy "$dir/policy.rego" --json
done
```

Any OPA-compatible runner also works, but it checks the policy in isolation
rather than an implementation's output shape and exit code:

```bash
opa eval -d spec/conformance/block-ai-no-tests/policy.rego \
         -I spec/conformance/block-ai-no-tests/input.json \
         'data.ods.policy'
```

The reference implementation runs this suite in its own CI at both layers —
policy evaluation and the CLI contract — so a scenario added here fails the
CLI build until it is satisfied.

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
| `elevated-ai-review-requests-changes` | Otherwise auto-eligible change, but an AI reviewer requested changes | PASS, WARN, `review_tier: elevated` |
| `standard-ai-review-approve` | AI reviewer approves, but the change misses `auto` on its own merits — an approve never loosens the gate | PASS, `review_tier: standard` |
| `warn-ai-undisclosed` | AI suspected (branch + heuristics) but the author disclosed nothing — nudge and route, never block | PASS, WARN, `review_tier: elevated` |
| `pass-ai-disclosed` | Same change with a `commit-trailer` disclosure — attribution silences the nudge | PASS, `review_tier: standard` |
| `warn-ai-no-tests` | AI-authored change adds source but no tests — warn and route, never block | PASS, WARN, `review_tier: elevated` |
| `pass-tested-change` | Same change with a test added — the signal is cleared | PASS, `review_tier: standard` |
| `warn-ai-low-patch-coverage` | AI-authored change whose added lines are under-covered (patch coverage 40%) — warn and route, never block | PASS, WARN, `review_tier: elevated` |
| `pass-ai-covered-patch` | Same change with its added lines fully covered — the signal is cleared | PASS, `review_tier: standard` |
| `warn-ai-weak-mutation` | AI-authored change whose added lines have a weak mutation score (30%) — warn and route, never block | PASS, WARN, `review_tier: elevated` |
| `pass-ai-strong-mutation` | Same change with a strong mutation score — the signal is cleared | PASS, `review_tier: standard` |
| `evidence-inferred-elevated` | AI attribution is only `inferred` (branch + heuristics) — route to extra review | PASS, `review_tier: elevated` |
| `evidence-attested-auto` | Same change with `attested` attribution (commit trailer) — trusted enough to stay standard | PASS, `review_tier: standard` |
