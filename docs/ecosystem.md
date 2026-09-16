---
title: Ecosystem
nav_order: 9
---

# ODS Ecosystem Positioning

This document clarifies how Open Delivery Spec relates to other standards and tools in the software delivery landscape.

---

## ODS vs Content Provenance (APP, C2PA)

| Dimension | APP / C2PA | ODS |
|---|---|---|
| **What's governed** | Content artifacts (text, images, video) | Software delivery lifecycle |
| **Target user** | Content platforms, social media, regulators | Engineering teams, CI/CD pipelines |
| **CI/CD integration** | None | Native (GitHub Actions, CLI, Git hooks) |
| **Core question** | "Was this content AI-generated?" | "Which changes are AI-assisted, are they tested, and do they meet policy?" |

APP (AI Content Provenance) and C2PA (Coalition for Content Provenance and Authenticity) solve the content labeling problem at the **artifact layer**: marking which images, text, or videos were generated or modified by AI. This is important for content platforms complying with regulations like the EU AI Act Article 50.

ODS works at the **process layer**: it attributes AI-assisted code in a pull request from the signals tools volunteer, routes review attention to it, and enforces the team's policy before it reaches production.

They are **complementary**: you might use C2PA to mark AI-generated documentation inside your repository, and ODS to govern how that repository's changes are reviewed and deployed. ODS does not compete with or replace content provenance standards.

## ODS vs SLSA

SLSA proves how an artifact was built; ODS shows how a change was delivered,
who (or what) wrote it, and whether it met policy. Different questions,
different audiences, often co-deployed. The full comparison is
[ODS and SLSA](comparison/slsa.md).

## ODS and Conventional Commits / Conventional Branch

| Standard | ODS Relationship |
|---|---|
| **Conventional Commits** | ODS reads commit metadata — especially `Co-Authored-By` trailers — as an AI-attribution signal during `detect`. The commit format is unchanged; ODS consumes what tools already emit rather than mandating a new format. |
| **Conventional Branch** | ODS recognizes AI-tool branch prefixes (`claude/`, `copilot/`, `cursor/`) and conventional prefixes (`feature/`, `bugfix/`, …) as detection signals. It reads them, it doesn't require them. |

ODS does not compete with these standards — it **builds on them** by treating their metadata as AI-detection input. A repository can use Conventional Commits and ODS together without conflict.

## ODS and Semgrep / CodeQL

| Dimension | Semgrep / CodeQL | ODS |
|---|---|---|
| **What it finds** | Security, bug, or style defects in any code | Quality patterns specific to AI-generated code |
| **Output format** | SARIF v2.1.0 | ODS `issues[]` JSON |
| **Policy enforcement** | Rule suppression / audit logs | OPA Rego gates in CI |
| **AI focus** | None by default | Primary |

Semgrep and CodeQL are **complementary inputs to ODS**. Run them as a CI step, then pass their SARIF output to `ods analyze --sarif`:

```bash
semgrep --config=auto --sarif > semgrep.sarif
ods analyze --sarif semgrep.sarif --json
```

ODS converts SARIF severity levels (`error` → `high`, `warning` → `medium`, `note` → `low`) into its own issue schema and includes them in the policy input's `issues[]` array. A Rego policy can then block on semgrep `critical` findings the same way it blocks on native ODS findings.

## ODS and commit-check

[commit-check](https://github.com/commit-check/commit-check) validates commit messages and branch names against Conventional Commit / Conventional Branch rules. ODS uses commit-check in its own CI to ensure that AI-tool-generated branches (`claude/`, `copilot/`, `cursor/`) are recognized as valid branch prefixes (requires commit-check ≥ 2.9.0).

| Dimension | commit-check | ODS |
|---|---|---|
| **What it checks** | Commit message and branch name format | AI code quality and delivery governance |
| **Output** | Pass / Fail on format rules | Structured JSON + OPA policy decision |
| **AI branch names** | Validates them (≥ 2.9.0) | Reads them as a detection signal |

They are **co-deployed**: commit-check enforces naming conventions, ODS enforces delivery quality.

## ODS and AI code reviewers

CodeRabbit, Copilot code review, `claude -p` and their peers produce opinions
about a change. ODS does not compete with them and does not run a model of its
own: it **consumes** their verdicts (`review-verdict/v1`, via
`ods check --ai-review`) as one more input to a deterministic, auditable
"can this merge?" decision. What ODS adds around any reviewer:

- **Attribution** from the signals tools volunteer (`Co-Authored-By`, git-ai
  notes, PR disclosure), graded by evidence tier: it never claims forensic
  detection, and it says so.
- **Routing**: a `review_tier` that sends undisclosed or untested AI changes to
  a human, and lets clean, disclosed, tested ones through.
- **Policy as code**: OPA Rego over a published contract, so the bar is the
  same on every PR and lives in the repository.
- **An audit trail**: every decision as structured JSON, and an evidence
  document (`ods attest`) for the ones that need one.
- **SARIF ingestion**: findings from Semgrep, CodeQL or any scanner feed the
  same policy.

The argument in full is [POSITIONING.md](https://github.com/open-delivery-spec/spec/blob/main/POSITIONING.md).

## ODS vs GitHub Code Review / GitLab MR

Platform-native code review is the default process for most teams. ODS does not replace it — ODS **augments** it by:

1. Flagging which changes are AI-assisted before the reviewer starts
2. Routing review attention with a `review_tier` instead of treating every PR alike
3. Providing machine-readable records of what was gated and why
4. Enforcing policy gates automatically in CI

The human reviewer still makes the final decision. ODS gives them the information they need to make it faster and more reliably.

---

## Summary

| Standard / Tool | Layer | AI Focus | ODS Relationship |
|---|---|---|---|
| APP / C2PA | Content artifact | Labeling | Complementary |
| SLSA | Supply chain | None | Co-deployable ([comparison](comparison/slsa.md)) |
| Conventional Commits | Commit format | None | Extended by ODS |
| Conventional Branch | Branch naming | None | Extended by ODS |
| Semgrep / CodeQL | Code analysis | None | Input to ODS via `--sarif` |
| commit-check | Commit/branch naming | AI branches (≥ 2.9.0) | Co-deployed |
| AI code reviewers | Review | Verdicts | Input to ODS via `review-verdict/v1` |
| Platform review | Process | None | Augmented by ODS |
