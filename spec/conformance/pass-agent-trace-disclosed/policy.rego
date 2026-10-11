package ods.policy

default allow := true

deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

# An Agent Trace record is line-level attribution the agent recorded: it
# discloses AI use as a trailer does, and is measured rather than declared.
default review_tier := "standard"

ai_disclosed {
    input.detection_sources[_] == "commit-trailer"
}

ai_disclosed {
    input.detection_sources[_] == "git-ai-notes"
}

ai_disclosed {
    input.detection_sources[_] == "agent-trace"
}

ai_disclosed {
    input.detection_sources[_] == "pr-body"
}

warn[msg] {
    input.ai_generated
    not ai_disclosed
    msg := "AI code detected without author disclosure"
}

review_tier := "elevated" {
    input.ai_generated
    not ai_disclosed
}
