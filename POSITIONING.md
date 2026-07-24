# Positioning: what ODS is, and what it deliberately is not

> One-line answer: **ODS is the governance layer that decides whether a change
> can merge — it consumes AI review, it does not try to be an AI reviewer.**

This document exists to settle a recurring question ("shouldn't ODS just review
the code with an LLM, like CodeRabbit?") once, so the project doesn't relitigate
its direction every few months. It is a statement of scope, not a feature plan —
see [ROADMAP.md](ROADMAP.md) for what's being built.

## The question ODS answers

Across a flood of pull requests — increasingly authored by AI — which ones can
merge, and which carry risk that a human must look at? The bottleneck was never
writing code; it's that humans cannot review as fast as machines now produce.

## "Can this merge?" has a deterministic shell and a semantic core

The decision decomposes into questions of very different tractability:

| Sub-question | Answered by | Deterministic? |
|---|---|---|
| Does it violate known rules (vulns, bad patterns)? | static analysis / SARIF | ✅ yes |
| Does it have tests / adequate coverage? | measurement | ✅ yes |
| Is AI involvement disclosed / attributed? | commit trailers | ✅ yes |
| **Is the code _correct_ — does it do what it claims? subtle logic bugs?** | **understanding intent** | ❌ needs intelligence (AI or human) |
| Is it well-designed and maintainable? | judgment | ❌ needs intelligence |

Two consequences follow, and ODS is built on accepting both honestly:

1. **Pure deterministic analysis can reject, but it cannot truly approve.** It
   can prove "definitely not mergeable" (critical vuln, zero tests, undisclosed
   AI, policy violation). It can never prove "mergeable" — only "no red flag I
   can mechanically detect." That is why ODS calls itself a *signal producer,
   not a quality oracle*: a PASS means no policy rule fired, not that the code
   is correct.

2. **Cracking the semantic core requires intelligence — and so does ODS's full
   promise.** ODS was never meant to reach "can this merge?" without AI. Its bet
   is to be the layer that consumes intelligence safely, not to be the
   intelligence.

## Consume AI, do not become AI

There are two fundamentally different products in this space:

- **The AI reviewer** (CodeRabbit, Greptile, Copilot code review, Claude
  `/review`, Apache Magpie's PR-review skills): reads the diff, uses an LLM to
  find bugs, posts comments. Its value _is_ the LLM's judgment quality. This is
  a crowded, well-funded, fast-moving arena, and it has no durable moat — a
  bigger model resets it.

- **The governance / decision layer** (this is ODS): does not do the reviewing.
  Given attribution + deterministic findings + AI-reviewer verdicts + coverage +
  the team's policy, it renders a **trustworthy, auditable, policy-as-code
  decision** on whether the change can merge, and routes human attention to
  where it's warranted.

ODS chooses the second, and already built the bridge to the first:
`review-verdict/v1` + the `ai_reviews` policy input let **any** AI reviewer's
opinion flow into the gate under one rule —

> **Deterministic findings may deny; probabilistic (LLM) opinions may only
> tighten the gate (route more review), never loosen it and never merge on their
> own.**

An AI reviewer's `request_changes` raises the review tier; its `approve` can
never qualify a change for the `auto` tier by itself. This keeps the gate safe
even against a prompt-injected or over-optimistic reviewer, and it means ODS
gets _more_ valuable as AI reviewers proliferate, not less:

> **However many AI reviewers exist and however fast they change, the gate they
> plug into is singular. ODS is that gate.**

## Non-Goals (the hard boundary)

ODS will **not**:

1. **Build its own LLM code-review engine**, or compete on review quality with
   CodeRabbit / Copilot / Greptile. ODS consumes their output via
   `review-verdict/v1`; it does not reproduce it.
2. **Restructure into an agent/skill framework** (à la Apache Magpie). Magpie
   distributes AI-agent capabilities as prompts; ODS's value is deterministic
   enforcement, which is code, not prompts. The two solve different problems.
3. **Remove the human from consequential merges.** Even _with_ AI, LLM judgment
   is not trustworthy enough to be the sole gate (measured: a large share of
   AI-proposed fixes point the wrong way; hallucination and prompt injection are
   real). The achievable goal is not "delivery without humans" — it is **freeing
   humans from the ~80% that is mechanically safe and concentrating them on the
   ~20% that is not.** That is exactly what `review_tier` does.

## The one place AI may enter ODS's own surface

A thin, **optional, clearly-labelled reference adapter** that calls the user's
_own_ LLM (bring-your-own key — ODS pays no inference cost and owns no model
quality) and formats the output as `review-verdict/v1`, purely to lower
activation energy for teams that don't already run an AI reviewer. It is
positioned as *a swappable convenience, not the core value* — replace it with
CodeRabbit / Copilot / Claude review at any time. The gate remains the product.

If a proposal would move review quality onto ODS's own shoulders, it is out of
scope by this document.

## In one sentence

> Whichever AI is reviewing, whatever the static analyzers found, whatever the
> humans said — ODS is the place that turns all of it into one trustworthy,
> auditable, you-decide answer to "can this merge?" There are many reviewers;
> there is one gate.
