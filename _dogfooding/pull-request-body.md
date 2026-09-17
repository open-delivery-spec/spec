<!--
Pull-request description for submitting an ODS workflow to a repository you
do not maintain. Replace the <placeholders>, delete what does not apply, and
keep it short: maintainers read many of these.
-->

## Add an ODS check for AI-assisted changes (observe-only)

This adds one GitHub Actions workflow, `.github/workflows/ods-validate.yml`,
that runs [Open Delivery Spec](https://github.com/open-delivery-spec/spec) on
every pull request. It reads the `Co-Authored-By` / `Assisted-by` trailers
that Claude Code, Copilot and Cursor already add to commits, and the AI
Disclosure section of a PR description, and posts one comment per pull
request: whether the change is AI-assisted and disclosed, what the built-in
checks found, and a review tier (`auto` / `standard` / `elevated`) to help
spend review time.

**What it does not do**

- It does not block anything by default. The check fails only on a critical
  finding from the built-in analysis. Undisclosed AI is a nudge, never a
  refusal: the heuristics have false positives, and a first-time contributor
  must not be turned away by a machine.
- It sends nothing anywhere. Everything runs in this repository's Actions
  runner; the report is the PR comment, the job summary and a workflow
  artifact.
- It does not claim to detect AI. Attribution reads what the tools and the
  authors disclose; the
  [guide](https://open-delivery-spec.github.io/spec/oss-ai-policy.html#what-the-check-can-see)
  says what the check can and cannot see.

**Why this project**

<One or two sentences. For example: CONTRIBUTING asks contributors to
disclose AI assistance and to test and understand what they submit; this
turns that clause into a check that runs on every pull request, with the
result in the place contributors already look.>

**Try it, keep it, or drop it**

- Observe for a week: the workflow is not a required check. Read the comments
  on real pull requests.
- Keep it: make it a required check and, if you want your AI clause enforced
  as policy, copy
  [`ods-policy-oss-disclosure.rego`](https://github.com/open-delivery-spec/spec/blob/main/examples/ods-policy-oss-disclosure.rego)
  to `.ods/policy.rego` (guide:
  <https://open-delivery-spec.github.io/spec/oss-ai-policy.html>). Projects
  that do not accept AI contributions have
  [`ods-policy-oss-no-ai.rego`](https://github.com/open-delivery-spec/spec/blob/main/examples/ods-policy-oss-no-ai.rego)
  instead: it refuses attested AI changes politely and routes suspected ones
  to a maintainer.
- Drop it: delete the file. Nothing else changes.

Pull requests from forks run with a read-only token, so on those the comment
is skipped and the report is in the job summary; the
[validate-action README](https://github.com/open-delivery-spec/validate-action#permissions-and-fork-pull-requests)
has an optional follow-up job that posts it.

The action is [open-delivery-spec/validate-action](https://github.com/open-delivery-spec/validate-action)
(Apache 2.0). I maintain ODS and will fix anything it causes here.
