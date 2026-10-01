# examples/ods-policy-enterprise.rego
# Copy to .ods/policy.rego in your repository.
#
# Enterprise policy: strict gates for production services.
# Blocks critical issues, high tech debt, and AI code in sensitive modules
# without sufficient test coverage.

package ods.policy

import rego.v1

default allow := true

# Block critical issues unconditionally
deny contains msg if {
    issue := input.issues[_]
    issue.severity == "critical"
    msg = sprintf("CRITICAL: %s at %s:%d — %s", [issue.rule, issue.file, issue.line, issue.message])
}

# Block AI code in payment/auth/billing without adequate test coverage
deny contains msg if {
    file := input.ai_files[_]
    regex.match(".*(payment|auth|billing|security).*", file.path)
    file.confidence > 0.5
    input.test_coverage >= 0
    input.test_coverage < 0.6
    pct := round(input.test_coverage * 100)
    msg = sprintf("AI code in sensitive module '%s' has insufficient test coverage (%d%% < 60%%)", [file.path, pct])
}

# Block excessive tech debt
deny contains msg if {
    input.technical_debt_delta > 5.0
    msg = sprintf("Technical debt increase %v exceeds block threshold (5.0)", [input.technical_debt_delta])
}

# Warn on high AI confidence with low test coverage
warn contains msg if {
    input.ai_generated == true
    input.ai_confidence > 0.7
    input.test_coverage >= 0
    input.test_coverage < 0.3
    conf := round(input.ai_confidence * 100)
    cov := round(input.test_coverage * 100)
    msg = sprintf("High-confidence AI code (%d%%) with low test coverage (%d%%)", [conf, cov])
}

# Warn on high issue count
warn contains msg if {
    count(input.issues) > 5
    msg = sprintf("High issue count: %d issues found — consider addressing before merge", [count(input.issues)])
}

# Warn on moderate tech debt
warn contains msg if {
    input.technical_debt_delta > 2.0
    input.technical_debt_delta <= 5.0
    msg = sprintf("Moderate technical debt increase: %v (threshold: 5.0)", [input.technical_debt_delta])
}
