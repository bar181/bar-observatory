# BAR Observatory (Base Agentic Reporter)

**A local-only, deterministic flight recorder for Claude Code agent sessions.** BAR Observatory
watches what an AI coding agent actually did — every tool call, every task, every rework loop —
and turns it into an auditable report you (or your own AI agent) can trust: same database in,
byte-identical report out, every time. No LLM in the render path, no network call, no API key.
If you've ever wondered *"what did my agent actually do in that session, and can I prove it?"* —
this is the tool.

## Why BAR Observatory

- **Deterministic, not vibes-based.** The render path is pure: `report.json`/`.html`/`.md` are a
  pure function of the capture database. Re-run it a year later, get the identical bytes.
- **Local-only.** Everything runs on your machine. Nothing is transmitted anywhere.
- **Honest about gaps.** A channel that wasn't captured is reported as `not_observed` — never a
  fabricated zero. If BAR Observatory doesn't know, it says so.
- **No API key required.** The primary path — parsing a session transcript you already have — makes
  zero network calls. Optional capture modules (proxy, OTLP) are opt-in.
- **Two front doors, one source of truth.** A human-friendly CLI and an AI-agent-friendly MCP
  server both read the exact same local SQLite database.

## Get started — the plugin (recommended front door)

The fastest way in is the **Claude Code plugin** in this repo. It handles both halves of setup
for you:

- **Setup**: wires all 21 lifecycle hooks and the read-only MCP server automatically — no
  hand-editing hook settings, no manually running `claude mcp add`.
- **Everyday use**: five slash commands so setting up a project and generating any report is one
  line inside your Claude Code session, not a terminal round-trip.

| Command | What it does |
|---|---|
| `/bar-init` | **Start here.** Set up `.bar/` for this project (idempotent, safe to re-run) |
| `/bar-report` | Generate the deterministic report (JSON + HTML + MD) |
| `/bar-interpret` | Generate the optional self-improvement report (engineering or executive) |
| `/bar-doctor` | Live health check — is the recorder actually working? |
| `/bar-query` | Direct read-only DB access — tools, timeline, errors, or raw SQL |

Install the plugin from this repo, then run `/bar-init` to set up your first project:
```bash
cargo install bar-hook bar-mcp bar-observatory   # crates.io — puts the binaries on PATH
```
> Today the plugin resolves `bar-hook`/`bar-mcp` via PATH rather than a bundled binary — a
> disclosed gap, not an oversight (no release pipeline assembles per-platform binaries into the
> plugin zip yet). Hook commands Claude Code can't resolve fail harmlessly and never block a
> session, so installing the plugin before the binaries is safe either order.

## Or: the CLI directly

```bash
cargo install bar-observatory
bar init --dir .                                     # create local config + SQLite stores (idempotent)
bar ingest .bar/ambient.sqlite <your-session>.jsonl   # parse a real Claude Code transcript, no API calls
bar report .bar/ambient.sqlite --out .                # JSON + HTML + MD, deterministic
```
Open the `.html` file. That's your report. See **[RUN.md](RUN.md)** for the one-script version
(`./run.sh <session.jsonl>`) and the full command reference. Crates publish incrementally,
dependency-tier-ordered — see [CRATES.md](CRATES.md) for each crate's real, current status.

## For AI agents

Connect directly to **[`bar-mcp`](https://crates.io/crates/bar-mcp)** (already wired if you
installed the plugin above):
```bash
claude mcp add bar-observatory -- bar-mcp --db-root .bar
```
12 read-only tools — call `get_hub` first. Full tool list and ground rules:
**[wiki/agent/AI-CONTEXT.md](wiki/agent/AI-CONTEXT.md)**.

## How it works

A guided, step-by-step walkthrough of the whole pipeline — init, config, database creation,
ingestion, optional modules, and a real sample report re-rendered every phase:

1. [Init](process/00-init.md) — `bar init`, idempotent, never clobbers existing config
2. [Config](process/01-config.md) — typed TOML, 5-layer resolver, blake3 integrity
3. [Database creation](process/02-database-creation.md) — one local SQLite file per run, portable
4. [Data ingestion](process/03-ingestion.md) — always-on transcript parsing, no API calls
5. [Optional modules](process/04-optional-modules.md) — coverage oracles, cost estimate,
   detectors, the optional interpreted layer
6. [Sample report](process/05-sample-report.md) — a real, current example report
7. [Use cases](process/06-use-cases.md) — real proof points from a real captured session

## The crates

BAR Observatory is a `bar` CLI (crate `bar-observatory`) built on a small suite of focused
`bar-*` crates — a SQLite substrate, a query surface, an ingest parser, the MCP server, and more.
**[CRATES.md](CRATES.md)** has the full list, what each one does, and a live link to its
crates.io page. Crate source lives and publishes from a private working repo; this repository is
the front door and documentation only — no crate source here by design.

## Reference material

- `schemas/` — the report contract (JSON Schema) · `config/` — default TOMLs
- `examples/` — real, current sample reports
- [LICENSE](LICENSE) (MIT) · [SECURITY.md](SECURITY.md) · [CONTRIBUTING.md](CONTRIBUTING.md) · [CHANGELOG.md](CHANGELOG.md)
- `checksums/SHA256SUMS.txt` + `provenance/PROVENANCE.json` — integrity and build provenance
