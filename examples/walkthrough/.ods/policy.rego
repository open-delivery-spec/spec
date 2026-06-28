package ods.policy

default allow := true

# Block any high- or critical-severity issue — including findings ingested from
# an external analyzer (Semgrep, CodeQL, ...) via `--sarif`.
deny[msg] {
	issue := input.issues[_]
	issue.severity == "high"
	msg := sprintf("%s: %s (%s:%d)", [issue.severity, issue.rule, issue.file, issue.line])
}

deny[msg] {
	issue := input.issues[_]
	issue.severity == "critical"
	msg := sprintf("%s: %s (%s:%d)", [issue.severity, issue.rule, issue.file, issue.line])
}
