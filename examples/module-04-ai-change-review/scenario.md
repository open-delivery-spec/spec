# Scenario: PR #142 — Add SARIF Output

This fictional scenario is used in all three review-level examples (L1, L2, L3).

## Overview

| Field | Value |
|---|---|
| **Repository** | `acme-corp/payment-service` |
| **PR #** | 142 |
| **Title** | `feat: add SARIF output for GitHub Advanced Security` |
| **Branch** | `feature/add-sarif-output` |
| **Author** | `dev-bot` (GitHub Copilot assisted) |
| **Base** | `main` |

## Change Summary

The PR adds SARIF (Static Analysis Results Interchange Format) output to a Go CLI tool called `payment-service`. SARIF is a JSON-based standard for exchanging static analysis results, and this feature enables the tool to integrate with GitHub Advanced Security's code scanning dashboard.

## Changed Files (8 total)

| # | File | Lines Changed | Purpose | Classification |
|---|---|---|---|---|
| 1 | `cmd/payment/main.go` | +12 / -3 | Add `--sarif` flag and output path | Primary |
| 2 | `internal/scanner/sarif.go` | +195 / -0 | New: SARIF report generation logic | Primary |
| 3 | `internal/scanner/sarif_test.go` | +78 / -0 | New: SARIF tests | Primary |
| 4 | `internal/scanner/result.go` | +23 / -8 | Extend result struct for SARIF fields | Primary |
| 5 | `internal/scanner/scanner.go` | +15 / -5 | Wire SARIF output into scan pipeline | Primary |
| 6 | `README.md` | +10 / -0 | Document `--sarif` flag usage | Documentation |
| 7 | `src/auth/token_refresh.go` | +8 / -4 | **Unrelated**: refresh token expiry handling | Out-of-scope |
| 8 | `go.mod` | +2 / -0 | Add `encoding/json` dependency (already indirect) | Build |

## AI Attribution

| Metric | Value |
|---|---|
| Total AI-generated commits | 6 of 8 |
| AI-generated files | Files 1–6 |
| Human-authored files | File 7 (`token_refresh.go`), File 8 (`go.mod`) |
| AI contribution (lines) | ~75% |
| AI tools used | GitHub Copilot (commit trailers: `AI-assisted: true`, `AI-tool: GitHub-Copilot`) |

## The Problem (Scope Drift)

File `src/auth/token_refresh.go` was modified in this PR but has **nothing to do with SARIF output**. The change adds token expiry retry logic — a legitimate improvement, but one that should have been a separate PR. The developer likely included it because they noticed the issue while working on the SARIF feature.

Without ODS Module 04 review, a reviewer might:
- Miss the scope drift entirely
- Approve the auth change without proper security review
- Create a merge that ships an unreviewed security-sensitive change

## Review Levels Applied

| Level | Trigger | When |
|---|---|---|
| **L1 — Quick Scan** | Every PR | Automated CI check on PR open |
| **L2 — Detailed Review** | PR targeting `main` | Added after initial scope drift detected |
| **L3 — Full Audit** | Release PR | Before merging to release branch |
