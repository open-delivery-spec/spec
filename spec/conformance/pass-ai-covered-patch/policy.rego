package ods.policy

import rego.v1

default allow := true

deny contains msg if {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

# Patch coverage: coverage of the diff's ADDED lines. For AI-authored changes,
# under-covered new code warns and routes to elevated. -1 = not measured, so
# guard with >= 0. Deny stays opt-in.
default review_tier := "standard"

ai_low_patch_coverage if {
    input.ai_generated == true
    input.patch_coverage >= 0
    input.patch_coverage < 0.8
}

warn contains msg if {
    ai_low_patch_coverage
    pct := round(input.patch_coverage * 100)
    msg := sprintf("AI-authored change: only %d%% of added lines are covered by tests", [pct])
}

review_tier := "elevated" if {
    ai_low_patch_coverage
}
