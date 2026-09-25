---
title: ODS and SLSA
parent: Why ODS
nav_order: 3
---

# ODS and SLSA

**ODS complements SLSA. They address different layers of software delivery trust.**

> [!NOTE]
> ODS is inspired by SLSA's specification rigor and ecosystem thinking. ODS is early-stage (2026); SLSA is established (OpenSSF, v1.2). This page explains where each fits.

## One Sentence

> **SLSA proves how software artifacts were built. ODS shows which changes were AI-assisted, whether they were tested, and that they met policy before merge.**

---

## Comparison

| Dimension | SLSA | ODS |
|-----------|------|-----|
| **Core concern** | Artifact integrity: was this artifact tampered with? | AI-assisted code governance: which changes are AI-assisted, are they tested, do they meet policy? |
| **Primary object** | Software artifact (binary, container, package) | Pull request diff |
| **Key evidence** | Provenance, attestation, signature | Attribution with its evidence tier, findings, technical-debt score, policy decision, review tier |
| **Lifecycle focus** | Source → Build → Distribution | Pre-merge (every PR) |
| **Primary audience** | Security, platform, supply-chain teams | Engineering teams shipping AI-assisted code |
| **Threat model** | Supply-chain tampering, build compromise | Undisclosed AI-assisted code, untested AI changes, review attention spread thin |
| **Output** | SLSA provenance, VSA | ODS report (JSON / Markdown / HTML), policy pass/warn/block, CycloneDX evidence document |
| **AI relationship** | Can protect the build chain for AI-assisted code | Attributes, routes and gates AI-assisted code |

---

## How They Work Together

```
┌──────────────────────────────────────────────────────────┐
│                     SOFTWARE DELIVERY                     │
│                                                          │
│   PRE-MERGE (every PR)                                   │
│   ┌────────────────────────────────────┐                │
│   │  ODS check                         │                │
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
| I need review attention routed to AI-assisted changes | — | ✅ |
| I need to verify artifact signatures | ✅ | — |
| I need to hold AI-assisted changes to a policy | — | ✅ |
| I need both artifact integrity and AI code governance | ✅ | ✅ |

---

## ODS Is Not a Replacement for SLSA

ODS does not:

- Generate build provenance
- Sign software artifacts
- Verify artifact integrity
- Replace SBOMs or SLSA attestations

ODS does:

- Attribute AI-assisted code in a change, with its evidence tier
- Surface findings and score the technical-debt impact
- Route review attention and enforce a policy-as-code gate before merge
- Emit an evidence document for the audit trail

> [!TIP]
> **Use SLSA when you need artifact integrity. Use ODS when you need AI code governance. Use both when you need both.**

---

## Further Reading

- [SLSA specification](https://slsa.dev/spec/v1.2/)
- [SLSA Get Started](https://slsa.dev/get-started)
- [ODS Get Started](../get-started.md)
