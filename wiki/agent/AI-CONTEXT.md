# BAR Observatory — AI Agent Context

This is the plugin front door for an AI agent (Claude Code or any MCP-speaking client) that
wants to **use** BAR Observatory, not build it. If you're looking for contributor/build-process
guidance, that lives in the private working repo, not here.

## Connect

`bar-mcp` is the read-only stdio MCP server over per-run capture DBs (ADR-049) — a session's
`bar` CLI (`bar init`/`bar ingest`/`bar report`) has already produced local SQLite files; this
server lets you query them directly instead of shelling out to `bar query`.

```bash
claude mcp add bar-observatory -- bar-mcp --db-root .bar
```

If this repo's own Claude Code plugin (`.claude-plugin/plugin.json` at the repo root) is
installed, this is already wired for you — along with `bar-hook`'s 21 lifecycle hooks and five
slash commands (`/bar-init`, `/bar-report`, `/bar-interpret`, `/bar-doctor`, `/bar-query`) a
human in the session can invoke directly. See the [README](../../README.md) for plugin install.

It never opens a DB in write mode. Every freeform text field crossing the boundary is routed
through PII redaction first. `db` arguments are paths relative to `--db-root`; absolute paths and
`..` are refused.

## What you can ask it

12 tools total, every one read-only, non-destructive, and idempotent. Call `get_hub` first in any
new session — it returns the full CLI/tool/hook registry so you know what else exists before you
guess:

- `get_hub` — the full CLI/tool/hook registry. Call this first.
- `list_runs` — every run in a database (or every database under `--db-root`).
- `get_ledger` — the T/R/L/Δ/E effort ledger for a run.
- `get_run_report` — the full report for one run.
- `query_delta_findings` — Δ (handoff-loss / drop-rate) findings for a run.
- `get_convergence` — convergence-test rows for a run.
- `compare_conditions` — aggregate ledgers across runs/conditions.
- `get_dead_letters` — capture-plane failures for a database.
- `get_completeness` — per-channel capture-completeness verdicts, never a bare boolean.
- `search_observations` — full-text search over the index database.
- `list_findings` — the reflection engine's stored recommendations.
- `recall_context` — memory-graph recall, up to 3 hops.

## If you'd rather use the CLI directly

`bar doctor <db>` — live health check. `bar query <db> tools|timeline|errors` or a raw
read-only `--sql "SELECT …"` — direct DB access without MCP. `bar report <db>` — the
deterministic JSON/HTML/MD report. See [RUN.md](../../RUN.md) and [CRATES.md](../../CRATES.md)
for the full command set and crate list.

## A worked example you can read without running anything

[`examples/deterministic/session.report.json`](../../examples/deterministic/session.report.json)
is literally what `bar report` wrote over the transcripts in
[`examples/capture/`](../../examples/capture/) — same shape you get back from `get_run_report`.
The HTML and Markdown beside it render from that same JSON in one pass, so the three cannot
disagree. `examples/capture/run.sh` reproduces the JSON field for field; only
`integrity.source_db_hash` and the `id` derived from it differ, because they hash the SQLite
file and two ingests are not byte-identical.

**The project in those examples is a stand-in.** Every count, rate and ranking is real — measured
by the tool from the shipped transcripts. The identifiers are not: `orbit` is not a real
repository, and the paths, commit subjects, prompt titles and sub-agent names are demo values. Do
not cite them as facts about anyone's codebase.

## Verifying claims yourself

Don't take the deterministic/local-only/byte-identical claims in this doc on faith — check them.
[`tests/verify.sh`](../../tests/verify.sh) is a black-box suite, runnable by anyone, that
installs from crates.io the way a stranger would and checks six specific claims: clean install,
byte-identical reproduction of the shipped example (99 of 101 fields match; the two that don't —
`source_db_hash`, `report.id` — are the ones already disclosed as expected to vary), checksum
integrity, `bar doctor` health, a config that actually loads, and the 12-tool MCP contract above.
It does not and cannot re-prove the private 699-test suite — that source isn't public, by design
(§ Ground rules) — so treat "699 tests" as a disclosed, unverifiable-from-here claim and the
`tests/` suite as the part you actually get to check. See
[`wiki/human-md/verification.md`](../human-md/verification.md) for the full write-up and
[`tests/README.md`](../../tests/README.md) for the exact commands and expected output.

## Ground rules

- BAR Observatory is **local-only and deterministic**: no LLM, no network call in the render
  path, same DB → byte-identical report. Anything you're told came from an *interpreted* report
  is LLM-written prose layered on top of the facts, kept in a separate artifact — never mutate or
  invent the deterministic facts underneath it.
- A missing capture channel is reported as `not_observed`, never a fabricated zero — don't
  silently fill a gap in with a guess.

## Why this document reads the way it does

This page is the "AI" register in this project's three-layer documentation architecture — human
prose, structured agent-facing docs (this file), and AISP symbolic specs
([`wiki/aisp/HUB.aisp`](../aisp/HUB.aisp)). See
[`documentation-layers.html`](../human-html/documentation-layers.html) for why the split exists and
what's actually generated versus hand-maintained today (hand-maintained, honestly disclosed). For
what a `get_run_report` call actually returns, annotated field by field against a real example:
[`report-guide.html`](../human-html/report-guide.html).
