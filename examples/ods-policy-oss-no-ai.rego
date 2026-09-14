# examples/ods-policy-oss-no-ai.rego
# Copy to .ods/policy.rego in your repository.
#
# Open-source policy for projects whose CONTRIBUTING.md says "we do not
# accept AI-generated contributions." A ban is a disclosure policy with a
# stricter consequence, and it can only be enforced on what is disclosed:
#
#   - Attested AI use (the author's own trailer, git-ai notes, or PR-body
#     disclosure) is a deterministic fact, so it denies — with a message
#     that thanks the contributor for saying so. A refusal that punishes
#     disclosure teaches people to hide it.
#   - Suspected AI use (branch name, diff heuristics) is a guess with false
#     positives, so it routes the PR to a maintainer instead of refusing a
#     human's work.
#
# Guide: https://open-delivery-spec.github.io/spec/oss-ai-policy.html

package ods.policy

default allow := true
default review_tier := "standard"

deny[msg] {
    issue := input.issues[_]
    issue.severity == "critical"
    msg = sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

ai_disclosed {
    input.detection_sources[_] == "commit-trailer"
}

ai_disclosed {
    input.detection_sources[_] == "git-ai-notes"
}

ai_disclosed {
    input.detection_sources[_] == "pr-body"
}

# Attested: refuse, and say why.
deny[msg] {
    input.ai_generated
    ai_disclosed
    msg = "This project does not accept AI-generated contributions (see CONTRIBUTING.md). Thank you for disclosing it — please rewrite the change by hand, or open an issue to discuss it first"
}

# Suspected only: route to a maintainer, never refuse on a heuristic.
ai_suspected {
    input.ai_generated
    input.ai_confidence >= 0.5
    not ai_disclosed
}

warn[msg] {
    ai_suspected
    msg = "AI assistance suspected (heuristics only) — a maintainer should confirm with the contributor before review"
}

review_tier := "elevated" {
    ai_suspected
}
