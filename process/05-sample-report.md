# Step 5 — Sample report: see BAR Observatory's output for real

You don't have to take any of the previous steps on faith — a real, deterministic sample report
ships right in this repo under `examples/`, and it's **re-rendered from a real Claude Code
session each phase**. It's never a hand-authored mock.

- `examples/` — five report artifacts, all rendered from **the same 7-session real capture store**
  (2026-07-31 → 2026-08-13, 9,132 transcript turns, 40/40 tasks completed): two audiences (**Boss
  Mode** = executive/client, **Developer Guide** = engineering) × two registers (**Evidence** =
  deterministic/no LLM, **Commentary** = optional LLM synthesis), plus the shared
  `real-session.report.json` machine contract. See [`examples/README.md`](../examples/README.md)
  for the full table and what's disclosed as not-yet-CLI-native.

## Which file should you open?

- **`.html`** — the human view. Open this one first; it's what most people mean by "the report."
- **`.md`** — a terminal- and diff-friendly view, handy if you want to `git diff` two reports or
  read one over SSH.
- **`.json`** — the machine contract: structured, typed output for feeding another tool, dashboard,
  or an AI agent. A versioned schema for it ships at `schemas/report.schema.json`, but it currently
  describes an earlier report shape and doesn't validate against live output — disclosed, not
  silently wrong, pending a schema regeneration.

All three are rendered from the exact same database, so they always agree with each other —
same DB in, byte-identical report out, across all three formats, every time.

Next: [06 — Use cases](06-use-cases.md) for concrete examples of what this report — and BAR
Observatory's other commands — can answer about a real agent session.
