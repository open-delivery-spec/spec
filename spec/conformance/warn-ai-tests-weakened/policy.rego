package ods.policy

default allow := true

deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

# Test weakening: a deleted test file, an added skip, more assertions removed
# than added. Each warns always; an AI-authored change that weakens its tests
# routes to elevated. Deny stays opt-in.
default review_tier := "standard"

warn[msg] {
    f := input.merge_confidence.test_weakening.deleted_test_files[_]
    msg := sprintf("Test file deleted: %s", [f])
}

warn[msg] {
    n := input.merge_confidence.test_weakening.skips_added
    n > 0
    msg := sprintf("Test skips added: %d", [n])
}

warn[msg] {
    w := input.merge_confidence.test_weakening
    w.assertions_removed > w.assertions_added
    msg := sprintf("Assertions removed: %d, added: %d", [w.assertions_removed, w.assertions_added])
}

review_tier := "elevated" {
    input.ai_generated
    input.merge_confidence.tests_weakened
}
