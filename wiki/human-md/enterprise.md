# Enterprise, regulated, and air-gapped use

BAR Observatory's primary capture path — parsing a Claude Code transcript already on disk — makes
**zero network calls**. That single fact is the whole story for most of what follows.

## Works on a machine with the network cable pulled out

Capture, storage, and reporting all function fully offline:

- **Capture**: transcript parsing reads a file already on your disk. No API calls, no outbound
  connection.
- **Storage**: one local SQLite file per run. Nothing is synced, uploaded, or phoned home.
- **Reporting**: the render path is a pure function of that local database — no model, no network
  dependency.

The one exception, by design and clearly bounded: `bar interpret` is optional, calls your own
Claude Code session to write a plain-English narrative, and is switched off unless you run it.
The deterministic report never depends on it and never calls a model itself.

## Nothing added to your codebase

There's no SDK to import, no decorator to add, no dependency your security team has to review in
your application's own dependency tree. BAR Observatory watches the Claude Code session, not your
project — your repository is untouched, and stays untouched if you uninstall.

## What data actually gets stored

"Local-only" tells you *where* the data goes. It doesn't tell you *how much* of it there is — and
a security review needs both. Stated plainly, from the actual capture schema, not the marketing
summary:

- **Full conversation content.** Not just counts — the actual message text, and the agent's
  internal `thinking`/reasoning blocks, are stored per transcript turn. A rendered report only
  *surfaces* aggregates (task counts, tool tallies, short error excerpts); the underlying
  database holds the real content, and it's queryable directly (`bar query --sql`, or an agent's
  own `search_observations` MCP call).
- **File content.** When available, BAR recovers actual per-edit file snapshots from Claude
  Code's own local file-history mechanism — not just "this file was touched," but the content
  itself, content-addressed by hash.
- **Tool inputs and outputs**, hook payloads, and (only if you run the optional capture proxy)
  full LLM request/response bodies.
- **Environment fingerprint** — but not raw secrets: environment variable *names* plus a hash of
  each value, never the value itself.
- **Raw process logs** — the harness debug log, stderr, and stdout, line by line, unfiltered.

**What's redacted automatically, on write, before any of the above lands in the database:**
secret-shaped API keys (a small set of known vendor prefixes). That's it at write time — a
narrow, specific list, not a general PII or secrets scanner.

**Everything else — including email-shaped tokens and home-directory paths — is a render/export-time
decision, not a write-time one**, controlled by `[redact]` in `.bar/config.toml`
(`mode = "off" | "export" | "strict"`, `paths = "verbatim" | "home-relative" | "mask-foreign"`).
The default is `mode = "off"`: out of the box, both the stored database *and* the rendered report
show paths and emails verbatim. Set `mode = "export"` to redact the export/publish-safe copy only,
or `"strict"` to redact rendered reports too. If your policy requires paths/emails masked by
default, set this explicitly — it is not the shipped default.

The practical takeaway: treat a capture database the way you'd treat the session transcript
itself, because it substantively *is* that transcript, restructured for querying — not a
metadata-only summary of it. Full anonymization is a separate, deliberate step (next section),
not something that happens by default at capture time, and applies to storage; the `[redact]`
config above governs what a *rendered report* shows, which is a separate surface.

## Sharing a capture database without sharing everything in it

A capture database can contain freeform text from a real working session — file contents,
command output, error text. When you need to hand a database to someone else (a teammate, a
support request, a public bug report), `bar-sanitize` scrubs PII from a capture DB into a
publish-safe copy, so what you share is under your control rather than "the whole database, as
captured."

## What this doesn't claim

- **Not a compliance certification.** Reports are reproducible and byte-identical, not
  cryptographically signed per run. If you have a specific evidentiary or compliance requirement,
  check it against what you actually need — this page describes engineering properties, not a
  legal opinion.
- **`bar interpret` is the one networked feature**, and it's opt-in and clearly labeled wherever
  it appears in a report. If your policy requires zero model calls of any kind, simply don't run
  it — everything else in the pipeline still works.

---

[← Back to the README](../../README.md) · [Comparison](comparison.md) · [Architecture](architecture.md)
