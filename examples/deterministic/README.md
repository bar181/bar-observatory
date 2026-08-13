# Deterministic report examples

Four files, three different origins — worth knowing which is which before you read one as a
preview of what your own report will look like.

| File(s) | Origin | What the data means |
|---|---|---|
| `real-session.report.{json,html,md}` | Rendered by the real `bar` CLI | A genuine capture database from an actual Claude Code session, run through `bar report` exactly as you'd run it yourself. Real tool usage, a real task ledger, real rework hotspots, a categorized failures section, validation evidence, and an honest `not_observed` for any channel that wasn't captured. This is the best preview of what your own report will look like. |
| `dogfood-session.report.{json,html,md}` | Rendered by the real `bar` CLI, over seeded data | The renderer is real, but the database underneath is a fixture seeded with fixed, illustrative rows rather than a live session. Useful for seeing the report's full shape — including its honest-absent states — without needing a real transcript on hand. |
| `example.report.json`, `bar_observatory_engineering_report.html` | Hand-authored mock | Fictional data illustrating every section of the report at once (all detectors populated). A target for what a fully-populated report looks like, not something `bar report` ever produced. |

## How to read them

Open any `.html` file for the human view, the `.md` for a terminal- or diff-friendly view, or the
`.json` for the machine contract (validates against
[`schemas/report.schema.json`](../../schemas/report.schema.json)). For a fixed database, all
three are byte-identical — that's the determinism guarantee: same input, same output, every time.

See **[wiki/human/README.md](../../wiki/human/README.md)** for a section-by-section guide to
reading a report, and **[examples/interpreted/](../interpreted/)** for the optional,
LLM-written self-improvement report that layers on top of these facts.
