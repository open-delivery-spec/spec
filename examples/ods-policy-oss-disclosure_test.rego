# Unit tests for examples/ods-policy-oss-disclosure.rego (also this
# repository's .ods/policy.rego). Run them with the policy:
#
#   opa test examples/ods-policy-oss-disclosure.rego examples/ods-policy-oss-disclosure_test.rego
#
# (The templates share one package, so each is tested on its own;
# scripts/test-policies.sh runs them all.) The STRICT blocks ship commented
# out; scripts/check-example-policies.sh checks them uncommented.
package ods.policy_test

import rego.v1

import data.ods.policy

nudge := "AI assistance suspected but not disclosed — add a Co-Authored-By or Assisted-by trailer, or tick the AI disclosure in the PR description (see CONTRIBUTING.md)"

untested := "AI-assisted change adds source code but no test was added or updated (see CONTRIBUTING.md)"

# A human change with nothing to report.
human := {
	"ai_generated": false,
	"ai_confidence": 0,
	"detection_sources": [],
	"issues": [],
	"technical_debt_delta": 0,
	"patch_coverage": -1,
	"merge_confidence": {"tests_touched": true, "added_source_without_tests": false},
}

# The fast lane: disclosed, tested, clean, low-debt AI change.
disclosed := object.union(human, {
	"ai_generated": true,
	"ai_confidence": 0.9,
	"detection_sources": ["commit-trailer"],
	"technical_debt_delta": 0.4,
	"patch_coverage": 0.9,
})

# AI suspected from the branch name alone, nothing disclosed.
suspected := object.union(human, {
	"ai_generated": true,
	"ai_confidence": 0.6,
	"detection_sources": ["branch-name"],
})

critical := {"rule": "ai-unsafe-deserialization", "file": "src/parser.py", "line": 87, "severity": "critical"}

high := object.union(critical, {"severity": "high"})

test_human_change_is_standard_and_silent if {
	policy.allow with input as human
	count(policy.deny) == 0 with input as human
	count(policy.warn) == 0 with input as human
	policy.review_tier == "standard" with input as human
}

# ── 0. Hard gate ──────────────────────────────────────────────────────────

test_critical_issue_denies if {
	policy.deny == {"CRITICAL: ai-unsafe-deserialization at src/parser.py:87"} with input as object.union(human, {"issues": [critical]})
}

test_high_issue_does_not_deny if {
	count(policy.deny) == 0 with input as object.union(disclosed, {"issues": [high]})
}

# ── 1. Disclose it ────────────────────────────────────────────────────────

test_suspected_ai_is_nudged_and_elevated_never_denied if {
	policy.warn == {nudge} with input as suspected
	policy.review_tier == "elevated" with input as suspected
	count(policy.deny) == 0 with input as suspected
}

test_every_disclosure_source_silences_the_nudge if {
	count(policy.warn) == 0 with input as object.union(suspected, {"detection_sources": ["branch-name", "commit-trailer"]})
	count(policy.warn) == 0 with input as object.union(suspected, {"detection_sources": ["branch-name", "git-ai-notes"]})
	count(policy.warn) == 0 with input as object.union(suspected, {"detection_sources": ["branch-name", "pr-body"]})
}

test_suspicion_signals_are_not_disclosure if {
	policy.warn == {nudge} with input as object.union(suspected, {"detection_sources": ["branch-name", "diff-heuristics"]})
}

test_nudge_threshold_is_inclusive if {
	policy.warn == {nudge} with input as object.union(suspected, {"ai_confidence": 0.5})
	count(policy.warn) == 0 with input as object.union(suspected, {"ai_confidence": 0.4})
	policy.review_tier == "standard" with input as object.union(suspected, {"ai_confidence": 0.4})
}

# ── 2. Test it ────────────────────────────────────────────────────────────

ai_untested := object.union(disclosed, {"merge_confidence": {"tests_touched": false, "added_source_without_tests": true}})

test_untested_ai_source_is_flagged_and_elevated if {
	policy.warn == {untested} with input as ai_untested
	policy.review_tier == "elevated" with input as ai_untested
	count(policy.deny) == 0 with input as ai_untested
}

test_untested_signal_keeps_a_change_out_of_the_fast_lane if {
	# The reference CLI never reports a test touched and source added without
	# tests together, but the policy must not rely on it: were the fast lane
	# to ignore the signal, both tiers would fire and OPA would fail the
	# evaluation with a conflict.
	both := object.union(disclosed, {"merge_confidence": {"tests_touched": true, "added_source_without_tests": true}})
	policy.review_tier == "elevated" with input as both
}

