# ODS and SLSA

**ODS complements SLSA. They address different layers of software delivery trust.**

## One Sentence

> **SLSA proves how software artifacts were built. ODS proves how software changes were delivered.**

---

## Comparison

| Dimension | SLSA | ODS |
|-----------|------|-----|
| **Core concern** | Artifact integrity: was this artifact tampered with? | Delivery governance: was this change properly reviewed and evidenced? |
| **Primary object** | Software artifact (binary, container, package) | Delivery artifact (branch name, commit, PR, review, release evidence) |
| **Key evidence** | Provenance, attestation, signature | PR description, AI review record, release readiness report, evidence bundle |
| **Lifecycle focus** | Source → Build → Distribution | Before merge → At merge → After merge → Release |
| **Primary audience** | Security, platform, supply chain teams | DevOps, release, engineering governance teams |
| **Threat model** | Supply chain tampering, build compromise | AI black-box delivery, missing review evidence, untracked releases |
| **Output** | SLSA provenance, VSA | ODS JSON artifacts (.ods/ directory) |
| **AI relationship** | Can protect build chain for AI-generated code | Directly records AI involvement and review obligations |
| **Levels** | SLSA Build L1 / L2 / L3 | ODS L1 / L2 / L3 / L4 |

---

## How They Work Together

```
┌──────────────────────────────────────────────────────────┐
│                     SOFTWARE DELIVERY                     │
│                                                          │
│  BEFORE MERGE           AT MERGE        AFTER MERGE       │
│  ┌──────────┐       ┌──────────┐       ┌──────────┐      │
│  │ Branch   │       │ PR Desc  │       │ Release  │      │
│  │ Naming   │       │ AI Review│       │ Evidence │      │
│  │ Commit   │       │ Approval │       │ Rollback │      │
│  │ Message  │       │ CI Fail  │       │          │      │
│  └──────────┘       └──────────┘       └──────────┘      │
│       │                  │                  │            │
│       └──────────────────┴──────────────────┘            │
│                          │                               │
│                    ODS governs                           │
│                delivery artifacts                        │
│                                                          │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─    │
│                                                          │
│                          ▼                               │
│                     BUILD & RELEASE                      │
│                   ┌──────────────┐                       │
│                   │  Provenance  │                       │
│                   │  Attestation │                       │
│                   │  Signature   │                       │
│                   └──────────────┘                       │
│                          │                               │
│                    SLSA secures                          │
│                artifact integrity                        │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## When to Use Each

| Scenario | SLSA | ODS |
|----------|------|-----|
| I need to prove my binary wasn't tampered with | ✅ | — |
| I need structured PR descriptions with AI disclosure | — | ✅ |
| I need build provenance for compliance | ✅ | — |
| I need to track which releases had rollback plans | — | ✅ |
| I need to verify artifact signatures | ✅ | — |
| I need evidence that a change was properly reviewed | — | ✅ |
| I need both artifact integrity and delivery governance | ✅ | ✅ |

---

## ODS Is Not a Replacement for SLSA

ODS does not:

- Generate build provenance
- Sign software artifacts
- Verify artifact integrity
- Replace SBOMs or SLSA attestations

ODS does:

- Standardize delivery metadata before and during the build
- Make AI involvement in code changes auditable
- Provide structure for release readiness decisions
- Create machine-readable evidence of delivery governance

> **Use SLSA when you need artifact integrity. Use ODS when you need delivery governance. Use both when you need both.**

---

## Further Reading

- [SLSA specification](https://slsa.dev/spec/v1.2/)
- [SLSA Get Started](https://slsa.dev/get-started)
- [ODS Levels](levels.md)
- [ODS Get Started](get-started.md)
