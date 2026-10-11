package ods.policy

default allow := true

deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

# Claims: what the PR description says, checked against the diff. An
# unverified claim warns always; for AI-authored changes it also routes to
# elevated. Deny stays opt-in.
default review_tier := "standard"

warn[msg] {
    c := input.merge_confidence.claims[_]
    c.verified == false
    msg := sprintf("The PR description claims %s, but the diff does not show it (%s)", [c.claim, c.evidence])
}

ai_unverified_claim {
    input.ai_generated
    input.merge_confidence.claims[_].verified == false
}

review_tier := "elevated" {
    ai_unverified_claim
}
