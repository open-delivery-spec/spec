# Unit tests for the walkthrough policy (.ods/policy.rego next to this file).
# Run them from the repository root with the policy:
#
#   opa test examples/walkthrough/.ods/policy.rego examples/walkthrough/.ods/policy_test.rego
package ods.policy_test

import rego.v1

import data.ods.policy

# The Semgrep finding from the walkthrough, as `ods analyze --sarif` carries
# it into the policy input: the tool's own rule id, ERROR mapped to high.
semgrep_finding := {
	"rule": "python-subprocess-shell-true",
	"file": "app/runner.py",
	"line": 11,
	"severity": "high",
	"message": "subprocess called with shell=True on untrusted input — command injection risk.",
}

test_the_walkthrough_finding_blocks_the_merge if {
	policy.deny == {"high: python-subprocess-shell-true (app/runner.py:11)"} with input as {"issues": [semgrep_finding]}
}

test_critical_findings_block if {
	finding := object.union(semgrep_finding, {"severity": "critical"})
	policy.deny == {"critical: python-subprocess-shell-true (app/runner.py:11)"} with input as {"issues": [finding]}
}

test_lower_severities_pass if {
	findings := [
		object.union(semgrep_finding, {"severity": "medium"}),
		object.union(semgrep_finding, {"severity": "low"}),
		object.union(semgrep_finding, {"severity": "info"}),
	]
	count(policy.deny) == 0 with input as {"issues": findings}
	policy.allow with input as {"issues": findings}
}

test_the_fixed_change_passes if {
	count(policy.deny) == 0 with input as {"issues": []}
}
