# Examples

Two audiences (**Boss Mode** for executive/client readers, **Developer Guide** for engineering),
two ways of generating (**Evidence** = deterministic, no LLM, byte-identical; **Commentary** =
optional LLM synthesis) — five report artifacts, all real, all rendered from **the same 7-session
capture store** (2026-07-31 → 2026-08-13, 9,132 transcript turns, 40/40 tasks completed):

| File(s) | Register | What it is |
| --- | --- | --- |
| [`deterministic/real-session.report.json`](deterministic/real-session.report.json) | — | The shared machine contract every report below renders from. Structured, typed, feeds a dashboard/pipeline/agent. |
| [`deterministic/boss-mode.report.{html,md}`](deterministic/boss-mode.report.html) | Boss Mode · Evidence | A consulting-register memo: task completion, cost, risk flags. Every figure resolves to a row in `report.json`. No AI, cost not tracked, byte-identical. |
| [`interpreted/interpreted-executive.html`](interpreted/interpreted-executive.html) | Boss Mode · Commentary | A narrative management summary: what the numbers mean, what needs deciding, what to watch. LLM-written, clearly labeled, from `interpret-brief.executive.md`. |
| [`deterministic/real-session.report.{html,md}`](deterministic/real-session.report.html) | Developer Guide · Evidence | A technical post-mortem: session-by-session breakdown (top 5 of 7, with rework/LOC/agents/skills per session), a top-5-languages chart, a 6-channel capture-flow diagram with per-channel `bar query`/SQL verify commands, top-5-prompts cards, rework hotspots enriched with language/location/tier, plus full appendices (a 68-prompt token/LOC ledger and the 60-row raw failure list). No AI, cost not tracked, byte-identical — about 3x the length of the plain deterministic render. |
| [`interpreted/interpreted-engineering.html`](interpreted/interpreted-engineering.html) | Developer Guide · Commentary | A diagnostic narrative: why the run went the way it did, root-cause-grouped failures, and concrete prompt/spec/context changes for next time. LLM-written, from `interpret-brief.engineering.md`. |
| [`deterministic/real-session.report.png`](deterministic/real-session.report.png), [`interpreted/interpreted-executive.png`](interpreted/interpreted-executive.png) | — | Screenshots used in the README and wiki. |
| [`interpreted/interpret-brief.executive.md`](interpreted/interpret-brief.executive.md), [`interpret-brief.engineering.md`](interpreted/interpret-brief.engineering.md) | — | The real, deterministic briefs `bar interpret` generated — the exact facts each Commentary report was written from. Nothing in either Commentary report exists that isn't in its brief. |

"Boss Mode" / "Developer Guide" are this project's settled public names for the two audiences —
the CLI itself still says `bar interpret --audience executive|engineering`; the names describe the
same two registers.

## One real, multi-session capture store, on purpose

All five reports above come from **the same store**: 7 real Claude Code sessions ingested
end-to-end (`bar init` → `bar ingest` ×7 → `bar report` → `bar interpret` ×2), spanning
2026-07-31 to 2026-08-13. Earlier drafts of this folder mixed two different single sessions across
the deterministic and interpreted examples — that's fixed now: one store, one set of facts, all
five reports agree with each other because they're the same data read five ways.

## How to read them

Open any `.html` file for the human view, the `.md` for a terminal- or diff-friendly view, or
`real-session.report.json` for the machine-readable form (shared by all five). **One known gap,
disclosed:** `real-session.report.json` does not currently validate against
`schemas/report.schema.json` — that schema describes an earlier report shape than what `bar
report` produces today. Same story for `schemas/interpretation.schema.json` against the
interpreted layer, which now ships as a brief-plus-prose pair rather than the richer JSON
structure that schema describes. Both are pending a schema regeneration in the private working
repo; this README says so rather than leaving a reader to discover the mismatch by hand.

**Also disclosed:** `boss-mode.report.{html,md}` and the Commentary layer's root-cause failure
grouping are hand-assembled from `real-session.report.json` and a real `bar query <db> errors`
export, not yet a dedicated `bar report --view summary` CLI mode — a genuine product gap, not a
silent one. The underlying facts are 100% real either way.

## Why the deterministic layer only had one example, historically

Earlier drafts also shipped a seeded fixture and a hand-authored "fully populated" mock, on the
theory that showing every possible section at once had more reference value. It didn't hold up:
the mock was built against the same earlier schema, and would have shown detectors this version
of the product doesn't actually run yet (`human_ai_recovery`, `micro_observations`) as if they
were live — exactly the kind of overclaiming this project's `not_observed` discipline exists to
prevent. Two real examples now (Boss Mode + Developer Guide, both Evidence), each honestly
incomplete in the same ways your own reports will be, is more useful than a synthetic one that
quietly promises more than the tool delivers.

See **[wiki/human-md/README.md](../wiki/human-md/README.md)** for a section-by-section guide to reading
a report, and **[wiki/report-guide.html](../wiki/human-html/report-guide.html)** for a fully annotated
walkthrough of the deterministic example above.
