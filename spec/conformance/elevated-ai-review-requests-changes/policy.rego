package ods.policy

import rego.v1

default allow := true

deny contains msg if {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

# AI reviewer verdicts are probabilistic: they only tighten routing, never
# deny. This change is otherwise auto-eligible (clean, tested, low debt) —
# the request_changes verdict must pull it to elevated instead.
default review_tier := "standard"

review_tier := "auto" if {
    input.technical_debt_delta <= 1.0
    not has_high_or_critical
    not ai_review_requests_changes
}

review_tier := "elevated" if {
    ai_review_requests_changes
}

ai_review_requests_changes if {
    input.ai_reviews[_].verdict == "request_changes"
}

has_high_or_critical if {
    input.issues[_].severity == "critical"
}

has_high_or_critical if {
    input.issues[_].severity == "high"
}

warn contains msg if {
    rev := input.ai_reviews[_]
    rev.verdict == "request_changes"
    msg := sprintf("AI reviewer %s requested changes (%d finding(s)) — extra review routed", [rev.tool, count(rev.findings)])
}