test_untested_human_source_is_not_flagged if {
	count(policy.warn) == 0 with input as object.union(ai_untested, {"ai_generated": false})
	policy.review_tier == "standard" with input as object.union(ai_untested, {"ai_generated": false})
}

test_low_patch_coverage_is_flagged_and_elevated if {
	policy.warn == {"AI-assisted change: only 40% of its added lines are covered by tests (threshold 70%)"} with input as object.union(disclosed, {"patch_coverage": 0.4})
	policy.review_tier == "elevated" with input as object.union(disclosed, {"patch_coverage": 0.4})
	policy.warn == {"AI-assisted change: only 0% of its added lines are covered by tests (threshold 70%)"} with input as object.union(disclosed, {"patch_coverage": 0})
}

test_patch_coverage_at_threshold_or_unmeasured_is_fine if {
	count(policy.warn) == 0 with input as object.union(disclosed, {"patch_coverage": 0.7})
	count(policy.warn) == 0 with input as object.union(disclosed, {"patch_coverage": -1})
	policy.review_tier == "auto" with input as object.union(disclosed, {"patch_coverage": -1})
}

test_low_patch_coverage_of_human_code_is_not_flagged if {
	count(policy.warn) == 0 with input as object.union(human, {"patch_coverage": 0.1})
}

# ── 3. Own it ─────────────────────────────────────────────────────────────

risky := object.union(disclosed, {"merge_confidence": object.union(disclosed.merge_confidence, {"risky_paths": [".github/workflows/ci.yml", "go.mod"]})})

test_each_sensitive_path_is_named_and_elevated if {
	policy.warn == {
		"AI-assisted change touches a sensitive path (.github/workflows/ci.yml) — maintainer review required",
		"AI-assisted change touches a sensitive path (go.mod) — maintainer review required",
	} with input as risky
	policy.review_tier == "elevated" with input as risky
	count(policy.deny) == 0 with input as risky
}

test_sensitive_path_in_human_change_is_not_flagged if {
	count(policy.warn) == 0 with input as object.union(risky, {"ai_generated": false})
	policy.review_tier == "standard" with input as object.union(risky, {"ai_generated": false})
}

test_ai_review_request_changes_elevates_without_denying if {
	reviewed := object.union(disclosed, {"ai_reviews": [{"tool": "claude-code", "verdict": "request_changes"}]})
	policy.review_tier == "elevated" with input as reviewed
	count(policy.deny) == 0 with input as reviewed
	count(policy.warn) == 0 with input as reviewed
}

test_ai_review_approve_never_loosens if {
	# misses the fast lane on its own merits (debt above 1.0)
	approved := object.union(disclosed, {"technical_debt_delta": 2.4, "ai_reviews": [{"tool": "claude-code", "verdict": "approve"}]})
	policy.review_tier == "standard" with input as approved
}

# ── Fast lane ─────────────────────────────────────────────────────────────

test_disclosed_tested_clean_change_is_auto if {
	policy.review_tier == "auto" with input as disclosed
	count(policy.warn) == 0 with input as disclosed
	count(policy.deny) == 0 with input as disclosed
}

test_fast_lane_needs_every_condition if {
	# undisclosed, below the nudge threshold: no warning, but no fast lane
	policy.review_tier == "standard" with input as object.union(disclosed, {"ai_confidence": 0.3, "detection_sources": ["diff-heuristics"]})

	# no test touched
	policy.review_tier == "standard" with input as object.union(disclosed, {"merge_confidence": {"tests_touched": false, "added_source_without_tests": false}})

	# debt above 1.0
	policy.review_tier == "standard" with input as object.union(disclosed, {"technical_debt_delta": 1.5})

	# a high finding
	policy.review_tier == "standard" with input as object.union(disclosed, {"issues": [high]})

	# not AI-assisted at all
	policy.review_tier == "standard" with input as object.union(disclosed, {"ai_generated": false})
}

test_debt_at_the_fast_lane_threshold_is_auto if {
	policy.review_tier == "auto" with input as object.union(disclosed, {"technical_debt_delta": 1})
}

test_critical_issue_denies_and_leaves_the_fast_lane if {
	blocked := object.union(disclosed, {"issues": [critical]})
	count(policy.deny) == 1 with input as blocked
	policy.review_tier == "standard" with input as blocked
}
