# 03 — Data ingestion

## Always done (no API key, no network)
- **Transcript ingest** — `bar ingest <db> <transcript.jsonl>` parses a real Claude Code session
  transcript into the store. This is the primary, always-available path: the transcript is already
  on disk, so ingestion makes **no API calls**.

```bash
bar ingest .bar/ambient.sqlite ~/.claude/projects/<project>/<session>.jsonl
```

## Optional (opt-in capture)
- **Proxy capture** — route `ANTHROPIC_BASE_URL` through the capture proxy to record real
  request/response bodies (adds the token/cost channel).
- **OTLP** — a native span/metrics receiver for live latency/span data.
- **Hooks** — Claude Code lifecycle hooks spool events into the store.

The report states honestly which channels were present; a channel that was not captured is rendered
`not_observed`, never as a fabricated zero.
