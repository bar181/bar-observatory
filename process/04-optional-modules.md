# Step 4 — Optional modules: what layers on top of the deterministic core

The deterministic core (the same database always produces the exact same output, byte for byte)
— capture, store, render — is always on and never changes shape. Layered on top of it are five
modules. Each one is opt-in, and every one of them keeps the same rule: nothing optional is
allowed to leak non-determinism into the deterministic report.

| Module | What it adds | Determinism |
|---|---|---|
| **Coverage oracles** (automated checks with a known-right answer) | hooks/transcript/OTLP-span loss detection → `verified` / `gap_detected` | deterministic |
| **Cost estimate** | a labeled token→USD list-price estimate (honestly reports "not recorded" when there are no token rows) | deterministic |
| **Detectors** | tool usage, task ledger, agents/skills, rework, error results, validation runs | deterministic |
| **Interpreted report** | an optional self-improvement / LLM-judge layer, kept as a separate artifact from the deterministic file | non-deterministic by nature — never in the deterministic report |
| **Direct query** | `bar query` — read-only DB access for slices the report doesn't pre-bake | deterministic (named queries run in a fixed, explicit order) |

## The interpreted report: BAR owns the facts, an LLM owns the wording

Want prose alongside the raw numbers? `bar interpret` writes a **deterministic brief** — the
exact facts plus tone/coverage guidance for the audience you pick:

```bash
bar interpret <db> --audience engineering|executive
```
(Plugin: `/bar-interpret engineering` or `/bar-interpret executive`.)

Hand that brief to your Claude Code session (or any LLM) and it writes the interpreted report —
technical detail for **engineering**, value/cost/risk framing for **executive**. The brief is
byte-identical every time you generate it (BAR owns the facts); only the prose written from it
varies (the LLM owns the wording). BAR never invents numbers — the brief pins every one of them.

## Direct query: when the report doesn't pre-bake what you need

For a slice the report doesn't cover, go straight to the database:

```bash
bar query <db> --list                       # the 3 named use cases + how format/limit work
bar query <db> tools --format csv           # tool-usage breakdown (also: timeline, errors)
bar query <db> --sql "SELECT role, count(*) FROM transcript_turns GROUP BY role"
```

The connection is opened `SQLITE_OPEN_READ_ONLY`, so any write you accidentally send in `--sql`
is refused by SQLite itself — not by a regex (a text-pattern-matching rule) BAR could get wrong. `--format table|json|csv` picks
a human-readable table or a machine-friendly json/csv for piping elsewhere; `--limit N` windows
the output (`--limit 0` returns everything). Named queries run in a fixed order, so a given
database always renders the same result.

If you're an AI agent rather than a person running commands, you don't need to shell out to `bar
query` at all — **[`bar-mcp`](https://crates.io/crates/bar-mcp)** exposes the same read-only
queries as MCP (Model Context Protocol — the standard interface AI agents use to call external
tools) tools you can call directly. See the [README](../README.md) for how to connect it.

Deeper technical detail on the crates behind each module: [wiki/architecture.md](../wiki/human-md/architecture.md).

Next: [05 — Sample report](05-sample-report.md) to see all of this rendered in a real report.
