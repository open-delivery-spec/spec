package ods.policy

import rego.v1

default allow := true

# Block any high- or critical-severity issue — including findings ingested from
# an external analyzer (Semgrep, CodeQL, ...) via `--sarif`.
deny contains msg if {
	issue := input.issues[_]
	issue.severity == "high"
	msg := sprintf("%s: %s (%s:%d)", [issue.severity, issue.rule, issue.file, issue.line])
}

deny contains msg if {
	issue := input.issues[_]
	issue.severity == "critical"
	msg := sprintf("%s: %s (%s:%d)", [issue.severity, issue.rule, issue.file, issue.line])
}
