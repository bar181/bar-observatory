# Step 5 — Sample report: see BAR Observatory's output for real

You don't have to take any of the previous steps on faith — a real, deterministic sample report
ships right in this repo under `examples/`, and it's **re-rendered from a real Claude Code
session each phase**. It's never a hand-authored mock.

- `examples/deterministic/real-session.report.{json,html,md}` — rendered from a real,
  multi-thousand-turn Claude Code transcript (no API calls involved). It shows real tool usage, a
  real task ledger, sub-agent dispatches, rework hotspots, validation runs, and an honest "cost
  not recorded" wherever the token channel wasn't captured. One example, kept deliberately —
  see [`examples/README.md`](../examples/README.md) for why there's only one.
- `examples/interpreted/*` — the optional interpreted layer from
  [04 — Optional modules](04-optional-modules.md), one example per audience (executive,
  engineering).

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
