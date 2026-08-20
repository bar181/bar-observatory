# Step 5 — Sample report: see BAR Observatory's output for real

You don't have to take any of the previous steps on faith. `examples/` ships four reports over one
capture, and **the capture ships with them** — so you can run the tool over the same seven
transcripts and get the same numbers back on your own machine.

- `examples/deterministic/session.report.{json,html,md}` — literally what `bar report` writes.
  Nothing is added by hand.
- `examples/deterministic/delivery-memo.{html,md}` — the same record cut for an executive reader.
- `examples/interpreted/*.{html,md}` — the optional commentary layer, with the exact brief each page
  was written from shipped beside it.
- `examples/capture/` — the seven session transcripts, plus `run.sh`. One script — `bar init`, seven
  `bar ingest` calls, one `bar report` — rebuilds every deterministic file above.

The capture covers 7 sessions, 9,132 transcript turns, 3,171 tool calls, 40 of 40 tasks completed
and 60 error results, over a recorded window of 322h 59m. **The project it describes — `orbit` — is a stand-in.** Every count, rate and ranking is
measured from the shipped transcripts by the real tool; the paths, commit subjects and prompt titles
belong to a demo project rather than to somebody's private repository. `examples/README.md` says
which is which, and `examples/capture/README.md` shows you how to check.

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
