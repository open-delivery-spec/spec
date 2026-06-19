# Module 04 — AI Change Review: End-to-End Example

> ⚠️ **Module status**: Experimental / Deprecated. The Module 01–09 system is retained for reference. The recommended ODS path today is the AI code quality gate pipeline (`ods detect | analyze | score | check`). See [ROADMAP.md](../../ROADMAP.md).

This directory demonstrates a realistic AI Change Review (Module 04) scenario using PR #142 from the fictional `acme-corp/payment-service` repository. See [scenario.md](scenario.md) for the full story.

## The Scenario

A developer adds SARIF output support to a Go CLI tool. Six of eight commits are AI-generated (GitHub Copilot). One changed file (`src/auth/token_refresh.go`) has nothing to do with SARIF — **scope drift** that a reviewer could easily miss.

ODS Module 04 catches this before merge.

## Review Level Outputs

ODS defines three review levels for AI-generated changes:

### L1 — Quick Scan (every PR)

Automated, fast — checks AI disclosure, scope boundaries, and basic quality signals.

```bash
# L1 runs on every PR automatically in CI
```

**Output:** [l1-review.json](l1-review.json)

Key signals:
- AI contribution: ~75% (6 of 8 commits AI-generated)
- Verdict: `approved_with_changes` — scope drift flagged
- The out-of-scope file (`src/auth/token_refresh.go`) is noted with a `WARN`

### L2 — Detailed Review (PRs targeting `main`)

Human reviewer applies the AI-specific checklist: correctness, security, AI-specific patterns, quality, and scope.

```bash
# L2 runs on PRs targeting main after developer fix
```

**Output:** [l2-review.json](l2-review.json)

What L2 adds over L1:
- Per-file classification (primary / documentation / out-of-scope)
- Detailed security finding: path traversal vulnerability in AI-generated SARIF output
- AI-specific quality issues: over-commenting (47% ratio), inconsistent error wrapping
- Recommendation: revert and re-submit the auth change separately

### L3 — Full Audit (release PRs)

Mandatory second reviewer. Full audit trail including all commits, PR metadata, and compliance verification.

```bash
# L3 runs on release PRs after all L2 findings are resolved
```

**Output:** [l3-review.json](l3-review.json)

What L3 adds over L2:
- Second reviewer (`john-smith`) independently verifies all findings
- Compliance note referencing ODS governance requirements
- Evidence that all L2 issues are resolved before release sign-off

## CI Integration

See [github-actions-workflow.yml](github-actions-workflow.yml) for a ready-to-use workflow that maps these review levels to GitHub Actions trigger points.

> **Note:** The `ods review generate` command that originally produced Module 04 records has been deprecated along with the Module 01–09 system. The GitHub Actions workflow below uses the current `validate-action@v2` pipeline. To generate Module 04–conformant review records from the pipeline output, use the JSON examples in this directory as templates.
