# Run BAR Observatory — the front door

Three ways in, all reading the same local, deterministic SQLite database — nothing here calls
out to a network or an LLM to produce a report:

1. **The Claude Code plugin** (recommended) — installs the hooks and the MCP server for you, plus
   five slash commands covering setup and every report: `/bar-init`, `/bar-report`,
   `/bar-interpret`, `/bar-doctor`, `/bar-query`.
   ```
   /plugin marketplace add bar181/bar-observatory
   /plugin install bar-observatory@bar-observatory
   ```
   No GitHub access, or testing from a local clone? `/plugin marketplace add` accepts a local
   folder path the same way — `/plugin marketplace add /path/to/bar-observatory` — with no
   network call at all; the install line after it is unchanged.

   Then, once (to get the binaries the plugin's hooks/MCP server resolve via `PATH`):
   ```bash
   cargo install bar-hook bar-mcp bar-observatory
   ```
   See the [README](README.md#get-started--the-plugin-recommended-front-door) for the full
   command table and the disclosed-gap note on why that last step is still needed today.
2. **The `bar` CLI**, manually — below.
3. **The `bar-mcp` MCP server**, manually — for an AI agent that wants to query databases
   directly without the plugin.

## Fastest path — one script

From this folder:
```bash
./run.sh <path-to-a-claude-code-session.jsonl>          # e.g. ~/.claude/projects/<proj>/<session>.jsonl
```
`run.sh` builds the `bar` CLI, creates a local database, ingests the transcript (no API calls),
renders the report, and runs a live health check. Output lands in `./_run/` — open
`_run/*.report.html` and you're done.

## Manual path — five commands

```bash
bar init   --dir .                               # create local config + SQLite stores (never clobbers)
bar ingest .bar/ambient.sqlite <session>.jsonl    # always-on transcript parsing, no API calls
bar report .bar/ambient.sqlite --out .            # JSON + HTML + MD, deterministic
bar doctor .bar/ambient.sqlite                    # live health check: is the recorder OK? what did it capture?
bar query  .bar/ambient.sqlite --list             # direct read-only DB access (3 named queries + raw SELECT)
```

Each command is safe to re-run. `bar init` never overwrites an existing config; `bar report` on
an unchanged database always produces byte-identical output.

## Where do I get `bar`?

```bash
cargo install bar-observatory
```
No Rust/`cargo` installed yet? One line gets you both: `curl https://sh.rustup.rs -sSf | sh` (or
see [rustup.rs](https://rustup.rs)). Crate source lives and publishes from a private working
repo — this public repo carries no crate code by design. See [CRATES.md](CRATES.md) for
real-time publish status.

## Connect your AI agent instead

If an AI agent wants to query your capture database directly rather than shelling out to `bar
query`, point it at **[`bar-mcp`](https://crates.io/crates/bar-mcp)**, the read-only MCP server:

```bash
claude mcp add bar-observatory -- bar-mcp --db-root .bar
```

See [wiki/agent/AI-CONTEXT.md](wiki/agent/AI-CONTEXT.md) for the full tool list.

## What you get

- `*.report.html` — the human view (accessibility-checked).
- `*.report.md` — a terminal- and diff-friendly view.
- `*.report.json` — the machine contract: structured, typed output. A versioned schema ships at
  `schemas/report.schema.json` but is currently out of sync with live output (disclosed, not
  silently wrong — pending a schema regeneration).

**Honest by design:** a channel that wasn't captured reads `not_observed`, never a fabricated
`0`. See [process/](process/) for the full guided walkthrough — init, config, database creation,
ingestion, optional modules, and a real sample report — or [wiki/human-md/architecture.md](wiki/human-md/architecture.md)
for the crate-level technical detail.
