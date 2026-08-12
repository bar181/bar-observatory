# Deterministic report examples

Two different kinds of file live here — don't confuse them:

| File(s) | Origin | Data |
|---|---|---|
| `real-session.report.{json,html,md}` | **Real Rust renderer over REAL data** | Rendered from **this build session's actual Claude-Code transcript** (re-rendered from this build session's real transcript each phase; see the report itself for current counts). Shows real tool usage, a real task ledger, real rework hotspots, a categorized Failures section (with MCP remediation), validation evidence, and honest "not recorded" for uncaptured channels. This is the answer to the "row counter" critique. |
| `dogfood-session.report.{json,html,md}` | **Real Rust renderer output** (`bar-observatory::report`, Phase 5) | Rendered from a **synthetic fixture store** — a real `bar-store` SQLite DB seeded with fixed, illustrative rows by `crates/bar-observatory/examples/dogfood.rs`. **NOT a live Claude-Code capture.** It exists to show the renderer's real output shape + honest-absent states; the numbers are seeded, not measured from a live session. |
| `example.report.json`, `bar_observatory_engineering_report.html` | **Hand-authored design mocks** (`"example": true`) | Fictional data illustrating the *full* report vision (all detectors populated). These are targets, not generated output. |

A report rendered from a **live-captured** session (proxy + hooks against a real `claude` run)
is the seal criterion for the Phase 2–5 block and does not exist yet — see `../../CAPTURE-RUNBOOK.md`
for the steps and the honest account of what's still env-blocked. When it lands it will be added
here and labeled as live.

As of **P6** the fixture demonstrates the **measured coverage oracle** (the hooks channel shows
`verified` because its lifecycle is bracketed + every tool call paired) and the **Harvard Crimson
`#A51C30`** palette. The oracle is real code (tested); the *data* it measures here is still the
labeled fixture until live capture is wired locally.

Determinism note: the `dogfood-session` fixture DB embeds a wall-clock migration timestamp, so
regenerating it produces different bytes (a different input). The product contract is that
rendering **one fixed DB** is byte-identical — see `LEARNING-LOG.md` L9.
