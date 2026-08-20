# Step 3 — Data ingestion: get a real Claude Code session into BAR

This is the step that turns a Claude Code agent session into data you can actually query and
report on.

## Always on: transcript ingest (no API key, no network)

The primary, always-available path is **transcript ingest**. You already have the session
transcript on disk — BAR just parses it:

```bash
bar ingest .bar/ambient.sqlite ~/.claude/projects/<project>/<session>.jsonl
```

Because the transcript is local, ingestion makes **zero API calls**. This is the path most
people will use every time: no proxy to configure, no collector to run, just a `.jsonl` file
(JSON Lines — a plain-text file with one JSON record per line) you already have.

## Optional: opt-in capture channels

If you want more than what's in the transcript, three capture modules add richer channels —
each one is opt-in, and none of them is required for a report:

- **Proxy capture** — point the `ANTHROPIC_BASE_URL` environment variable (the address Claude
  Code sends its API requests to) at the capture proxy to record real request/response bodies,
  which adds the token/cost channel to your report.
- **OTLP** (OpenTelemetry Protocol — an open standard for exporting traces and metrics) — a
  native receiver for live latency data and "spans" (timed records of individual operations).
- **Hooks** — Claude Code lifecycle hooks that spool events straight into the store as they
  happen.

## What ingest works out while it can

Ingest is mostly a verbatim recorder — a transcript block goes in and comes out unchanged. There
are two deliberate exceptions, and both exist for the same reason: a tool output above a size
threshold is stored in a content-addressed blob beside the database rather than inline.

**Only the body is set aside, never the labels.** A large tool result keeps every field that says
what it *is* — whether it errored, which call it answers — and loses only its text. That matters
more than it sounds: when the whole block was set aside, a failure buried in a long output was
counted nowhere at all, and the biggest outputs tend to be the interesting failures.

**Verdicts are read on the way past.** A full test run is exactly the output that gets set aside,
and several test runners print their verdict on the *last* line. So BAR reads test verdicts while
the whole output is still in hand and stores them as typed facts.

That is why a `bar report` over a database copied to another machine gives the same answer as it did
on the original: the verdict is inside the one file, not in a directory that may not have travelled
with it. If you have an older capture from before this existed, re-run `bar ingest` on the same
transcript; it is idempotent, and the report will tell you plainly when it is working from a store
that has not been re-ingested.

## Honest about what's missing

Whichever channels you do or don't enable, the report tells you the truth about it: a channel
that wasn't captured renders as `not_recorded` (and one whose writer was never invoked as
`not_observed`), never as a fabricated `0`. You'll always be able
to tell the difference between "this session made zero tool calls" and "BAR wasn't watching that
channel" — that distinction is the whole point of an honest AI agent session report.

Next: [04 — Optional modules](04-optional-modules.md) for what these capture channels unlock in
the report, or skip ahead to [05 — Sample report](05-sample-report.md) to see one rendered.
