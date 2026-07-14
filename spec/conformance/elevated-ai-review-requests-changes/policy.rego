package ods.policy

default allow := true

deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

# AI reviewer verdicts are probabilistic: they only tighten routing, never
# deny. This change is otherwise auto-eligible (clean, tested, low debt) —
# the request_changes verdict must pull it to elevated instead.
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

warn[msg] {
    rev := input.ai_reviews[_]
    rev.verdict == "request_changes"
    msg := sprintf("AI reviewer %s requested changes (%d finding(s)) — extra review routed", [rev.tool, count(rev.findings)])
}
