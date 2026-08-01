package ods.policy

default allow := true

deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

# Mutation score (diff-scoped): do the tests catch changes to the new code, not
# just run it? For AI-authored changes a weak score warns and routes to
# elevated. -1 = not measured, so guard with >= 0. Mutation scores run lower
# than coverage, so the threshold is lower. Deny stays opt-in.
default review_tier := "standard"

ai_weak_mutation_score {
    input.ai_generated == true
    input.mutation_score >= 0
    input.mutation_score < 0.5
}

warn[msg] {
    ai_weak_mutation_score
    pct := round(input.mutation_score * 100)
    msg := sprintf("AI-authored change: tests kill only %d%% of mutations on the added lines", [pct])
}

review_tier := "elevated" {
    ai_weak_mutation_score
}
