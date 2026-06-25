package ods.policy

default allow := true

deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

# NOTE: test_coverage < 0 means "not measured" — skip coverage check
deny[msg] {
    input.ai_confidence > 0.8
    input.test_coverage >= 0
    input.test_coverage < 0.3
    msg := "AI code with low test coverage"
}
