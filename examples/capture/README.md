# The capture these examples are rendered from

Seven session transcripts for **`orbit`**, a stand-in project. Every figure in every report under
`examples/` is measured from these files by the real tool — nothing in the reports is typed in by
hand, and nothing is copied from a private repository.

## Reproduce every number yourself

```sh
bar init --dir .
for f in examples/capture/*.jsonl; do
  bar ingest .bar/ambient.sqlite "$f" --run-uuid "session-$(basename "$f" .jsonl)"
done
bar report .bar/ambient.sqlite --out out/
```

`out/ambient.report.json` will match [`../deterministic/session.report.json`](../deterministic/session.report.json)
field for field — every count, every ranking, every status — and `out/ambient.report.html` will be
the same page as [`../deterministic/session.report.html`](../deterministic/session.report.html).

Exactly two fields will differ, and should: `integrity.source_db_hash` and the `report.id` derived
from it hash **the SQLite file**, and two separate ingests of the same transcripts do not produce a
byte-identical database. Everything else matches, `report.generated_at` included — it is taken from
the last activity the store recorded, not from the wall clock, which is what lets a report rendered
next year still say the same thing. That is what "deterministic" means here: the same store always
renders the same report, and the same transcripts always measure the same way.

`run.sh` in this folder does exactly the above.

## What is real about a stand-in capture

| Real | Stood in |
|---|---|
| Every count, rate and ranking in the reports — they are measured from these files by `bar report`, not asserted | The project itself: `orbit`, its paths, its commit subjects, its prompt titles |
| The failure text shapes: a blocked `rm -rf`, a not-installed plugin agent, a stale path after a docs move, a CI line caught mid-command | The specific repository those failures happened in |
| The distribution: one file taking 77 of 482 repeat edits, 3 tests changing verdict, 60 errors across 6 root-cause classes | — |
| The gaps: 629 dangling parents, 136 unpaired tool calls, and eight of nine channels holding no rows — six `not_recorded`, two `not_observed` | — |

The shape of this capture is modelled on a real two-week run so that the examples stay
representative of what the tool actually sees. The identifiers are not, so that a public example
never exposes a private repository. Both halves of that sentence are the point.

## Files

| File | Records | What it is |
|---|---:|---|
| `2026-05-04.jsonl` | 1,518 | 12 instructions — the biggest single session |
| `2026-05-07.jsonl` | 1,700 | 14 instructions |
| `2026-05-13.jsonl` | 778 | 4 instructions |
| `2026-05-14.jsonl` | 869 | 5 instructions |
| `2026-05-16a.jsonl` | 1,884 | 16 instructions |
| `2026-05-16b.jsonl` | 1,330 | 10 instructions — same day, second sitting |
| `2026-05-17.jsonl` | 1,053 | 7 instructions |

9,132 records in total: 68 human instructions, 3,171 tool calls and their results, and the model's
own prose in between. The format is the ordinary Claude Code transcript JSONL — one JSON object per
line, `user` / `assistant` records carrying content blocks.
