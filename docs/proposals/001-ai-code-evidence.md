# Proposal 001 — AI-Code Evidence Documents (CycloneDX-aligned)

**Status:** Proposal / RFC — design only, no schema or code changes yet.
**Depends on:** nothing shipped changes; builds on data ODS already computes.

## Motivation

Regulation has arrived: the EU AI Act's technical-documentation requirements
(Article 11 / Annex IV) took effect on 2026-08-02, and audit-style questions —
*"which parts of this codebase were AI-assisted, by what tool, and what
verification was applied?"* — are becoming procurement and compliance
questions, not just engineering ones.

The existing AI-BOM ecosystem (CycloneDX ML-BOM / modelCard, OWASP AIBOM
tooling, runtime generators such as k8s-aibom) answers a *different* question:
**which models and datasets are components of your system**. Nobody covers the
layer ODS lives in: **which of your source code was AI-assisted, with what
strength of evidence, and what deterministic verification it passed**.

ODS already computes every input this layer needs, per PR: attribution
(trailers / PR body / git-ai measured lines), `evidence_tier`
(corroborated / attested / inferred / inconclusive), diff-scoped test adequacy
(`patch_coverage`, `mutation_score`, merge-confidence facts), the policy
verdict and review-routing tier, and pipeline integrity. This proposal adds an
**output layer** that serializes those facts into a standard, auditable,
signable document. It is an extension of the current positioning
("governance and visibility"), not a pivot: the tagline gains
*"the audit trail for AI-assisted code."*

## Design principles

1. **Use an existing standard; invent nothing.** The evidence document is a
   **valid CycloneDX 1.6 BOM** (ECMA-424). ODS-specific data rides on
   CycloneDX's own extension points: the `ods:` property namespace and a
   `definitions.standards` entry. Any CycloneDX-aware tool can ingest it; the
   reference example in this proposal validates against the official
   `bom-1.6.schema.json`.
2. **Corroboration over self-report.** Every evidence entry carries a
   **re-fetchable locator** — a workflow-run URL, an artifact digest, a commit
   SHA — so an auditor can verify it independently. Anything only the
   submitter can produce, only the submitter can fabricate; evidence that
   cannot be re-fetched is labeled accordingly (its `confidence` reflects the
   evidence tier).
3. **Facts with graded confidence, not verdicts.** CycloneDX attestations
   natively separate **conformance** (how well the requirement is met) from
   **confidence** (how trustworthy the assessment is). That is exactly ODS's
   split between the measured value and the evidence tier, and the document
   preserves it.
4. **Not forensic.** The document's `affirmation.statement` says explicitly:
   attribution reflects signals tools and authors volunteered; it is not
   forensic proof of authorship, and no claim asserts code correctness.

## Document shape (CycloneDX 1.6 mapping)

| ODS data | CycloneDX location |
|---|---|
| The change (PR / commit range) | `metadata.component` (`type: application`) with `pedigree.commits[]` and `ods:pr` / `ods:head_sha` / `ods:diff_base` / `ods:workflow_run` properties |
| ODS CLI that produced the doc | `metadata.tools.components[]` |
| Each changed file + its attribution | `components[]` (`type: file`) with `evidence.identity[]` — one `methods[]` entry per detection source: `technique: attestation` (commit-trailer / pr-body), `technique: source-code-analysis` (git-ai measured), `technique: filename` (branch-name), each with its confidence |
| The AI tool/model attributed | `components[]` (`type: application`, e.g. Claude Code + model version) |
| ODS governance requirements | `definitions.standards[]` — "ODS AI-Assisted Code Governance v1" with requirements ODS-R1…R6 (disclosure, evidence grading, patch coverage, mutation score, policy evaluation, pipeline integrity) |
| Per-requirement facts | `declarations.claims[]` (predicate = the deterministic fact) backed by `declarations.evidence[]` (each with re-fetchable locators + digests) |
| Fact value vs. evidence strength | `declarations.attestations[].map[]` — `conformance.score` carries the measured value (e.g. patch coverage 0.75), `confidence.score` carries the evidence tier (corroborated = 1.0, attested ≈ 0.9, inferred ≈ 0.35) |
| Honesty statement | `declarations.affirmation.statement` |

Reference example (validates against the official CycloneDX 1.6 JSON schema):
[`examples/ai-code-evidence.cdx.json`](examples/ai-code-evidence.cdx.json).

## Requirements catalogue (ODS-R1…R6, v1)

| ID | Requirement | Fed by |
|----|-------------|--------|
| ODS-R1 | AI involvement is disclosed | `detection_sources` |
| ODS-R2 | Attribution strength is graded | `evidence_tier` |
| ODS-R3 | Changed code is exercised by tests | `merge_confidence`, `patch_coverage` |
| ODS-R4 | Tests detect faults in the added lines | `mutation_score` |
| ODS-R5 | Policy evaluated and change routed | `allowed`, `review_tier` |
| ODS-R6 | Pipeline integrity | `pipeline` block (validate-action) |

The catalogue is versioned with the standard (`ODS AI-Assisted Code
Governance v1`); teams can extend it with their own requirements in their own
standards entry without forking the format.

## Delivery phases

- **Phase 1 — emit.** New CLI command (working name `ods attest`) that reuses
  the exact data `ods check` already assembles and writes
  `evidence.cdx.json`. validate-action uploads it with the existing report
  artifact and links it from the PR comment. No new detection, no new
  computation.
- **Phase 2 — sign.** Wire the emitted document through GitHub artifact
  attestations (sigstore) in validate-action. No home-grown crypto; CycloneDX
  JSF `signature` slots remain available for teams with their own signing.
- **Phase 3 — aggregate.** `ods attest --range vX..vY`: the release-level
  AI-code evidence document — the artifact an EU-AI-Act-style technical-file
  request actually asks for.

## Non-goals

- **Not an ML-BOM.** ODS does not inventory models/datasets as system
  components; it documents evidence about AI-assisted *source code*. The two
  compose (a team can ship both documents).
- **No proprietary format.** If CycloneDX cannot express something, the answer
  is properties/standards within CycloneDX, not a new format.
- **No correctness or authorship-proof claims.** Same POSITIONING boundaries
  as the rest of ODS.

## Open questions (for review)

1. Command name: `ods attest` vs `ods evidence` vs a flag on `ods check`
   (`--evidence-out`).
2. Register the `ods:` prefix in the CycloneDX property-taxonomy registry
   once the shape stabilizes?
3. Target CycloneDX 1.6 now (widest tool support, validated) and revisit 1.7
   (Oct 2025, ECMA-424 2nd ed.) once its tooling catches up — any reason to
   start at 1.7 instead?
4. Per-file granularity: include all changed files, or only files with AI
   attribution (current lean: all changed files, attribution where present —
   auditors want the denominator).
