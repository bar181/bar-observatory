# BAR Observatory — captured session report

> Observe how agentic work actually gets done.

## Executive summary

**Over 30h 58m, the session made 1,145 tool calls across 3,970 transcript turns, dispatched 22 sub-agent run(s), and captured 25 error result(s).**

### Key findings

- **25 tool error(s) were captured — the failures are recorded, not swallowed.**
  - Worst: search_ruvnet (MCP) ×9. See the Failures section for the per-tool breakdown.
- **One file absorbed the most churn: 157 edits.**
  - `./observatory/crates/bar-observatory/src/report.rs` — a refactor / test-coverage candidate.
- **Validation was not fully green at capture end: 20 failing vs 99 passing.**
  - From real `test result:` lines in the tool outputs (measured, not self-reported).
- **5 of 6 capture channels were not recorded this session.**
  - Uncaptured channels read "not recorded" (never a fabricated 0) — this is a transcript-only ingest.

### Recommendations (resolution-first)

- **P1** — A failing MCP tool has an alternative front door — reach it via its CLI/RVF path instead of the MCP (ADR-021).
- **P1** — Resolve the remaining failing tests before relying on the session's completion claims.
- **P2** — Review `./observatory/crates/bar-observatory/src/report.rs` (highest edit churn) for a refactor or missing test coverage.
- **P3** — Enable OTEL telemetry + hooks to capture tokens/cost, timeline, and coverage (see the process docs).

In a recorded window of 30h 58m, the recorder captured 3,970 transcript turns (hook, log/metric, and span channels were not recorded in this transcript-only ingest); hook-lifecycle coverage is unverified; a TRANSCRIPT coverage gap was detected (see capture quality — a dead-letter count of 0 is not the whole completeness story), and 0 dead-letter loss(es) were detected. The agent made 1,145 tool calls; the task ledger shows 27 task(s) (12 completed, 0 in-progress, 15 other), and 22 attributable file(s) show repeated-edit churn.

| Outcome (self-reported) | Rework signal | Recorded window |
|---|---|---|
| **12/27 tasks completed** (self-reported (TodoWrite/TaskUpdate); per-task claim≠evidence linkage is P8) | **22 rework hotspot(s), 25 error(s)** (measured repeated-edit / error churn (structural signal, not a quality judgment)) | **30h 58m** |

**Action required: review 22 rework hotspot(s).** The most-churned file(s) are under Rework — repeated edits often mark a hard spot worth a test or design pass. Structural signal, not a quality verdict.

> Colour/marker key: a **measured gap or risk in the session** is distinct from a **recorder capability not yet enabled** — the latter is never rendered as a finding or a zero.

## Summary

| Measure | Value |
|---|---:|
| Runs / sessions | 1 |
| Timeline events | not recorded |
| Hook events | not recorded |
| Log/metric events | not recorded |
| OTLP spans | not recorded |
| Transcript turns | 3,970 |
| Requests | not recorded |
| Tokens in | not recorded |
| Tokens out | not recorded |
| Tokens total | not recorded |
| Capture losses | 0 |

## Capture quality

No capture losses recorded (dead_letters is empty).

| Channel | Status | Coverage | Recorded | What this means |
|---|---|---|---:|---|
| hooks | not_recorded | not_applicable | 0 | No hooks rows in this store. |
| events | not_recorded | not_applicable | 0 | No events rows in this store. |
| spans | not_recorded | not_applicable | 0 | No spans rows in this store. |
| transcripts | partial | gap_detected | 3,970 | 3970 turns; coverage gap (MEASURED) — 350 dangling parent(s); 36 unpaired tool_use/tool_result. |
| requests | not_recorded | not_applicable | 0 | No requests rows in this store. |
| provider_cost_usd | not_recorded | not_applicable | 0 | Subscription auth (ADR-024) exposes no authoritative per-token USD; a labeled list-price ESTIMATE is derived instead (see cost). Tokens + wall-clock stay primary. |

<details><summary>Methodology &amp; definitions (status vs coverage, the oracle)</summary>

**Status** is loss-detection (`complete` = no dead-letter loss; `partial` = a measured loss/gap; `not_recorded` = no rows). **Coverage** is a separate axis: `verified` = an oracle measured completeness (hooks: session bracketed by SessionStart+Stop AND every PreToolUse paired with a PostToolUse); `gap_detected` names the shortfall; `unverified` = no oracle for that channel yet. A green status is never a coverage guarantee.
</details>

