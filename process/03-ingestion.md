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
people will use every time: no proxy to configure, no collector to run, just a `.jsonl` file you
already have.

## Optional: opt-in capture channels

If you want more than what's in the transcript, three capture modules add richer channels —
each one is opt-in, and none of them is required for a report:

- **Proxy capture** — route `ANTHROPIC_BASE_URL` through the capture proxy to record real
  request/response bodies, which adds the token/cost channel to your report.
- **OTLP** — a native span/metrics receiver for live latency and span data.
- **Hooks** — Claude Code lifecycle hooks that spool events straight into the store as they
  happen.

## Honest about what's missing

Whichever channels you do or don't enable, the report tells you the truth about it: a channel
that wasn't captured renders as `not_observed`, never as a fabricated `0`. You'll always be able
to tell the difference between "this session made zero tool calls" and "BAR wasn't watching that
channel" — that distinction is the whole point of an honest AI agent session report.

Next: [04 — Optional modules](04-optional-modules.md) for what these capture channels unlock in
the report, or skip ahead to [05 — Sample report](05-sample-report.md) to see one rendered.
