# Conformance harness for plain OPA: checks that a scenario's policy.rego,
# evaluated on its input.json, yields its expected.json under the suite's
# comparison semantics (README.md): `allowed` and `review_tier` are scalars,
# `denials` and `warnings` are sets. `allowed` is what an implementation
# reports: the policy's `allow` (true by default), false once a deny fires.
#
# The scenarios share one package, so each runs on its own, with its input
# and expected documents loaded under data.conformance:
#
#   opa test spec/conformance/conformance_test.rego \
#     spec/conformance/block-ai-no-tests/policy.rego \
#     conformance.input:spec/conformance/block-ai-no-tests/input.json \
#     conformance.expected:spec/conformance/block-ai-no-tests/expected.json
#
# scripts/test-policies.sh runs every scenario this way. It checks the
# policies in isolation; an implementation's output shape and exit code are
# checked by running the suite through it.
package conformance_test

import rego.v1

result := r if {
	r := data.ods.policy with input as data.conformance.input
}

expected := data.conformance.expected

denials := {d | some d in object.get(result, "deny", set())}

warnings := {w | some w in object.get(result, "warn", set())}

allowed := false if count(denials) > 0

allowed := object.get(result, "allow", true) if count(denials) == 0

review_tier := object.get(result, "review_tier", "")

test_allowed if {
	print("allowed: got", allowed, "want", expected.allowed)
	allowed == expected.allowed
}

test_denials if {
	want := {d | some d in object.get(expected, "denials", [])}
	print("denials: got", denials, "want", want)
	denials == want
}

test_warnings if {
	want := {w | some w in object.get(expected, "warnings", [])}
	print("warnings: got", warnings, "want", want)
	warnings == want
}

test_review_tier if {
	want := object.get(expected, "review_tier", "")
	print("review_tier: got", review_tier, "want", want)
	review_tier == want
}

test_review_tier_is_a_known_tier if {
	review_tier in {"", "auto", "standard", "elevated"}
}
