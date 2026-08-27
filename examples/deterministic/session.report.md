**Evidence · deterministic · no LLM in the render path**

# BAR Observatory — captured session report

> Observe how agentic work actually gets done.

| Sessions | Transcript turns | Tool calls | Tasks | Errors | Recorded window |
|---:|---:|---:|---:|---:|---:|
| **7** | **9,132** | **3,171** | **40 / 40** | **60** | **322h 59m** |

*Report `barobs-94c4ff164bd8` · renderer 0.3.0 · generated from the store at 2026-05-18T06:06:00Z. Uncaptured channels read "not recorded", never a fabricated 0.*

**Contents**

01. [Executive summary](#executive-summary)
02. [Summary](#summary)
03. [Capture quality](#capture-quality)
04. [Agent activity](#agent-activity)
05. [Failures](#failures)
06. [Flaky tests · measured](#flaky-tests--measured)
07. [Task ledger](#task-ledger)
08. [Sub-agents dispatched](#sub-agents-dispatched)
09. [Skills invoked](#skills-invoked)
10. [Validation evidence · measured](#validation-evidence--measured)
11. [Rework · measured](#rework--measured)
12. [Cross-run hotspots · measured](#cross-run-hotspots--measured)
13. [Cost (list-price estimate)](#cost-list-price-estimate)
14. [Still not built](#still-not-built)
15. [Evidence & integrity](#evidence--integrity)

## Executive summary

**Over 322h 59m, the session made 3,171 tool calls across 9,132 transcript turns, dispatched 40 sub-agent run(s), and captured 60 error result(s).**

### Key findings

- **60 tool error(s) were captured — the failures are recorded, not swallowed.**
  - Worst: Bash ×45. See the Failures section for the per-tool breakdown.
- **One file absorbed the most churn: 77 edits.**
  - `orbit/README.md` — a refactor / test-coverage candidate.
- **Validation was not fully green at capture end: 29 failing vs 344 passing.**
  - From real `test result:` lines in the tool outputs (measured, not self-reported).
- **6 of 9 capture channels were not recorded this session.**
  - Uncaptured channels read "not recorded" (never a fabricated 0) — this is a transcript-only ingest.

### Recommendations (resolution-first)

- **P1** — Resolve the remaining failing tests before relying on the session's completion claims.
- **P2** — Review `orbit/README.md` (highest edit churn) for a refactor or missing test coverage.
- **P3** — Enable OTEL telemetry + hooks to capture tokens/cost, timeline, and coverage (see the process docs).

In a recorded window of 322h 59m, the recorder captured 9,132 transcript turns (hook, log/metric, and span channels were not recorded in this transcript-only ingest); hook-lifecycle coverage is unverified; a TRANSCRIPT coverage gap was detected (see capture quality — a dead-letter count of 0 is not the whole completeness story), and 0 dead-letter loss(es) were detected. The agent made 3,171 tool calls; the task ledger shows 40 task(s) (40 completed, 0 in-progress, 0 other), and 96 attributable file(s) show repeated-edit churn.

| Outcome (self-reported) | Rework signal | Recorded window |
|---|---|---|
| **40/40 tasks completed** (self-reported (TodoWrite/TaskUpdate); per-task claim≠evidence linkage is P8) | **96 rework hotspot(s), 60 error(s)** (measured repeated-edit / error churn (structural signal, not a quality judgment)) | **322h 59m** |

**Action required: review 96 rework hotspot(s).** The most-churned file(s) are under Rework — repeated edits often mark a hard spot worth a test or design pass. Structural signal, not a quality verdict.

> Colour/marker key: a **measured gap or risk in the session** is distinct from a **recorder capability not yet enabled** — the latter is never rendered as a finding or a zero.

## Summary

| Measure | Value |
|---|---:|
| Runs / sessions | 7 |
| Timeline events | not recorded |
| Hook events | not recorded |
| Log/metric events | not recorded |
| OTLP spans | not recorded |
| Transcript turns | 9,132 |
| Requests | not recorded |
| Tokens in | not recorded |
| Tokens out | not recorded |
| Tokens total | not recorded |
| Capture losses | 0 |

## Capture quality

No unresolved capture losses (dead_letters has no resolved=0 rows).

| Channel | Status | Coverage | Recorded | What this means |
|---|---|---|---:|---|
| hooks | not_recorded | not_applicable | 0 | No hooks rows in this store. |
| events | not_recorded | not_applicable | 0 | No events rows in this store. |
| spans | not_recorded | not_applicable | 0 | No spans rows in this store. |
| transcripts | partial | gap_detected | 9,132 | 9132 turns; coverage gap (MEASURED) — 629 dangling parent(s); 136 unpaired tool_use/tool_result. |
| requests | not_recorded | not_applicable | 0 | No requests rows in this store. Remediable: the token/cost channel is captured by the local proxy (point ANTHROPIC_BASE_URL at it), not by transcript ingest — this is expected on a transcript-only ingest, not a capture failure. |
| file_history | not_recorded | not_applicable | 0 | No file_history rows in this store. |
| plan_docs | not_observed | not_applicable | 0 | Not observed — no correlation_stats row for channel='plan_docs' in this store (ingest_plans has not run against this store's data yet). |
| raw_logs | not_observed | not_applicable | 0 | no_data: raw_logs has a real writer but no ambient-capture trigger wires it — on-demand-only by design, not a capture gap. No call site in this store's ingest path has invoked it. |
| provider_cost_usd | not_recorded | not_applicable | 0 | Subscription auth (ADR-024) exposes no authoritative per-token USD; a labeled list-price ESTIMATE is derived instead (see cost). Tokens + wall-clock stay primary. |

<details><summary>Methodology &amp; definitions (status vs coverage, the oracle)</summary>

**Status** is loss-detection (`complete` = no dead-letter loss; `partial` = a measured loss/gap; `not_recorded` = no rows). **Coverage** is a separate axis: `verified` = an oracle measured completeness (hooks: session bracketed by SessionStart+Stop AND every PreToolUse paired with a PostToolUse); `gap_detected` names the shortfall; `unverified` = no oracle for that channel yet. A green status is never a coverage guarantee.
</details>

## Agent activity

What the agent actually did: **3,171** tool calls this session, across 17 distinct tool(s).

| Tool | Calls | Share |
|---|---:|---|
| Bash | 1,706 | ██████████████████████ 53.8% |
| Edit | 496 | ██████ 15.6% |
| Read | 410 | █████ 12.9% |
| TaskUpdate | 209 | ███ 6.6% |
| TaskCreate | 132 | ██ 4.2% |
| Write | 97 | █ 3.1% |
| Agent | 40 | █ 1.3% |
| ToolSearch | 19 | █ 0.6% |
| TaskOutput | 16 | █ 0.5% |
| ScheduleWakeup | 15 | █ 0.5% |
| AskUserQuestion | 11 | █ 0.3% |
| WebSearch | 9 | █ 0.3% |
| Skill | 6 | █ 0.2% |
| WebFetch | 2 | █ 0.1% |
| EnterPlanMode | 1 | █ 0.0% |
| ExitPlanMode | 1 | █ 0.0% |
| Workflow | 1 | █ 0.0% |

## Failures

Real failures captured from tool outputs: 60 error result(s) across 7 distinct tool(s), categorized (mcp / tool / unknown). This section surfaces both system failures (a tool or MCP not working) and coded errors so they are recorded, not silently dropped.

| Tool | Kind | Errors |
|---|---|---:|
| Bash | tool | 45 |
| Agent | tool | 5 |
| Edit | tool | 3 |
| Read | tool | 2 |
| Skill | tool | 2 |
| unknown | unknown | 2 |
| Write | tool | 1 |

## Flaky tests · measured

3 test(s) both passed AND failed across the session's captured test runs (measured from `test … ok`/`FAILED` lines, no LLM). This is a verdict-change signal to investigate — on an actively-editing session a flip can be a fix or a regression, not only non-determinism.

| Test | Passes | Fails |
|---|---:|---:|
| round_trips_losslessly | 5 | 3 |
| query_failures_are_disclosed_not_silent | 3 | 2 |
| committed_hooks_match_generator | 2 | 1 |

## Task ledger

Real ledger from the ingested transcript: 40 task(s) — 40 completed, 0 in-progress, 0 pending, 0 other/untracked (sums to 40). State is the agent's SELF-REPORT (TodoWrite/TaskUpdate); per-task attempt/loop/evidence linkage (claim≠evidence) is P8 (rendered null, not a measured zero).

| Task | State (self-reported) |
|---|---|
| Draft the public README and the quickstart it promises | completed |
| Fix the plugin manifest so the hooks load once | completed |
| Split the configuration reference out of the README | completed |
| Add a run-it-yourself walkthrough for a first-time reader | completed |
| Check every external link in the docs tree | completed |
| Tighten the error text so it names the failing input | completed |
| Add a worked example for the query command | completed |
| Document what the tool does not observe yet | completed |
| Rewrite the comparison page for a non-specialist | completed |
| Add a licence header check to the release script | completed |
| Make the report render byte-identical across runs | completed |
| Reconcile the handbook figures against the manifest | completed |
| Verify the plugin installs from a local folder path | completed |
| Collect the open questions into one document | completed |
| Add a schema-drift note to the examples index | completed |
| Trim the quickstart to a single screen | completed |
| Confirm the guide builds with scripting disabled | completed |
| Record the provenance of every generated file | completed |
| Add an accessibility pass over the report pages | completed |
| Reconcile the language ranking with the rework list | completed |
| Replace the placeholder screenshots with real ones | completed |
| Name the two dates the record carries | completed |
| Port the crate index and check every publish flag | completed |
| Add a print stylesheet to the report | completed |
| Check the report at three viewport widths | completed |
| Move the appendices behind a disclosure control | completed |
| Give the failure list a root-cause column | completed |
| Document the redaction policy in the guide | completed |
| Add a worked example for the interpret command | completed |
| Verify the examples folder has no dead links | completed |
| Regenerate the crate index from the manifests | completed |
| Write the contributing guide | completed |
| Add a security policy and a disclosure address | completed |
| Write the release checklist and run it end to end | completed |
| Tag the release candidate and write the notes | completed |
| Add the capture-channel diagram to the guide | completed |
| Redact private paths from the example output | completed |
| Cross-link the guide pages and add a trust section | completed |
| Regenerate the checksum manifest and verify it | completed |
| Review the changelog against the actual commits | completed |

## Sub-agents dispatched

Real sub-agent hierarchy from the transcript: 40 dispatch(es) across 8 sub-agent type(s). Deterministic post-hoc 'who was dispatched'; live nested-span viz needs the runtime (conceded).

| Sub-agent type | Dispatches |
|---|---:|
| general-purpose | 17 |
| reviewer | 10 |
| docs-researcher | 5 |
| requirements-validator | 3 |
| docs-curator | 2 |
| release-verifier | 1 |
| skeptic-reviewer | 1 |
| unspecified | 1 |

## Skills invoked

Real skill invocations from the transcript: 5 skill(s).

| Skill | Invocations |
|---|---:|
| review | 2 |
| loop | 1 |
| quality-assessment | 1 |
| quality-court | 1 |
| release-protocol | 1 |

## Validation evidence · measured

Real validation EVIDENCE from ingested tool outputs: 373 verdict line(s) (373 cargo) — 344 passed, 29 failed; last verdict PASSED. (One `cargo test --workspace` emits several such lines — one per crate — so this counts result-lines, not invocations; the last verdict is as of the capture window's end.) Measured, not self-reported: it begins to back the ledger's completion claims.

## Rework · measured

Real deterministic rework signals from the transcript: 96 attributable file(s) edited ≥2× (churn) + 60 error tool_result(s). Structural signals (repeated-edit / error) — NOT hallucination/quality judgment (that is the interpreted report, P10+). Repeated edits are normal in iterative/TDD work; this flags concentration, not failure.

| File (edited ≥2×) | Edits |
|---|---:|
| orbit/README.md | 77 |
| orbit/index.html | 22 |
| orbit/docs/guide/README.md | 16 |
| orbit/docs/manifest.json | 16 |
| orbit/CHANGELOG.md | 15 |
| orbit/docs/guide/handbook.html | 15 |
| .gitignore | 12 |
| orbit/RUN.md | 9 |
| orbit/docs/layers.html | 9 |
| specs/10-capabilities-review.md | 9 |
| specs/13-pre-release-checklist.md | 9 |
| NOTES.md | 7 |
| review/verify/src/main.rs | 7 |
| AGENTS.md | 6 |
| review/pr-a/crates/orbit/src/detectors.rs | 6 |
| orbit/config/proxy-26.toml | 5 |
| orbit/config/query-22.toml | 5 |
| orbit/crates/orbit-core/Cargo.toml | 5 |
| orbit/crates/orbit-core/src/lib.rs | 5 |
| orbit/crates/orbit-ingest/Cargo.toml | 5 |
| orbit/crates/orbit-ingest/src/mod20.rs | 5 |
| orbit/crates/orbit-metrics/Cargo.toml | 5 |
| orbit/crates/orbit-proxy/src/lib.rs | 5 |
| orbit/crates/orbit-query/src/lib.rs | 5 |
| orbit/crates/orbit-registry/src/lib.rs | 5 |
| orbit/crates/orbit-resolve/Cargo.toml | 5 |
| orbit/crates/orbit-schema/Cargo.toml | 5 |
| orbit/crates/orbit-schema/src/mod24.rs | 5 |
| orbit/crates/orbit-testenv/src/lib.rs | 5 |
| orbit/docs/guide/cli-25.md | 5 |
| orbit/docs/guide/config-5.md | 5 |
| orbit/docs/guide/docs-17.md | 5 |
| orbit/docs/guide/hooks-9.md | 5 |
| orbit/docs/guide/render-21.md | 5 |
| orbit/docs/guide/review-13.md | 5 |
| orbit/docs/guide/store-1.md | 5 |
| specs/23-render-notes.md | 5 |
| specs/27-cli-notes.md | 5 |
| specs/31-index-notes.md | 5 |
| specs/35-sanitize-notes.md | 5 |
| specs/39-store-notes.md | 5 |
| specs/43-config-notes.md | 5 |
| specs/47-hooks-notes.md | 5 |
| orbit/crates/orbit-metrics/src/mod28.rs | 3 |
| orbit/config/core-54.toml | 2 |
| orbit/config/ingest-38.toml | 2 |
| orbit/config/ingest-74.toml | 2 |
| orbit/config/metrics-46.toml | 2 |
| orbit/config/proxy-62.toml | 2 |
| orbit/config/query-58.toml | 2 |
| orbit/config/registry-30.toml | 2 |
| orbit/config/registry-66.toml | 2 |
| orbit/config/resolve-50.toml | 2 |
| orbit/config/schema-42.toml | 2 |
| orbit/config/schema-78.toml | 2 |
| orbit/config/testenv-34.toml | 2 |
| orbit/config/testenv-70.toml | 2 |
| orbit/crates/orbit-core/src/mod36.rs | 2 |
| orbit/crates/orbit-core/src/mod72.rs | 2 |
| orbit/crates/orbit-ingest/src/mod56.rs | 2 |
| orbit/crates/orbit-metrics/src/mod64.rs | 2 |
| orbit/crates/orbit-proxy/src/mod44.rs | 2 |
| orbit/crates/orbit-proxy/src/mod80.rs | 2 |
| orbit/crates/orbit-query/src/mod40.rs | 2 |
| orbit/crates/orbit-query/src/mod76.rs | 2 |
| orbit/crates/orbit-registry/src/mod48.rs | 2 |
| orbit/crates/orbit-resolve/src/mod32.rs | 2 |
| orbit/crates/orbit-resolve/src/mod68.rs | 2 |
| orbit/crates/orbit-schema/src/mod60.rs | 2 |
| orbit/crates/orbit-testenv/src/mod52.rs | 2 |
| orbit/docs/guide/cli-61.md | 2 |
| orbit/docs/guide/config-41.md | 2 |
| orbit/docs/guide/config-77.md | 2 |
| orbit/docs/guide/docs-53.md | 2 |
| orbit/docs/guide/hooks-45.md | 2 |
| orbit/docs/guide/index-29.md | 2 |
| orbit/docs/guide/index-65.md | 2 |
| orbit/docs/guide/render-57.md | 2 |
| orbit/docs/guide/review-49.md | 2 |
| orbit/docs/guide/sanitize-33.md | 2 |
| orbit/docs/guide/sanitize-69.md | 2 |
| orbit/docs/guide/store-37.md | 2 |
| orbit/docs/guide/store-73.md | 2 |
| specs/51-review-notes.md | 2 |
| specs/55-docs-notes.md | 2 |
| specs/59-render-notes.md | 2 |
| specs/63-cli-notes.md | 2 |
| specs/67-index-notes.md | 2 |
| specs/71-sanitize-notes.md | 2 |
| specs/75-store-notes.md | 2 |
| specs/79-config-notes.md | 2 |
| specs/83-hooks-notes.md | 2 |
| specs/87-review-notes.md | 2 |
| specs/91-docs-notes.md | 2 |
| specs/95-render-notes.md | 2 |
| specs/99-cli-notes.md | 2 |

## Cross-run hotspots · measured

Real deterministic cross-run churn signal: 96 file(s) edited ≥2× when aggregated across every run with a reliable workspace root in this store.

| File (edited ≥2× across runs) | Edits |
|---|---:|
| orbit/README.md | 77 |
| orbit/index.html | 22 |
| orbit/docs/guide/README.md | 16 |
| orbit/docs/manifest.json | 16 |
| orbit/CHANGELOG.md | 15 |
| orbit/docs/guide/handbook.html | 15 |
| .gitignore | 12 |
| orbit/RUN.md | 9 |
| orbit/docs/layers.html | 9 |
| specs/10-capabilities-review.md | 9 |
| specs/13-pre-release-checklist.md | 9 |
| NOTES.md | 7 |
| review/verify/src/main.rs | 7 |
| AGENTS.md | 6 |
| review/pr-a/crates/orbit/src/detectors.rs | 6 |
| orbit/config/proxy-26.toml | 5 |
| orbit/config/query-22.toml | 5 |
| orbit/crates/orbit-core/Cargo.toml | 5 |
| orbit/crates/orbit-core/src/lib.rs | 5 |
| orbit/crates/orbit-ingest/Cargo.toml | 5 |
| orbit/crates/orbit-ingest/src/mod20.rs | 5 |
| orbit/crates/orbit-metrics/Cargo.toml | 5 |
| orbit/crates/orbit-proxy/src/lib.rs | 5 |
| orbit/crates/orbit-query/src/lib.rs | 5 |
| orbit/crates/orbit-registry/src/lib.rs | 5 |
| orbit/crates/orbit-resolve/Cargo.toml | 5 |
| orbit/crates/orbit-schema/Cargo.toml | 5 |
| orbit/crates/orbit-schema/src/mod24.rs | 5 |
| orbit/crates/orbit-testenv/src/lib.rs | 5 |
| orbit/docs/guide/cli-25.md | 5 |
| orbit/docs/guide/config-5.md | 5 |
| orbit/docs/guide/docs-17.md | 5 |
| orbit/docs/guide/hooks-9.md | 5 |
| orbit/docs/guide/render-21.md | 5 |
| orbit/docs/guide/review-13.md | 5 |
| orbit/docs/guide/store-1.md | 5 |
| specs/23-render-notes.md | 5 |
| specs/27-cli-notes.md | 5 |
| specs/31-index-notes.md | 5 |
| specs/35-sanitize-notes.md | 5 |
| specs/39-store-notes.md | 5 |
| specs/43-config-notes.md | 5 |
| specs/47-hooks-notes.md | 5 |
| orbit/crates/orbit-metrics/src/mod28.rs | 3 |
| orbit/config/core-54.toml | 2 |
| orbit/config/ingest-38.toml | 2 |
| orbit/config/ingest-74.toml | 2 |
| orbit/config/metrics-46.toml | 2 |
| orbit/config/proxy-62.toml | 2 |
| orbit/config/query-58.toml | 2 |
| orbit/config/registry-30.toml | 2 |
| orbit/config/registry-66.toml | 2 |
| orbit/config/resolve-50.toml | 2 |
| orbit/config/schema-42.toml | 2 |
| orbit/config/schema-78.toml | 2 |
| orbit/config/testenv-34.toml | 2 |
| orbit/config/testenv-70.toml | 2 |
| orbit/crates/orbit-core/src/mod36.rs | 2 |
| orbit/crates/orbit-core/src/mod72.rs | 2 |
| orbit/crates/orbit-ingest/src/mod56.rs | 2 |
| orbit/crates/orbit-metrics/src/mod64.rs | 2 |
| orbit/crates/orbit-proxy/src/mod44.rs | 2 |
| orbit/crates/orbit-proxy/src/mod80.rs | 2 |
| orbit/crates/orbit-query/src/mod40.rs | 2 |
| orbit/crates/orbit-query/src/mod76.rs | 2 |
| orbit/crates/orbit-registry/src/mod48.rs | 2 |
| orbit/crates/orbit-resolve/src/mod32.rs | 2 |
| orbit/crates/orbit-resolve/src/mod68.rs | 2 |
| orbit/crates/orbit-schema/src/mod60.rs | 2 |
| orbit/crates/orbit-testenv/src/mod52.rs | 2 |
| orbit/docs/guide/cli-61.md | 2 |
| orbit/docs/guide/config-41.md | 2 |
| orbit/docs/guide/config-77.md | 2 |
| orbit/docs/guide/docs-53.md | 2 |
| orbit/docs/guide/hooks-45.md | 2 |
| orbit/docs/guide/index-29.md | 2 |
| orbit/docs/guide/index-65.md | 2 |
| orbit/docs/guide/render-57.md | 2 |
| orbit/docs/guide/review-49.md | 2 |
| orbit/docs/guide/sanitize-33.md | 2 |
| orbit/docs/guide/sanitize-69.md | 2 |
| orbit/docs/guide/store-37.md | 2 |
| orbit/docs/guide/store-73.md | 2 |
| specs/51-review-notes.md | 2 |
| specs/55-docs-notes.md | 2 |
| specs/59-render-notes.md | 2 |
| specs/63-cli-notes.md | 2 |
| specs/67-index-notes.md | 2 |
| specs/71-sanitize-notes.md | 2 |
| specs/75-store-notes.md | 2 |
| specs/79-config-notes.md | 2 |
| specs/83-hooks-notes.md | 2 |
| specs/87-review-notes.md | 2 |
| specs/91-docs-notes.md | 2 |
| specs/95-render-notes.md | 2 |
| specs/99-cli-notes.md | 2 |

## Cost (list-price estimate)

No token counts in this store — the token channel is captured by the proxy (`requests`), not by transcript ingest (see the capture runbook). Cost is **not recorded** here, not $0 spent.

## Still not built

2 analyzer(s) are **not yet built** — disclosed so an unbuilt measure is never mistaken for a measured zero. Capability state, not a finding.

<details><summary>Show the 2 not-yet-built analyzer(s) &amp; why each is absent</summary>

| Section | Why it is absent |
|---|---|
| Human-vs-AI recovery | Not observed — human-vs-AI recovery classification is not built yet. |
| Micro-observations & silent signals | Not observed — micro-observation extraction and silent-signal detection are not built yet; no findings are fabricated. |

</details>

## Evidence & integrity

Deterministic render — the same database renders byte-identically; no LLM and no network in the render path.

- `recorded_window`: 322h 59m (1,162,740,000 ms)
- `source_db_hash`: blake3:94c4ff164bd809155968649f1a7bc068b9faed9f520ea88e3f8473b0294ccc98
- `template_hash`: blake3:3384a44fb8e759ebed83168fa79ff83c4cf30b6b2bb3867be4c91310fd5a022e
- `renderer_version`: 0.3.0
- `redact_mode`: off · `redact_paths`: verbatim · `redact_secrets`: detect_and_report
- `generated_at` (from DB): 2026-05-18T06:06:00Z

---
_Independent open-source project by Bradley Ross / Bradley.Academy. No third-party marks are used and no endorsement is implied._

Report barobs-94c4ff164bd8 · template bar-observatory-engineering-1.0 · Bradley.Academy
