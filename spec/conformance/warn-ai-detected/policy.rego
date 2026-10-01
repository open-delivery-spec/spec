package ods.policy

import rego.v1

default allow := true

deny contains msg if {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

deny contains msg if {
    input.ai_confidence > 0.8
    input.test_coverage >= 0
    input.test_coverage < 0.3
    msg := "AI code with low test coverage"
}

warn contains msg if {
    input.ai_generated
    msg := "AI-generated code detected — ensure human review"
}
