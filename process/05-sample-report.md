# 05 — Sample report (updated each phase)

A real, deterministic sample report ships under `examples/` and is **re-rendered from a real session
each phase** — it is never a hand-authored mock.

- `examples/deterministic/real-session.report.{json,html,md}` — rendered from a real multi-thousand-turn
  Claude Code transcript (no API calls). Shows real tool usage, task ledger, sub-agent dispatches,
  rework hotspots, validation runs, and an honest "cost not recorded" where the token channel is absent.
- `examples/deterministic/dogfood-session.report.*` — renderer output over a seeded fixture (shape demo).
- `examples/interpreted/*` — the optional interpreted layer (example-stage).

Read the HTML for the human view, the MD for a terminal/diff view, the JSON as the machine contract
(validates against `schemas/report.schema.json`). Same DB → byte-identical across all three.
