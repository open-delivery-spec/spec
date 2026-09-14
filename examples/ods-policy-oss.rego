# examples/ods-policy-oss.rego
# Copy to .ods/policy.rego in your repository.
#
# Open-source project policy: permissive gates, focused on transparency.
# Blocks only critical security issues. Warns on everything else.

package ods.policy

default allow := true

# Block critical issues unconditionally
deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg = sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

# Warn when AI ratio is very high with no tests
warn[msg] {
    input.ai_generated == true
    input.ai_confidence > 0.9
    input.test_coverage >= 0
    input.test_coverage < 0.1
    pct := round(input.ai_confidence * 100)
    msg = sprintf("Fully AI-generated code (%d%% confidence) with less than 10%% test coverage", [pct])
}

# Warn on extreme tech debt
warn[msg] {
    input.technical_debt_delta > 8.0
    msg = sprintf("Large technical debt increase: %v (consider splitting this PR)", [input.technical_debt_delta])
}
