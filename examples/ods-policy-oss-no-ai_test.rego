# Unit tests for examples/ods-policy-oss-no-ai.rego. Run them with the policy:
#
#   opa test examples/ods-policy-oss-no-ai.rego examples/ods-policy-oss-no-ai_test.rego
#
# (The templates share one package, so each is tested on its own;
# scripts/test-policies.sh runs them all.)
package ods.policy_test

import rego.v1

import data.ods.policy

refusal := "This project does not accept AI-generated contributions (see CONTRIBUTING.md). Thank you for disclosing it — please rewrite the change by hand, or open an issue to discuss it first"

suspicion := "AI assistance suspected (heuristics only) — a maintainer should confirm with the contributor before review"

human := {
	"ai_generated": false,
	"ai_confidence": 0,
	"detection_sources": [],
	"issues": [],
}

attested := object.union(human, {"ai_generated": true, "ai_confidence": 0.9, "detection_sources": ["commit-trailer"]})

suspected := object.union(human, {"ai_generated": true, "ai_confidence": 0.6, "detection_sources": ["branch-name", "diff-heuristics"]})

test_human_change_passes_silently if {
	policy.allow with input as human
	count(policy.deny) == 0 with input as human
	count(policy.warn) == 0 with input as human
	policy.review_tier == "standard" with input as human
}

test_critical_issue_denies if {
	critical := {"rule": "ai-unsafe-deserialization", "file": "src/parser.py", "line": 87, "severity": "critical"}
	policy.deny == {"CRITICAL: ai-unsafe-deserialization at src/parser.py:87"} with input as object.union(human, {"issues": [critical]})
}

test_attested_ai_is_refused_with_thanks if {
	policy.deny == {refusal} with input as attested
	count(policy.warn) == 0 with input as attested
}

test_every_disclosure_source_is_attested if {
	policy.deny == {refusal} with input as object.union(attested, {"detection_sources": ["git-ai-notes"]})
	policy.deny == {refusal} with input as object.union(attested, {"detection_sources": ["pr-body"]})
}

test_disclosure_without_ai_detected_is_not_refused if {
	count(policy.deny) == 0 with input as object.union(attested, {"ai_generated": false})
}

test_suspected_ai_is_routed_never_refused if {
	count(policy.deny) == 0 with input as suspected
	policy.warn == {suspicion} with input as suspected
	policy.review_tier == "elevated" with input as suspected
}

test_suspicion_threshold_is_inclusive if {
	policy.warn == {suspicion} with input as object.union(suspected, {"ai_confidence": 0.5})
	count(policy.warn) == 0 with input as object.union(suspected, {"ai_confidence": 0.4})
	policy.review_tier == "standard" with input as object.union(suspected, {"ai_confidence": 0.4})
}
