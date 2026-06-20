---
title: Threats & Failure Modes
nav_order: 8
---

# Threats and Failure Modes

> [!IMPORTANT]
> ODS exists because AI now generates code faster than review processes can vet it. This page maps the failure modes of AI-assisted delivery to the part of the ODS pipeline (`detect → analyze → score → check`) that addresses each one.

---

## AI-Specific Failure Modes

| # | Failure Mode | What Goes Wrong | ODS Mitigation |
|---|-------------|-----------------|----------------|
| 1 | **AI code ships with no disclosure** | Reviewers can't tell which changes were AI-generated, so they can't target scrutiny | `detect` surfaces AI involvement from `Co-Authored-By` trailers, PR-body disclosure, branch prefixes, and diff heuristics |
| 2 | **High-volume AI PRs go under-reviewed** | "AI wrote it, it's probably fine" — large diffs are skimmed and merged | `detect` + `analyze` flag AI-touched code and its defect patterns so review effort goes where the risk is |
| 3 | **AI introduces subtle quality defects** | Hallucinated APIs, unsafe deserialization, missing edge cases pass CI but rot the codebase | `analyze` applies AI-specific rule categories that generic linters don't check for |
| 4 | **Technical debt accumulates invisibly** | Each AI PR looks fine alone; the aggregate quality slide is never measured | `score` produces a weighted technical-debt delta per PR |
| 5 | **No consistent quality bar** | Whether risky AI code merges depends on which reviewer happened to look | `check` enforces an OPA Rego policy identically on every PR |
| 6 | **No audit trail for AI-era changes** | Compliance asks "how do you control AI risk?" and there's no structured answer | Every detection, analysis, score, and policy decision is emitted as structured JSON |

---

## Why Generic Tooling Isn't Enough

AI-generated code fails in ways traditional checks miss:

| Generic tool | What it catches | What it misses |
|--------------|-----------------|----------------|
| **Linters / formatters** | Style, syntax, obvious bugs | AI-specific patterns (over-commenting, redundant error handling, hallucinated APIs) |
| **Test coverage gates** | Untested lines | Whether the *AI-generated* portion is the untested part |
| **Code review** | Whatever the human notices | Which changes were AI-generated, at scale, consistently |
| **SLSA / provenance** | Build-chain integrity | The quality and review status of the change itself |

ODS sits at the **pre-merge change layer** and answers the AI-specific questions: *was this AI-generated, what's wrong with it, how much debt does it add, and does it meet policy?*

---

## Threat Model Principles

ODS's threat model is not about security vulnerabilities. It's about **AI code quality governance failures**:

1. **Opacity**: AI involvement is invisible, so review can't be targeted.
2. **Volume**: AI produces more code than humans can carefully review.
3. **Silent debt**: Quality erodes one acceptable-looking PR at a time.
4. **Inconsistency**: The quality bar varies by reviewer instead of being enforced as policy.

ODS mitigates these by producing **machine-readable evidence at every stage of the gate** and enforcing a **policy as code** before merge.

---

## Further Reading

- [ODS Levels](levels.md) — progressive adoption model
- [SLSA Comparison](comparison/slsa.md) — how ODS and SLSA address different layers