## Agent activity

What the agent actually did: **1,145** tool calls this session.

| Tool | Calls |
|---|---:|
| Bash | 603 |
| Edit | 293 |
| Read | 98 |
| Write | 43 |
| TaskUpdate | 30 |
| TaskCreate | 27 |
| Agent | 22 |
| search_ruvnet (MCP) | 9 |
| ToolSearch | 7 |
| AskUserQuestion | 4 |
| SendUserFile | 4 |
| WebSearch | 2 |
| Grep | 1 |
| ScheduleWakeup | 1 |
| WebFetch | 1 |

## Failures

Real failures captured from tool outputs: 25 error result(s) across 5 distinct tool(s), categorized (mcp / tool / unknown). Remediation: 1 MCP tool(s) failed (worst: search_ruvnet (MCP) ×9). A repeatedly-failing MCP server (e.g. a timing-out one) should be reached through its alternative front door — its CLI/RVF path — instead of the MCP (BAR ADR-021). This section surfaces both system failures (a tool or MCP not working) and coded errors so they are recorded, not silently dropped.

| Tool | Kind | Errors |
|---|---|---:|
| search_ruvnet (MCP) | mcp | 9 |
| Bash | tool | 7 |
| Edit | tool | 7 |
| Agent | tool | 1 |
| AskUserQuestion | tool | 1 |

## Flaky tests (measured)

2 test(s) both passed AND failed across the session's captured cargo runs (measured from `test … ok`/`FAILED` lines, no LLM). This is a verdict-change signal to investigate — on an actively-editing session a flip can be a fix or a regression, not only non-determinism.

| Test | Passes | Fails |
|---|---:|---:|
| migration_files_are_byte_frozen | 1 | 2 |
| report::tests::p5_empty_store_honest_absent | 1 | 1 |

## Task ledger

Real ledger from the ingested transcript: 27 task(s) — 12 completed, 0 in-progress, 0 pending, 15 other/untracked (sums to 27). State is the agent's SELF-REPORT (TodoWrite/TaskUpdate); per-task attempt/loop/evidence linkage (claim≠evidence) is P8 (rendered null, not a measured zero).

