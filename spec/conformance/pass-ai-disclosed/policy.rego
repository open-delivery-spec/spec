package ods.policy

default allow := true

deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

# Disclosure completeness: the author discloses AI involvement; heuristic
# suspicion without any attribution draws a nudge and extra review — never
# a block (heuristics have false positives).
ai_disclosed {
    input.detection_sources[_] == "commit-trailer"
}

ai_disclosed {
    input.detection_sources[_] == "git-ai-notes"
}

ai_disclosed {
    input.detection_sources[_] == "pr-body"
}

ai_undisclosed {
    input.ai_generated == true
    input.ai_confidence >= 0.5
    not ai_disclosed
}

warn[msg] {
    input.ai_generated == true
    not ai_disclosed
    msg := "AI code detected without author disclosure — ask for attribution"
}

default review_tier := "standard"

review_tier := "elevated" {
    ai_undisclosed
}
