# Unit tests for examples/ods-policy-oss.rego. Run them with the policy:
#
#   opa test examples/ods-policy-oss.rego examples/ods-policy-oss_test.rego
#
# (The templates share one package, so each is tested on its own;
# scripts/test-policies.sh runs them all.)
package ods.policy_test

import rego.v1

import data.ods.policy

# A human change with nothing to report: the baseline every case varies.
clean := {
	"ai_generated": false,
	"ai_confidence": 0,
	"issues": [],
	"technical_debt_delta": 0,
	"test_coverage": 0.8,
}

critical := {"rule": "ai-unsafe-deserialization", "file": "src/parser.py", "line": 87, "severity": "critical"}

high := {"rule": "ai-hallucinated-api", "file": "src/client.go", "line": 12, "severity": "high"}

test_clean_change_passes_silently if {
	policy.allow with input as clean
	count(policy.deny) == 0 with input as clean
	count(policy.warn) == 0 with input as clean
}

test_critical_issue_denies if {
	policy.deny == {"CRITICAL: ai-unsafe-deserialization at src/parser.py:87"} with input as object.union(clean, {"issues": [critical, high]})
}

test_each_critical_issue_denies_on_its_own if {
	second := object.union(critical, {"file": "src/codec.py", "line": 3})
	count(policy.deny) == 2 with input as object.union(clean, {"issues": [critical, second]})
}

test_non_critical_issues_do_not_deny if {
	count(policy.deny) == 0 with input as object.union(clean, {"issues": [high]})
}

fully_ai_untested := object.union(clean, {"ai_generated": true, "ai_confidence": 0.95, "test_coverage": 0.05})

test_confident_ai_with_little_coverage_warns if {
	policy.warn == {"Fully AI-generated code (95% confidence) with less than 10% test coverage"} with input as fully_ai_untested
	count(policy.deny) == 0 with input as fully_ai_untested
}

test_unmeasured_coverage_does_not_warn if {
	count(policy.warn) == 0 with input as object.union(fully_ai_untested, {"test_coverage": -1})
}

test_ai_warning_thresholds_are_exclusive if {
	count(policy.warn) == 0 with input as object.union(fully_ai_untested, {"ai_confidence": 0.9})
	count(policy.warn) == 0 with input as object.union(fully_ai_untested, {"test_coverage": 0.1})
}

test_human_change_with_little_coverage_does_not_warn if {
	count(policy.warn) == 0 with input as object.union(fully_ai_untested, {"ai_generated": false})
}

test_extreme_debt_warns_but_does_not_deny if {
	policy.warn == {"Large technical debt increase: 8.5 (consider splitting this PR)"} with input as object.union(clean, {"technical_debt_delta": 8.5})
	count(policy.deny) == 0 with input as object.union(clean, {"technical_debt_delta": 8.5})
}

test_debt_at_the_threshold_does_not_warn if {
	count(policy.warn) == 0 with input as object.union(clean, {"technical_debt_delta": 8})
}
