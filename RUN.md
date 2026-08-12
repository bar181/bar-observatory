# Run BAR Observatory — the front door

BAR Observatory is a **local-only, deterministic flight-recorder for Claude Code sessions**. It
turns a session transcript into an auditable report (JSON + HTML + Markdown) with **no API key, no
network, no LLM in the render path**. Same database → byte-identical report.

## Fastest path — one script
From this folder:
```bash
./run.sh <path-to-a-claude-code-session.jsonl>          # e.g. ~/.claude/projects/<proj>/<session>.jsonl
```
`run.sh` builds the `bar` CLI (from the in-repo crates today; from crates.io at release), creates a
local database, ingests the transcript (no API calls), renders the report, and runs `bar doctor`.
Output lands in `./_run/` — open `_run/*.report.html`.

## Manual path — the 4 steps
```bash
bar init   --dir .                         # create local config + SQLite stores (never clobbers)
bar ingest .bar/ambient.sqlite <session>.jsonl   # always-done ingest, no API calls
bar report .bar/ambient.sqlite --out .           # JSON + HTML + MD, deterministic
bar doctor .bar/ambient.sqlite                   # live health: is the recorder OK? what did it capture?
bar query  .bar/ambient.sqlite --list            # direct read-only DB access (3 use cases + raw SELECT)
```

## Where do I get `bar`?
- **In the private working repo now:** `run.sh` builds it from `../bar-obs-private/crates`
  automatically (that's where crate source lives — this public repo carries no crate code).
- **At release:** `cargo install bar-observatory` (crates.io — human-gated, ADR-016), then the four
  commands above work anywhere.

## What you get
- `*.report.html` — the human view (Harvard-crimson, a11y-checked).
- `*.report.md` — a terminal/diff-friendly view.
- `*.report.json` — the machine contract (validates against `schemas/report.schema.json`).

Honesty by design: a channel that wasn't captured reads **"not recorded"**, never a fabricated `0`.
See [process/](process/) for init · config · database · ingestion · optional modules · sample.
