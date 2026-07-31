package ods.policy

default allow := true

deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

# Merge-confidence: deterministic diff facts. Adding source without tests warns
# always; for AI-authored changes it also routes to elevated. Deny stays opt-in.
default review_tier := "standard"

warn[msg] {
    input.merge_confidence.added_source_without_tests
    msg := "Source code changed but no tests were added or updated"
}

ai_undertested {
    input.ai_generated
    input.merge_confidence.added_source_without_tests
}

review_tier := "elevated" {
    ai_undertested
}
