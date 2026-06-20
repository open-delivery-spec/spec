---
title: Ecosystem
nav_order: 7
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
| **Core question** | "Was this content AI-generated?" | "Is this AI-generated code safe to ship?" |

APP (AI Content Provenance) and C2PA (Coalition for Content Provenance and Authenticity) solve the content labeling problem at the **artifact layer**: marking which images, text, or videos were generated or modified by AI. This is important for content platforms complying with regulations like the EU AI Act Article 50.

ODS solves the delivery governance problem at the **process layer**: ensuring that AI-generated code in a pull request is reviewed, scoped correctly, and free of known quality defects before it reaches production.

They are **complementary**: you might use C2PA to mark AI-generated documentation inside your repository, and ODS to govern how that repository's changes are reviewed and deployed. ODS does not compete with or replace content provenance standards.

## ODS vs SLSA

| Dimension | SLSA | ODS |
|---|---|---|
| **What's governed** | Supply chain integrity | Delivery quality |
| **Core question** | "Was this artifact built from the right source?" | "Was this change reviewed, scoped, and ready?" |
| **Target** | Build pipelines, artifact registries | Pull requests, CI gates |
| **AI focus** | None | Primary |

SLSA (Supply-chain Levels for Software Artifacts) governs supply chain integrity — verifying that a software artifact was built from the correct source code without tampering. ODS governs delivery quality — verifying that a code change was properly reviewed, stays within its declared scope, and doesn't introduce AI-specific quality regressions.

These are different questions with different audiences, and they are often co-deployed: SLSA ensures the artifact is authentic, ODS ensures the change is safe.

## ODS and Conventional Commits / Conventional Branch

| Standard | ODS Relationship |
|---|---|
| **Conventional Commits** | ODS reads commit metadata — especially `Co-Authored-By` trailers — as an AI-attribution signal during `detect`. The commit format is unchanged; ODS consumes what tools already emit rather than mandating a new format. |
| **Conventional Branch** | ODS recognizes AI-tool branch prefixes (`claude/`, `copilot/`, `cursor/`) and conventional prefixes (`feature/`, `bugfix/`, …) as detection signals. It reads them, it doesn't require them. |

ODS does not compete with these standards — it **builds on them** by treating their metadata as AI-detection input. A repository can use Conventional Commits and ODS together without conflict.

## ODS vs AI Code Linters

AI-focused linters (e.g., specialized Copilot review tools) detect code quality issues in AI output. ODS overlaps at the analysis layer but adds:

- **Multi-source AI detection** without relying on developer self-disclosure
- **Technical debt scoring** that combines detection confidence, defect density, and test coverage
- **Policy enforcement** via OPA Rego, allowing enterprise-specific rules
- **Policy decisions recorded as structured JSON** for an audit trail of what was gated and why

## ODS vs GitHub Code Review / GitLab MR

Platform-native code review is the default process for most teams. ODS does not replace it — ODS **augments** it by:

1. Flagging which changes are AI-generated before the reviewer starts
2. Automating the AI-specific checklist items
3. Providing machine-readable review records for compliance
4. Enforcing policy gates automatically in CI

The human reviewer still makes the final decision. ODS gives them the information they need to make it faster and more reliably.

---

## Summary

| Standard | Layer | AI Focus | ODS Relationship |
|---|---|---|---|
| APP / C2PA | Content artifact | Labeling | Complementary |
| SLSA | Supply chain | None | Co-deployable |
| Conventional Commits | Commit format | None | Extended by ODS |
| Conventional Branch | Branch naming | None | Extended by ODS |
| AI Linters | Code quality | Detection + analysis | Overlaps, ODS adds policy + scoring |
| Platform review | Process | None | Augmented by ODS |
