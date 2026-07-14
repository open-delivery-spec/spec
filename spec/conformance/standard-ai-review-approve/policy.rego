package ods.policy

default allow := true

deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

# An AI reviewer's approve is inert: it appears in no rule below, so it can
# never qualify a change for the auto tier. This change misses auto on its
# own merits (debt 2.4 > 1.0) and the approve must not rescue it.
default review_tier := "standard"

review_tier := "auto" {
    input.technical_debt_delta <= 1.0
    not has_high_or_critical
    not ai_review_requests_changes
}

review_tier := "elevated" {
    ai_review_requests_changes
}

ai_review_requests_changes {
    input.ai_reviews[_].verdict == "request_changes"
}

has_high_or_critical {
    input.issues[_].severity == "critical"
}

has_high_or_critical {
    input.issues[_].severity == "high"
}
