# How BAR Observatory compares

BAR Observatory answers **"what happened in this run, and can I prove it?"** Most of the tools
people reach for in this space answer a different question — **"what is happening right now,
across my fleet?"** Those are different jobs. The tools compose; BAR Observatory isn't trying to
replace them.

| Dimension | **BAR Observatory** | **Live dashboards** | **OTel backends**<br/>(SigNoz, OpenObserve, Dash0) | **LLM eval platforms**<br/>(Langfuse, Phoenix, Arthur, AgentOps) | **Raw `.jsonl` + `jq`** |
| --- | --- | --- | --- | --- | --- |
| **What it is** | Post-hoc audit report / receipt | Real-time event stream UI | Trace & metric backend | Trace + evaluation platform | Your own scripts |
| **Where data lives** | Local SQLite, one file per run | Local, live-streamed | Collector → server / SaaS | Self-hosted or SaaS service | Local files |
| **Needs a server or daemon** | No | Yes | Yes | Yes | No |
| **Works on sessions already finished** | **Yes** — parses transcripts on disk | No — must be running | No — must be exporting | No — must be exporting | Yes |
| **Reproducible artifact** | **Byte-identical, every time** | Ephemeral view | Query-time view | Query-time view | Whatever you wrote |
| **Absence handled honestly** | **`not_observed`, never a fake zero** | Varies | Typically gaps or zeros | Varies | Up to you |
| **Readable by your AI agent** | **Yes — MCP, 12 read-only tools** | Rarely | Via backend API | Via API | Via shell |
| **Setup cost** | A few commands, no server to run | Install + run server | Collector + backend config | Account + SDK wiring | Hours of your time |
| **Best for** | Audit, review, PR evidence, retros, compliance | Watching a run unfold | Fleet-scale metrics across many runs | Model/prompt evaluation | One-off spelunking |

*Reflects the general design posture of each category, not an audited feature list of any
specific product — individual tools evolve; check their own docs for specifics.*

## Why choose BAR Observatory

1. **Deterministic, not vibes-based.** The render path is a pure function of the database.
   Re-run it a year from now and get the identical bytes.
2. **Honest about gaps.** An uncaptured channel is reported as `not_observed`, never a fabricated
   zero. If BAR Observatory doesn't know, it says so.
3. **Retroactive.** Every other tool on this page requires you to have already been recording.
   BAR Observatory works on the transcript already sitting on your disk.
4. **Local-only by construction, not by promise.** Zero egress on the primary path, verifiable
   from the source (MIT licensed). No API key, no account, no telemetry about your telemetry.
5. **Built for agents as first-class readers.** The MCP surface means your agent can audit its
   own last session without you copy-pasting anything.

## What it isn't

**Not a replacement for:** fleet-scale dashboards, prompt/model evaluation, or live monitoring.
If you already run a dashboard or an OTel backend, BAR Observatory sits *beside* either one as
the per-run evidence layer — it answers the question those tools were never built to answer:
*"prove it, after the fact, without having been watching at the time."*

---

[← Back to the README](../../README.md) · [Architecture](architecture.md) · [Enterprise & offline use](enterprise.md)
