---
title: Open-Source AI Policy
nav_order: 5
---

# Open-Source AI Policy

**For maintainers who have, or want, an AI clause in CONTRIBUTING.md.**

Most projects that have written one say the same three things: disclose AI
assistance, test what it wrote, and own the result. This page turns that
clause into a check that runs on every pull request, with a policy you can
copy as it is, and says plainly what such a check can and cannot see.

## What the check can see

| Your CONTRIBUTING says | ODS reads | What happens on the PR |
|---|---|---|
| "Disclose AI assistance" | `Co-Authored-By` / `Assisted-by` commit trailers, git-ai notes, the AI-disclosure checkbox in the PR body | A change with AI signals but no disclosure gets a nudge in the ODS comment and is routed to `elevated` review. It is never blocked on suspicion. |
| "AI-generated code must come with tests" | Whether the diff adds source without touching a test; patch coverage of the added lines when a coverage report exists | Warn and route to `elevated`. A `deny` is available as an opt-in for changes the author attested. |
| "A human must understand and own the change" | Nothing directly. It reads *where* the change lands: CI config, dependency manifests and lockfiles, auth / crypto / security paths | AI-assisted changes on those paths are routed to `elevated` with the maintainers you name. The human-review statement stays in the PR template, where a person writes it. |
| "We do not accept AI-generated contributions" | The same disclosure signals | Attested AI changes are refused with a message that says why and thanks the contributor for disclosing; suspected ones are routed to a maintainer. See the second template below. |

What it cannot see: undisclosed AI use that leaves no trailer, and whether the
contributor understood the code. Attribution is volunteered, never proven. The
check makes honest disclosures count and gives your rule a place to live. It is
not a detector for people hiding AI use, and it says nothing about correctness.

## The clause, if you do not have one yet

The policy's messages send contributors to CONTRIBUTING.md, so say it there.
This is the wording this organization uses in its own repositories; adjust the
tool names and the paths you consider sensitive:

> **AI-assisted contributions.** AI assistance is welcome here on three
> conditions. **Disclose it:** keep the `Co-Authored-By` trailer your tool
> adds, add `Assisted-by: <tool>` to the commit message, or tick the AI
> Disclosure box in the pull request template. **Test it:** AI-authored code
> comes with tests. **Own it:** you have read and understood what you submit
> and can answer questions about it in review. CI checks what it can see of
> these on every pull request and posts the result as a comment; a change that
> looks AI-assisted but says nothing gets a nudge and a maintainer's look,
> never a refusal.

## Set it up

### 1. The policy

Copy the template to `.ods/policy.rego`:

```bash
mkdir -p .ods
curl -o .ods/policy.rego \
  https://raw.githubusercontent.com/open-delivery-spec/spec/main/examples/ods-policy-oss-disclosure.rego
```

