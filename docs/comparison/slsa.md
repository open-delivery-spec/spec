---
title: ODS and SLSA
nav_order: 9
---

# ODS and SLSA

**ODS complements SLSA. They address different layers of software delivery trust.**

> [!NOTE]
> ODS is inspired by SLSA's approach to levels, specification rigor, and ecosystem thinking. ODS is early-stage (2026); SLSA is established (OpenSSF, v1.2). This page explains where each fits.

## One Sentence

> **SLSA proves how software artifacts were built. ODS proves the AI-generated code in a change was detected, vetted, and within policy before merge.**

---

## Comparison

| Dimension | SLSA | ODS |
|-----------|------|-----|
| **Core concern** | Artifact integrity: was this artifact tampered with? | AI code quality: is the AI-generated code in this change safe to merge? |
| **Primary object** | Software artifact (binary, container, package) | Pull request diff |
| **Key evidence** | Provenance, attestation, signature | AI detection result, quality issues, technical-debt score, policy decision |
| **Lifecycle focus** | Source → Build → Distribution | Pre-merge (every PR) |
| **Primary audience** | Security, platform, supply-chain teams | Engineering teams shipping AI-assisted code |
| **Threat model** | Supply-chain tampering, build compromise | Undisclosed AI code, AI-specific defects, silent technical debt |
| **Output** | SLSA provenance, VSA | ODS report (JSON / Markdown / SVG) + policy pass/warn/block |
| **AI relationship** | Can protect the build chain for AI-generated code | Directly detects and gates AI-generated code |
| **Levels** | SLSA Build L1 / L2 / L3 | ODS L1 / L2 / L3 |

---

## How They Work Together

```
┌──────────────────────────────────────────────────────────┐
│                     SOFTWARE DELIVERY                     │
│                                                          │
│   PRE-MERGE (every PR)                                   │
│   ┌────────────────────────────────────┐                │
│   │  ODS AI Code Quality Gate          │                │
│   │  detect → analyze → score → check  │                │
│   └────────────────────────────────────┘                │
│                     │                                    │
│                ODS gates the change                      │
│                                                          │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─    │
│                     ▼                                    │
│                BUILD & RELEASE                           │
│              ┌──────────────┐                            │
│              │  Provenance  │                            │
│              │  Attestation │                            │
│              │  Signature   │                            │
│              └──────────────┘                            │
│                     │                                    │
│              SLSA secures the artifact                   │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## When to Use Each

| Scenario | SLSA | ODS |
|----------|------|-----|
| I need to prove my binary wasn't tampered with | ✅ | — |
| I need to know which PRs contain AI-generated code | — | ✅ |
| I need build provenance for compliance | ✅ | — |
| I need to catch AI-specific quality defects before merge | — | ✅ |
| I need to verify artifact signatures | ✅ | — |
| I need to block low-quality AI changes by policy | — | ✅ |
| I need both artifact integrity and AI code governance | ✅ | ✅ |

---

## ODS Is Not a Replacement for SLSA

ODS does not:

- Generate build provenance
- Sign software artifacts
- Verify artifact integrity
- Replace SBOMs or SLSA attestations

ODS does:

- Detect AI-generated code in a change
- Analyze it for AI-specific quality defects and score its technical-debt impact
- Enforce a policy-as-code gate before merge

> [!TIP]
> **Use SLSA when you need artifact integrity. Use ODS when you need AI code governance. Use both when you need both.**

---

## Further Reading

- [SLSA specification](https://slsa.dev/spec/v1.2/)
- [SLSA Get Started](https://slsa.dev/get-started)
- [ODS Levels](../levels.md)
- [ODS Get Started](../get-started.md)
