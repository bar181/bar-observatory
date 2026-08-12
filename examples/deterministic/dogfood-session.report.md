# BAR Observatory — captured session report

> Observe how agentic work actually gets done.

In a recorded window of 1h 00m, the recorder captured 3 transcript turns plus 10 timeline events across 8 hook events, 2 log/metric events and 1 span(s); hook-lifecycle coverage is verified; transcript coverage is verified, and 0 dead-letter loss(es) were detected.

| Outcome (self-reported) | Rework signal | Recorded window |
|---|---|---|
| **Not enabled** (no task calls in this transcript to derive a ledger from) | **Not enabled** (no repeated-edit or error signal in this transcript) | **1h 00m** |

**Action required: none identified.** Risk/outcome analyzers found no signal (or aren't enabled) — an absence of instrumentation, not an all-clear.

> Colour/marker key: a **measured gap or risk in the session** is distinct from a **recorder capability not yet enabled** — the latter is never rendered as a finding or a zero.

## Summary

| Measure | Value |
|---|---:|
| Runs / sessions | 1 |
| Timeline events | 10 |
| Hook events | 8 |
| Log/metric events | 2 |
| OTLP spans | 1 |
| Transcript turns | 3 |
| Requests | 2 |
| Tokens in | 20,800 |
| Tokens out | 5,500 |
| Tokens total | 26,300 |
| Capture losses | 0 |

## Capture quality

No capture losses recorded (dead_letters is empty).

| Channel | Status | Coverage | Recorded | What this means |
|---|---|---|---:|---|
| hooks | complete | verified | 8 | Lifecycle complete (MEASURED): session bracketed — SessionStart×1, Stop×1; all 2 tool call(s) paired (PreToolUse↔PostToolUse); no dead-letter loss. |
| events | complete | unverified | 2 | 2 recorded; no capture loss detected (coverage unverified — oracle in Phase 6+). |
| spans | complete | verified | 1 | Span tree complete (MEASURED): 1 spans, all closed, all parents resolve, no OTLP loss (structural only — prompt-correlation best-effort). |
| transcripts | complete | verified | 3 | Transcript DAG complete (MEASURED): 3 turns, seq gapless, every parent resolves, all 1 tool_use paired BY ID with a tool_result, no transcript loss. |
| requests | complete | unverified | 2 | 2 recorded; no capture loss detected (coverage unverified — oracle in Phase 6+). |
| provider_cost_usd | not_recorded | not_applicable | 0 | Subscription auth (ADR-024) exposes no authoritative per-token USD; a labeled list-price ESTIMATE is derived instead (see cost). Tokens + wall-clock stay primary. |

<details><summary>Methodology &amp; definitions (status vs coverage, the oracle)</summary>

**Status** is loss-detection (`complete` = no dead-letter loss; `partial` = a measured loss/gap; `not_recorded` = no rows). **Coverage** is a separate axis: `verified` = an oracle measured completeness (hooks: session bracketed by SessionStart+Stop AND every PreToolUse paired with a PostToolUse); `gap_detected` names the shortfall; `unverified` = no oracle for that channel yet. A green status is never a coverage guarantee.
</details>

## Cost (API-cost equivalent)

**≈ $0.14** at API list price (`list-price-v1-2026-08`) for 20,800 in / 5,500 out tokens.

- **Subscription value:** on a Pro/Max subscription you paid *nothing extra* — that ≈$0.14 is the list-price value your subscription absorbed.
- **If you switched to the API:** this same session would cost ≈$0.14 in pay-per-token billing.

A *list-price equivalent*, **not what a subscriber paid** (subscriptions are prepaid; tokens + wall-clock is primary).

## Still not built

7 analyzer(s) are **not yet built** — disclosed so an unbuilt measure is never mistaken for a measured zero. Capability state, not a finding.

<details><summary>Show the 7 not-yet-built analyzer(s) &amp; why each is absent</summary>

| Section | Why it is absent |
|---|---|
| Tasks & completion | Not observed — no TodoWrite/TaskCreate task calls in this transcript to derive a ledger from. |
| Rework | Not observed — no repeated-edit or error signals in this transcript. |
| Agents & handoffs | Not observed — no Agent/Task sub-agent dispatches in this transcript. |
| Skills usage | Not observed — no Skill invocations in this transcript (0 is real here, not unbuilt). |
| Human-vs-AI recovery | Not observed — human-vs-AI recovery classification is not built yet. |
| Validation runs | Not observed — no cargo `test result:` lines in this transcript's tool outputs. |
| Micro-observations & silent signals | Not observed — micro-observation extraction and silent-signal detection are not built yet; no findings are fabricated. |

</details>

## Evidence & integrity

Deterministic render — the same database renders byte-identically; no LLM and no network in the render path.

- `recorded_window`: 1h 00m (3,600,000 ms)
- `source_db_hash`: blake3:a47010b467b5011af00f3a2474d4588a18352b16746617cc4c1ea14c387100cc
- `template_hash`: blake3:b8bcf83ef579efa16b0185ca546f39cf8a408aa8c0a58051763eab7500742871
- `renderer_version`: 0.1.0
- `generated_at` (from DB): 2025-06-15T16:06:40Z

---
_Independent open-source project by Bradley Ross / Bradley.Academy. Academic crimson palette; no Harvard University marks are used and no endorsement is implied._

Report barobs-a47010b467b5 · template bar-observatory-engineering-1.0 · Bradley.Academy
