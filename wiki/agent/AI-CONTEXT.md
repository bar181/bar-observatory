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

## Ground rules

- BAR Observatory is **local-only and deterministic**: no LLM, no network call in the render
  path, same DB → byte-identical report. Anything you're told came from an *interpreted* report
  is LLM-written prose layered on top of the facts, kept in a separate artifact — never mutate or
  invent the deterministic facts underneath it.
- A missing capture channel is reported as `not_observed`, never a fabricated zero — don't
  silently fill a gap in with a guess.
