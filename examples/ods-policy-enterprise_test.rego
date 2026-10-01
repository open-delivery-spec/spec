# Unit tests for examples/ods-policy-enterprise.rego. Run them with the policy:
#
#   opa test examples/ods-policy-enterprise.rego examples/ods-policy-enterprise_test.rego
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
	"ai_files": [],
	"issues": [],
	"technical_debt_delta": 0,
	"test_coverage": 0.8,
}

critical := {
	"rule": "ai-unsafe-deserialization",
	"file": "src/parser.py",
	"line": 87,
	"severity": "critical",
	"message": "json.Unmarshal into interface{}",
}

medium := {"rule": "ai-inconsistent-pattern", "file": "src/util.go", "line": 4, "severity": "medium", "message": "mixed naming"}

test_clean_change_passes_silently if {
	policy.allow with input as clean
	count(policy.deny) == 0 with input as clean
	count(policy.warn) == 0 with input as clean
}

# ── Critical issues ───────────────────────────────────────────────────────

test_critical_issue_denies_with_its_message if {
	high := object.union(critical, {"severity": "high"})
	policy.deny == {"CRITICAL: ai-unsafe-deserialization at src/parser.py:87 — json.Unmarshal into interface{}"} with input as object.union(clean, {"issues": [critical, high]})
}

test_critical_issue_without_a_message_still_denies if {
	# `message` is optional on an issue (schemas/policy-input/v1.json); the
	# denial must not depend on it
	unlabelled := object.remove(critical, ["message"])
	policy.deny == {"CRITICAL: ai-unsafe-deserialization at src/parser.py:87"} with input as object.union(clean, {"issues": [unlabelled]})

	# nor leave a dangling separator when the message is empty
	blank := object.union(critical, {"message": ""})
	policy.deny == {"CRITICAL: ai-unsafe-deserialization at src/parser.py:87"} with input as object.union(clean, {"issues": [blank]})
}

# ── AI code in sensitive modules ──────────────────────────────────────────

payment_file := {"path": "src/payment/charge.go", "ai_lines": 40, "total_lines": 50, "confidence": 0.9}

sensitive := object.union(clean, {"ai_generated": true, "ai_confidence": 0.6, "ai_files": [payment_file], "test_coverage": 0.4})

test_ai_code_in_sensitive_module_needs_coverage if {
	policy.deny == {"AI code in sensitive module 'src/payment/charge.go' has insufficient test coverage (40% < 60%)"} with input as sensitive
}

test_each_sensitive_module_denies_on_its_own if {
	files := [
		object.union(payment_file, {"path": "internal/auth/token.go"}),
		object.union(payment_file, {"path": "billing/invoice.py"}),
		object.union(payment_file, {"path": "pkg/security/acl.go"}),
	]
	count(policy.deny) == 3 with input as object.union(sensitive, {"ai_files": files})
}

test_sensitive_module_rule_needs_every_condition if {
	# not a sensitive path
	count(policy.deny) == 0 with input as object.union(sensitive, {"ai_files": [object.union(payment_file, {"path": "src/report/render.go"})]})

	# attribution not confident enough (the threshold is exclusive)
	count(policy.deny) == 0 with input as object.union(sensitive, {"ai_files": [object.union(payment_file, {"confidence": 0.5})]})

	# coverage at the threshold
	count(policy.deny) == 0 with input as object.union(sensitive, {"test_coverage": 0.6})

	# coverage not measured
	count(policy.deny) == 0 with input as object.union(sensitive, {"test_coverage": -1})
}

# ── Technical debt ────────────────────────────────────────────────────────

test_excessive_debt_denies if {
	policy.deny == {"Technical debt increase 5.5 exceeds block threshold (5.0)"} with input as object.union(clean, {"technical_debt_delta": 5.5})
	count(policy.warn) == 0 with input as object.union(clean, {"technical_debt_delta": 5.5})
}

test_moderate_debt_warns_without_denying if {
	policy.warn == {"Moderate technical debt increase: 3 (threshold: 5.0)"} with input as object.union(clean, {"technical_debt_delta": 3})
	count(policy.deny) == 0 with input as object.union(clean, {"technical_debt_delta": 3})

	# the upper bound is inclusive: 5.0 still only warns
	count(policy.deny) == 0 with input as object.union(clean, {"technical_debt_delta": 5})
	count(policy.warn) == 1 with input as object.union(clean, {"technical_debt_delta": 5})
}

test_small_debt_is_silent if {
	count(policy.warn) == 0 with input as object.union(clean, {"technical_debt_delta": 2})
}

# ── Confident AI code with little coverage ────────────────────────────────

ai_untested := object.union(clean, {"ai_generated": true, "ai_confidence": 0.8, "test_coverage": 0.2})

test_confident_ai_with_low_coverage_warns if {
	policy.warn == {"High-confidence AI code (80%) with low test coverage (20%)"} with input as ai_untested
	count(policy.deny) == 0 with input as ai_untested
}

test_low_coverage_warning_needs_every_condition if {
	count(policy.warn) == 0 with input as object.union(ai_untested, {"ai_generated": false})
	count(policy.warn) == 0 with input as object.union(ai_untested, {"ai_confidence": 0.7})
	count(policy.warn) == 0 with input as object.union(ai_untested, {"test_coverage": 0.3})
	count(policy.warn) == 0 with input as object.union(ai_untested, {"test_coverage": -1})
}

# ── Issue count ───────────────────────────────────────────────────────────

test_many_issues_warn if {
	issues := [medium, medium, medium, medium, medium, medium]
	policy.warn == {"High issue count: 6 issues found — consider addressing before merge"} with input as object.union(clean, {"issues": issues})
}

test_five_issues_are_not_many if {
	count(policy.warn) == 0 with input as object.union(clean, {"issues": [medium, medium, medium, medium, medium]})
}
