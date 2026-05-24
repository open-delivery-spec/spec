# Threats and Failure Modes

ODS exists because software delivery has predictable failure modes — and they get worse when AI generates code at speed.

This page maps each ODS module to the governance failure it prevents.

---

## Failure Modes

| # | Failure Mode | What Goes Wrong | ODS Mitigation |
|---|-------------|-----------------|----------------|
| 01 | **Unstructured branch names** | Can't categorize branches for CI workflows, auto-deploy, or changelog generation | Branch Naming enforces `<type>/<description>` format |
| 02 | **Commit messages lack intent** | Can't determine if a change was a fix, feature, or breaking change from the commit alone | Commit Message requires Conventional Commits with optional AI attribution |
| 03 | **PR descriptions are inconsistent** | Reviewers can't quickly find Summary, Changes, or Testing sections; AI disclosures are missing | PR Description mandates structured sections including AI Disclosure |
| 04 | **AI-generated code is invisible** | No record of which PRs contain AI-generated code, making review and liability tracking impossible | AI Change Review requires disclosure protocol: L1 (AI-assisted), L2 (AI-generated, human-reviewed), L3 (AI-generated with mandatory human review) |
| 05 | **CI failures are opaque** | Failures produce unstructured logs; can't programmatically determine if failure is AI-related or infrastructure-related | CI Failure produces machine-parseable reports with AI explanation |
| 06 | **Release readiness is gut-feel** | "Is this release ready?" answered orally or via Slack, with no evidence trail | Release Readiness requires evidence-based gates with scoring |
| 07 | **Approval rules are informal** | Who needs to approve what is tribal knowledge, not documented policy | Approval Workflow makes approval rules declarative and version-controlled |
| 08 | **No rollback plan exists** | Production incident occurs; no documented path to revert | Rollback Plan requires structured rollback plans with verification steps |
| 09 | **No deployment evidence** | After a release, no immutable record of what was deployed, when, or whether gates were met | Production Release Evidence creates auditable, timestamped bundles |

---

## AI-Specific Threats

AI coding tools introduce new failure modes that ODS directly addresses:

| AI Threat | Why It Matters | ODS Response |
|-----------|---------------|--------------|
| **AI writes code with no disclosure** | Team can't distinguish human-written from AI-generated changes | PR Description: mandatory AI Disclosure section; Commit Message: `AI-assisted: true` footer |
| **AI changes are never reviewed** | High-volume AI PRs go unreviewed because "AI wrote it, it's probably fine" | AI Change Review L1/L2/L3 protocol; review records are machine-verifiable |
| **AI introduces subtle bugs** | AI-generated code passes CI but contains logic errors | CI Failure: structured reports flag AI-related failures; release readiness gates catch patterns |
| **AI makes deployment decisions** | Without evidence gates, AI-assisted deployments are opaque | Release Readiness: scored gates prevent unverified deployments |
| **No audit trail for AI-era releases** | Compliance auditors ask "how do you control AI risks?" but no structured answer exists | Production Release Evidence: immutable deployment bundles include AI review records |

---

## Governance Failures (Non-AI)

Traditional delivery governance also has well-known failures:

| Failure | Example | ODS Module |
|---------|---------|------------|
| **Branch naming chaos** | 47 branches named `fix`, `test`, `wip` | 01 Branch Naming |
| **Meaningless commits** | `"fix stuff"`, `"update"` as commit messages | 02 Commit Message |
| **Unreviewed changes** | 300-line PR merged with no description | 03 PR Description |
| **Undocumented releases** | "We deployed last Tuesday, I think" | 09 Production Evidence |
| **Absent rollback plans** | 4-hour outage because no one knew how to revert | 08 Rollback Plan |

---

## Threat Model Principles

ODS's threat model is not about security vulnerabilities. It's about **delivery governance failures**:

1. **Opacity**: Changes happen without structured records.
2. **Inconsistency**: Every team uses different conventions.
3. **Untraceability**: Can't answer "was this reviewed?" or "what evidence existed for this release?"
4. **AI blind spots**: Can't tell if AI wrote code, reviewed it, or influenced a deployment decision.

ODS mitigates these by requiring **machine-readable evidence** at each governance checkpoint.

---

## Further Reading

- [ODS Levels](levels.md) — progressive adoption model
- [SLSA Comparison](comparison/slsa.md) — how ODS and SLSA address different threats
