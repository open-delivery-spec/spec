# examples/ods-policy-enterprise.rego
# Copy to .ods/policy.rego in your repository.
#
# Enterprise policy: strict gates for production services.
# Blocks critical issues, high tech debt, and AI code in sensitive modules
# without sufficient test coverage.

package ods.policy

default allow := true

# Block critical issues unconditionally
deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg = sprintf("CRITICAL: %s at %s:%d — %s", [issue.rule, issue.file, issue.line, issue.message])
}

# Block AI code in payment/auth/billing without adequate test coverage
deny[msg] {
    file := input.ai_files[_]
    regex.match(".*(payment|auth|billing|security).*", file.path)
    file.confidence > 0.5
    input.test_coverage < 0.6
    msg = sprintf("AI code in sensitive module '%s' has insufficient test coverage (%.0f%% < 60%%)", [file.path, input.test_coverage * 100.0])
}

# Block excessive tech debt
deny[msg] {
    input.technical_debt_delta > 5.0
    msg = sprintf("Technical debt increase %.1f exceeds block threshold (5.0)", [input.technical_debt_delta * 1.0])
}

# Warn on high AI confidence with low test coverage
warn[msg] {
    input.ai_generated == true
    input.ai_confidence > 0.7
    input.test_coverage < 0.3
    msg = sprintf("High-confidence AI code (%.0f%%) with low test coverage (%.0f%%)", [input.ai_confidence * 100.0, input.test_coverage * 100.0])
}

# Warn on high issue count
warn[msg] {
    count(input.issues) > 5
    msg = sprintf("High issue count: %d issues found — consider addressing before merge", [count(input.issues)])
}

# Warn on moderate tech debt
warn[msg] {
    input.technical_debt_delta > 2.0
    input.technical_debt_delta <= 5.0
    msg = sprintf("Moderate technical debt increase: %.1f (threshold: 5.0)", [input.technical_debt_delta * 1.0])
}
