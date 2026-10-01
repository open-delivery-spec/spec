package ods.policy

import rego.v1

default allow := true

deny contains msg if {
    issue := input.issues[_]
    issue.severity == "critical"
    msg := sprintf("CRITICAL: %s at %s:%d", [issue.rule, issue.file, issue.line])
}

# Evidence tier: route AI changes whose attribution is only inferred (heuristic)
# or inconclusive to extra review. Attested/corroborated attribution is trusted
# enough to stay standard. A low tier never denies on its own.
default review_tier := "standard"

strong_evidence if { input.evidence_tier == "corroborated" }
strong_evidence if { input.evidence_tier == "attested" }

review_tier := "elevated" if {
    input.ai_generated
    not strong_evidence
}
