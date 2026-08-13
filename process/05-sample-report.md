# Step 5 — Sample report: see BAR Observatory's output for real

You don't have to take any of the previous steps on faith — a real, deterministic sample report
ships right in this repo under `examples/`, and it's **re-rendered from a real Claude Code
session each phase**. It's never a hand-authored mock.

- `examples/deterministic/real-session.report.{json,html,md}` — rendered from a real,
  multi-thousand-turn Claude Code transcript (no API calls involved). It shows real tool usage, a
  real task ledger, sub-agent dispatches, rework hotspots, validation runs, and an honest "cost
  not recorded" wherever the token channel wasn't captured.
- `examples/deterministic/dogfood-session.report.*` — the same renderer run over a seeded
  fixture, useful as a quick shape demo.
- `examples/interpreted/*` — an example of the optional interpreted layer from
  [04 — Optional modules](04-optional-modules.md).

## Which file should you open?

- **`.html`** — the human view. Open this one first; it's what most people mean by "the report."
- **`.md`** — a terminal- and diff-friendly view, handy if you want to `git diff` two reports or
  read one over SSH.
- **`.json`** — the machine contract, validated against `schemas/report.schema.json`. This is
  what you'd feed to another tool, dashboard, or an AI agent reading the report programmatically.

All three are rendered from the exact same database, so they always agree with each other —
same DB in, byte-identical report out, across all three formats, every time.

Next: [06 — Use cases](06-use-cases.md) for concrete examples of what this report — and BAR
Observatory's other commands — can answer about a real agent session.
