# 04 — Optional modules

The deterministic core (capture → store → report) is always on. These layer on top and are opt-in:

| Module | What it adds | Determinism |
|---|---|---|
| **Coverage oracles** | hooks/transcript/span loss detection → `verified` / `gap_detected` | deterministic |
| **Cost estimate** | labeled token→USD list-price estimate (honest "not recorded" without token rows) | deterministic |
| **Detectors** | tool usage, task ledger, agents/skills, rework, error results, validation runs | deterministic |
| **Interpreted report** | an *optional* self-improvement/LLM-judge layer, kept **separate** from the deterministic file | non-deterministic by nature — never in the deterministic report |
| **Direct query** | `bar query` — read-only DB access (3 use cases + raw SELECT) for slices the report doesn't pre-bake | deterministic (named queries are explicitly ordered) |

Rule: nothing optional is allowed to leak non-determinism into the deterministic report. The
interpreted layer is a distinct artifact you request explicitly.

## Interpreted report (LLM-written, two audiences)
`bar interpret <db> --audience engineering|executive` emits a **deterministic brief** (the exact
facts + tone/coverage guidance). Hand the brief to your Claude Code session (or any LLM) and it
writes the interpreted report — technical for **engineering**, value/cost/risk for **executive**.
The brief is byte-identical (BAR owns the facts); the prose varies (the LLM owns the wording). BAR
never invents numbers — the brief pins them.

## Direct query (read-only, `bar query`)
When you want a slice the report doesn't pre-bake, go straight to the DB:
```bash
bar query <db> --list                       # the 3 named use cases + how format/limit work
bar query <db> tools --format csv           # tool-usage breakdown (also: timeline, errors)
bar query <db> --sql "SELECT role, count(*) FROM transcript_turns GROUP BY role"
```
The connection is opened `SQLITE_OPEN_READ_ONLY`, so a write in `--sql` is refused by SQLite
itself — not a regex we could get wrong. `--format table|json|csv` (table for humans, json/csv for
agents/pipes); `--limit N` windows the output (`--limit 0` = all). Named queries are explicitly
ordered, so a fixed DB renders identically every time.