| Task | State (self-reported) |
|---|---|
| Phase 0 — Cleanup & green baseline | completed |
| P7.5: token→USD list-price cost table (labeled estimate) | completed |
| Generate all reports from real data + QE + brutal review + rubric | completed |
| P8: agents & skills detectors + review-swarm fixes | completed |
| P9: recall-memory ON + rubric-vs-ruvnet-SOTA + phase-end (live tests, | created |
| P10.1 — Debug ruflo/ruvnet failures; canonical memory proof; root-cause file | created |
| P10.2 — Confirm DB create-if-not-exists; plan DB upload/portability feature | created |
| P10.3 — Refresh 5 reports w/ real data; QE+designer+reviewer+persona lens | created |
| P10.4 — Phase-end: validation+optimization, live tests, improvements, seal | created |
| P11.1 — ADR: ground brain via CLI/RVF front door (not MCP); make explicit in | created |
| P11.2 — Deep dive public repo folder (bar-observatory/); production-grade + | created |
| Phase 1 — Structural refactor (tooling path drift) | completed |
| P11.3 — Review + update all stale files/docs | created |
| P11.4 — Optimize CLAUDE.md + README docs | created |
| P12.1 — Complete the live DB (create-if-not-exists + full ingest); document | created |
| P12.2 — Regenerate 5 reports from real DB; system+report review | created |
| P12.3 — Reshape public folder = process (init/config/db/ingest/optional/sample) | created |
| P12.4 — Audit private/public boundary (phases 0+ + crates in private; | created |
| P13 — bar doctor: live toolchain/DB/ruvnet health command (CF-P10-1) | created |
| P14 — runnable public front door + dogfood + ruvnet capabilities (SEALED) | created |
| Phase 2 — ADR updates | completed |
| Phase 3 — Data-spec updates | completed |
| Phase 4 — Recursive implementation loop (PAUSE before this) | completed |
| Land P6.1 seal (external-review UX fixes) | completed |
| Append brutal review + build SOTA rubric doc | completed |
| P6.5: ingest real transcript + span/transcript coverage oracles | completed |
| P7: task/completion ledger + rework detection from real transcript | completed |

## Sub-agents dispatched

Real sub-agent hierarchy from the transcript: 22 dispatch(es) across 4 sub-agent type(s). Deterministic post-hoc 'who was dispatched'; live nested-span viz needs the runtime (conceded).

| Sub-agent type | Dispatches |
|---|---:|
| general-purpose | 15 |
| bar-skeptic-reviewer | 5 |
| bar-repo-archaeologist | 1 |
| bar-test-architect | 1 |

## Validation evidence (measured)

Real validation EVIDENCE from ingested tool outputs: 119 cargo `test result:` line(s) — 99 passed, 20 failed; last line PASSED. (One `cargo test --workspace` emits several such lines — one per crate — so this counts result-lines, not invocations; the last verdict is as of the capture window's end.) Measured, not self-reported: it begins to back the ledger's completion claims.

## Rework (measured)

Real deterministic rework signals from the transcript: 22 attributable file(s) edited ≥2× (churn) + 25 error tool_result(s). Structural signals (repeated-edit / error) — NOT hallucination/quality judgment (that is the interpreted report, P10+). Repeated edits are normal in iterative/TDD work; this flags concentration, not failure.

| File (edited ≥2×) | Edits |
|---|---:|
| ./observatory/crates/bar-observatory/src/report.rs | 157 |
| ./observatory/crates/bar-observatory/src/lib.rs | 24 |
| ./observatory/crates/bar-observatory/src/detectors.rs | 22 |
| ./scripts/public-export.sh | 12 |
| ./docs/bar-observatory/LEARNING-LOG.md | 9 |
| ./docs/bar-observatory/REPORT-SCORES.md | 9 |
| ./docs/bar-observatory/PHASE-2-5-CHECKLISTS.md | 8 |
| ./docs/bar-observatory/schemas/report.schema.json | 7 |
| ./docs/bar-observatory/tests/schema/validate.mjs | 6 |
| ./CURRENT-STATE.md | 5 |
| ./docs/bar-observatory/RUBRIC-VS-SOTA.md | 5 |
| ./docs/bar-observatory/tests/frontend/eval.mjs | 5 |
| ./observatory/crates/bar-observatory/src/main.rs | 5 |
| ./docs/bar-observatory/examples/deterministic/README.md | 4 |
| ./observatory/CLAUDE.md | 4 |
| ./observatory/crates/bar-observatory/Cargo.toml | 4 |
| ./docs/bar-observatory/CHECKLIST.md | 3 |
| ./docs/bar-observatory/config-rs/src/lib.rs | 3 |
| ./docs/bar-observatory/RUVNET-BRAIN-ISSUE-REPORT.md | 2 |
| ./docs/bar-observatory/config-rs/Cargo.toml | 2 |
| ./observatory/crates/bar-observatory/examples/dogfood.rs | 2 |
| ./observatory/scripts/session-init.sh | 2 |

## Cost (list-price estimate)

No token counts in this store — the token channel is captured by the proxy (`requests`), not by transcript ingest (see the capture runbook). Cost is **not recorded** here, not $0 spent.

## Still not built

3 analyzer(s) are **not yet built** — disclosed so an unbuilt measure is never mistaken for a measured zero. Capability state, not a finding.

<details><summary>Show the 3 not-yet-built analyzer(s) &amp; why each is absent</summary>

| Section | Why it is absent |
|---|---|
| Skills usage | Not observed — no Skill invocations in this transcript (0 is real here, not unbuilt). |
| Human-vs-AI recovery | Not observed — human-vs-AI recovery classification is not built yet. |
| Micro-observations & silent signals | Not observed — micro-observation extraction and silent-signal detection are not built yet; no findings are fabricated. |

</details>

## Evidence & integrity

Deterministic render — the same database renders byte-identically; no LLM and no network in the render path.

- `recorded_window`: 30h 58m (111,480,000 ms)
- `source_db_hash`: blake3:557f024108c3ecefff021360adb4f8c0ef223754c5704c6c46fe4ac5b4711ee6
- `template_hash`: blake3:b8bcf83ef579efa16b0185ca546f39cf8a408aa8c0a58051763eab7500742871
- `renderer_version`: 0.1.0
- `generated_at` (from DB): 2026-08-03T17:00:10Z

---
_Independent open-source project by Bradley Ross / Bradley.Academy. Academic crimson palette; no Harvard University marks are used and no endorsement is implied._

Report barobs-557f024108c3 · template bar-observatory-engineering-1.0 · Bradley.Academy
