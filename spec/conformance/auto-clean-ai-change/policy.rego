package ods.policy

import rego.v1

default allow := true

deny contains msg if {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

# Review routing: deny always wins; the tier only routes allowed changes.
default review_tier := "standard"

review_tier := "auto" if {
    input.technical_debt_delta <= 1.0
    not has_high_or_critical
}

review_tier := "elevated" if {
    input.ai_generated == true
    has_high_or_critical
}

has_high_or_critical if {
    input.issues[_].severity == "critical"
}

has_high_or_critical if {
    input.issues[_].severity == "high"
}