[`examples/ods-policy-oss-disclosure.rego`](https://github.com/open-delivery-spec/spec/blob/main/examples/ods-policy-oss-disclosure.rego)
has one section per clause. Out of the box it denies only critical findings;
everything about AI warns and routes. Each section ends with a commented
`STRICT` block that turns the warning into a `deny` once you have watched the
warnings for a while and trust them.

This organization runs this exact file on all of its own repositories
([ADOPTERS.md](https://github.com/open-delivery-spec/spec/blob/main/ADOPTERS.md));
the spec repository's CI keeps its copy identical to the template.

### 2. The workflow

{% raw %}
```yaml
# .github/workflows/ods.yml
name: ODS AI Policy
on:
  pull_request:

permissions:
  contents: read
  pull-requests: write   # the comment and the review-tier label

jobs:
  ods:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
        with:
          fetch-depth: 0                                   # trailers live in history
          ref: ${{ github.event.pull_request.head.sha }}   # resolves for fork PRs too
      - uses: open-delivery-spec/validate-action@v1
        with:
          diff-base: ${{ github.event.pull_request.base.sha }}
          branch: ${{ github.head_ref }}
          review-routing: "true"            # label the PR ods:review/<tier>
          elevated-reviewers: "your-handle" # requested when the tier is elevated
```
{% endraw %}

Pull requests from forks run with a read-only token, so on those the comment
and the label are skipped. The check still runs, still fails on a `deny`, and
its report is in the job summary and the `ods-report` artifact. To post the
comment on fork PRs as well, add the `workflow_run` job from
[Permissions and Fork Pull Requests](https://github.com/open-delivery-spec/validate-action#permissions-and-fork-pull-requests)
in the validate-action README.

### 3. The PR template

Give contributors a place to disclose. This is the part of
[`examples/ods-pr-template.md`](https://github.com/open-delivery-spec/spec/blob/main/examples/ods-pr-template.md)
that `detect` reads:

```markdown
## AI Disclosure
- [ ] This PR contains AI-generated code
- **AI Tool:** <!-- e.g. GitHub Copilot, Cursor, Claude Code -->
- **Human Review:** <!-- what you verified yourself -->
```

Contributors using Claude Code, Copilot or Cursor usually need nothing more:
those tools add the `Co-Authored-By` trailer on their own.

### 4. Roll it out

1. **Observe for a week.** Run the workflow without requiring the check in
   branch protection. Read the ODS comments and see which warnings fire on
   real contributions.
2. **Require the check.** Add the workflow to the required status checks.
   Nothing changes for contributors who disclose and test.
3. **Then decide about STRICT.** Uncomment a `deny` only for a clause you have
   seen enough warnings for. The disclosure `deny` keeps a high confidence
   threshold on purpose: a false positive there turns away a human.

## If your project does not accept AI contributions

[`examples/ods-policy-oss-no-ai.rego`](https://github.com/open-delivery-spec/spec/blob/main/examples/ods-policy-oss-no-ai.rego)
is the same check with a stricter consequence, and it is honest about what a
ban can enforce:

- **Attested** AI use (the author's own trailer, git-ai notes, or PR-body
  disclosure) is a deterministic fact, so it denies. The message thanks the
  contributor for disclosing. A refusal that punishes disclosure teaches
  people to hide it, which is the one outcome a ban cannot survive.
- **Suspected** AI use (branch name, diff heuristics) is a guess with false
  positives, so it routes the PR to a maintainer instead of refusing a
  human's work.

## What contributors see

An undisclosed change gets a comment like this; the **Why** line names every
reason the badge is not green:

```text
Result: WARN
AI Detected: Yes (confidence: 60%)
Policy: Allowed
Review Tier: elevated
Why: 1 policy warning; policy routed this to elevated review

Policy Warnings
- AI assistance suspected but not disclosed — add a Co-Authored-By or
  Assisted-by trailer, or tick the AI disclosure in the PR description
  (see CONTRIBUTING.md)
```

Adding the trailer or ticking the box on the next push turns it into a
`PASS`. A disclosed, tested, clean change lands in the `auto` tier: eligible
for expedited review, never merged on its own.

## Tune it

| Knob | Where | Default |
|---|---|---|
| Suspicion threshold for the disclosure nudge | `ai_undisclosed`, `input.ai_confidence >= 0.5` | 0.5: an AI-tool branch prefix alone scores 0.6, diff heuristics alone 0.4 |
| Patch-coverage threshold | `ai_low_patch_coverage`, `input.patch_coverage < 0.7` | 70% of added lines, only when a coverage report exists |
| Sensitive paths | `input.merge_confidence.risky_paths` | CI config, dependency manifests and lockfiles, auth / crypto / security paths. Add your own with a `regex.match` over `input.changed_files` |
| Fast lane | `review_tier := "auto"` | Disclosed, tests touched, no high or critical finding, debt delta at most 1.0 |
| Hard gates | the `STRICT` blocks | Off |

The [policy authoring guide](policy-authoring.md) covers the Rego you need for
anything beyond these knobs.

## Verify it before you ship it

The spec's conformance scenarios are ready-made inputs, so a policy can be
checked without a matching repository:

```bash
go install github.com/open-delivery-spec/cli/cmd/ods@latest

# An undisclosed AI change: expect a warning and review_tier "elevated"
ods check --input spec/conformance/warn-ai-undisclosed/input.json \
          --policy .ods/policy.rego --json

# A disclosed, tested change: expect review_tier "auto"
ods check --input spec/conformance/pass-tested-change/input.json \
          --policy .ods/policy.rego --json
```

`scripts/check-example-policies.sh` runs both templates against every
scenario in this repository's CI, so the templates cannot drift from what this
page says.
