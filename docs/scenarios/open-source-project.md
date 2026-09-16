---
title: Scenario: Open-Source Project
nav_order: 11
---

# Scenario: Open-Source Project

**Use case:** A maintainer wants to see which contributions are AI-assisted and
hold them to the project's contribution rules, without adding friction for
casual contributors.

## Profile

- Team: 1 to 3 maintainers, 5 to 50 contributors, many of them first-timers
- Repository: public on GitHub, pull requests from forks
- AI tools: some contributors use Copilot, Cursor or Claude Code; nobody tracks it
- Goal: visibility first, a policy the community agreed on, nothing blocked on suspicion

## Set-up

The [Get Started](../get-started.md) workflow, unchanged. With no
`.ods/policy.rego` the check reports on every PR and only critical findings
block, so newcomers are never turned away by a red check.

Most projects that allow AI assistance ask for the same three things: disclose
it, test it, own it. [`examples/ods-policy-oss-disclosure.rego`](https://github.com/open-delivery-spec/spec/blob/main/examples/ods-policy-oss-disclosure.rego)
is that clause as a policy: an undisclosed AI change gets a nudge and extra
review, an untested one a warning, and nothing is blocked on suspicion. The
[Open-Source AI Policy](../oss-ai-policy.md) page walks through it, including
the fork pull-request caveats and a variant for projects that do not accept AI
contributions.

Projects that want no AI-specific rules at all can keep the default, or commit
[`examples/ods-policy-oss.rego`](https://github.com/open-delivery-spec/spec/blob/main/examples/ods-policy-oss.rego),
which blocks only critical findings.

## Why this approach

| Principle | Implementation |
|-----------|----------------|
| **Low barrier** | No required forms; disclosure comes from the trailers tools already emit |
| **Visibility first** | The report shows attribution and findings as information |
| **Newcomer-friendly** | Without a policy only critical findings block; with the disclosure policy, nothing blocks on suspicion |
| **Upgrade path** | Require the check in branch protection when the project is ready |

## Next steps

1. Once the report has run for a few weeks, require the check in branch
   protection (see [Rolling it out to a team](../get-started.md#rolling-it-out-to-a-team)).
2. Add the badge so contributors know what to expect:

   ```markdown
   [![ODS](https://img.shields.io/badge/ODS-AI%20attribution-blue)](https://github.com/open-delivery-spec/spec)
   ```
