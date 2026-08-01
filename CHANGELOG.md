# Changelog

All notable changes to Open Delivery Spec will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Merge-confidence signals** in the policy input (`merge_confidence`): deterministic, diff-scoped facts — `added_source_without_tests` / `tests_touched`, `risky_paths`, and diff shape — advisory by default with `review_tier` routing; deny stays opt-in.
- **Patch (diff) coverage** (`patch_coverage`): coverage of a change's *added* lines from an existing report (Go / LCOV / Cobertura), with a `-1` "not measured" sentinel.
- **AI reviewer verdicts** (`ai_reviews`, via `ods check --ai-review`) as a `review-verdict/v1` input — advisory: routes attention, never denies unless a policy opts in.
- **Disclosure completeness** (`detection_sources`): distinguishes disclosed AI use (commit-trailer / git-ai-notes / pr-body) from merely suspected, so policies can nudge for attribution without blocking.
- **`ai-hallucinated-api`** analysis rule (hallucinated / deprecated API usage) — the fifth analysis rule.
- **Real test-coverage parsing** (Go / LCOV / Cobertura / NYC) feeding the coverage-gap score, replacing the heuristic estimate when a report is present.
- **`ods report`**: per-repo AI attribution report with text, JSON, and a self-contained HTML dashboard.
- **Review-tier routing** (`review_tier`: `auto` / `standard` / `elevated`) as an advisory output of `ods check`.
- Conformance suite for the policy-input contract (15 scenarios).

### Changed
- Front-door framing reframed from "AI code quality gate" to **governance and visibility for AI-assisted code** (disclosed AI PRs already merge at a high rate; ODS's value is visibility, routing, audit, and policy).

## [2.0.0] — 2026-06-11

### Changed
- **Pivot to AI code quality gate.** ODS is no longer a delivery metadata standard (branch naming, commit message, PR description). It is now a CI gate that detects AI-generated code, analyzes its quality, scores technical debt impact, and enforces enterprise policy.
- CLI commands replaced: `ods validate`, `ods report`, `ods review`, `ods generate`, `ods ci`, `ods fix` removed in favor of `ods detect`, `ods analyze`, `ods score`, `ods check`, `ods hook`, `ods init`.

### Removed
- **Modules 01–09 deprecated.** Branch Naming, Commit Message, PR Description, AI Change Review, CI Failure, Release Readiness, Approval Workflow, Rollback Plan, and Production Evidence are no longer supported by tooling. JSON Schemas retained in the spec repo for reference.

### Added
- **AI code detection:** Multi-source detection via commit trailers, PR body disclosure, branch prefix, and diff heuristics.
- **AI code quality analysis:** 4 deterministic rules (redundant error handling, over-commenting, unsafe deserialization, inconsistent patterns).
- **Technical debt scoring:** 5-dimension weighted score (AI code ratio, defect density, critical issues, test coverage gap, code duplication).
- **OPA Rego policy engine:** Enterprise policy enforcement via `.ods/policy.rego`.
- **Git hooks:** Pre-commit governance with `ods hook install`.
- **Scaffolding:** `ods init` for CI workflow and agent instructions.

## [1.0.0] — 2026-05-24

### Added
- **01 — Branch Naming:** Standardized branch naming spec extending Conventional Branch 1.0.0 with AI generation markers and ticket integration
- **02 — Commit Message:** Extended Conventional Commits 1.0.0 with AI attribution footers (AI-assisted, AI-tool, AI-scope, AI-review, AI-confidence)
- **03 — PR Description:** Structured PR description template with mandatory AI disclosure, risk assessment, and verification checklist
- **04 — AI Change Review:** Three-level review protocol (L1 Quick Scan, L2 Enhanced, L3 Full Audit) with machine-parseable review records
- **05 — CI Failure:** Standardized CI failure report format with AI failure explanation and hallucination detection
- **06 — Release Readiness:** Evidence-based release gate system with scoring and AI-specific gates
- **07 — Approval Workflow:** Declarative approval policy format with AI-aware conditional rules
- **08 — Rollback Plan:** Minimum requirements for valid rollback plans with testability requirements
- **09 — Production Release Evidence:** Immutable evidence bundle for audit and compliance
- JSON Schemas for all nine modules (Draft 2020-12)
- CLI reference design
- GitHub Action integration design
