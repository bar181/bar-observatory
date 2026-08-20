# Architecture

BAR Observatory is a thin `bar` CLI (crate `bar-observatory`) over a 16-crate `bar-*` engine.
Crate source lives and publishes from a private working repository; this public repository is
the front door — documentation, plugin assets, schemas, and contracts, no crate source, by
design. Full crate list with live crates.io links: [CRATES.md](../../CRATES.md).

## The crates

| Crate | Tier | Role |
| --- | --- | --- |
| `bar-store` | L0 | SQLite schema and substrate trait. Depends on nothing internal. |
| `bar-root-resolve` | L0 | Shared, provenance-visible DB-root and workspace-root resolution. Depends on nothing internal. |
| `bar-index` | L0.5 | The second kernel: cross-run catalog and artifact store. |
| `bar-hook` | L1 | Hook binary, reads JSON on stdin. |
| `bar-ingest` | L1 | Transcript JSONL parser — the always-on capture path. |
| `bar-otlp` | L1 | Native OTLP receiver (tonic gRPC plus hand-rolled HTTP/1.1). |
| `bar-proxy` | L1 | `ANTHROPIC_BASE_URL` interceptor (axum/hyper). |
| `bar-read` | L1 | Read-only query surface: named queries plus guarded raw SELECT. |
| `bar-metrics` | L2 | T/R/L/Δ/E ledger and the Δ subsystem. |
| `bar-review` | L2 | Reflection engine: detectors, review orchestration, recommendations. |
| `bar-mcp` | L3 | Read-only stdio MCP server over per-run capture databases. |
| `bar-schema` | — | The `report.json` typed contract: ReportDocument, AbsenceState, fact_id assignment. |
| `bar-obs-config` | — | Layered TOML config resolution. |
| `bar-registry` | — | The Hub's registry: capability collection plus a byte-deterministic canonical-JSON emitter. Zero dependencies by design. |
| `bar-root-resolve` | — | Shared, provenance-visible workspace / db-root resolution. |
| `bar-sanitize` | — | Publication sanitizer: scrub PII from a capture DB into a publish-safe copy. |
| `bar-observatory` | facade | The `bar` CLI: init, ingest, report, query, doctor, interpret. |

Sixteen of the seventeen crates publish to crates.io; `bar-testenv` is internal/dev-only and
stays unpublished. Crates publish incrementally in dependency-tier order — a link in `CRATES.md`
means cleared for publish, not necessarily live. That table is generated from the crate manifests
themselves, counts included, so it cannot quietly disagree with the crate set. `bar-engine`, an older internal-only CLI that predates the public
`bar-observatory` facade, is deliberately not ported — see [CRATES.md](../../CRATES.md) for the
disclosed rationale.

## The determinism contract

- **No model in the render path.** Report generation is a pure function of the capture database.
  Any interpreted output is a separate, optional command (`bar interpret`).
- **Byte-identical across formats.** JSON, HTML, and Markdown render in one pass from one
  database, so they cannot disagree.
- **One file, no fetches.** The HTML report inlines its own stylesheet and its own runtime. It
  requests no stylesheet, no script, no font and no image from anywhere — the same promise the tool
  makes about your session data, applied to the artifact it hands you. Charts are drawn in the
  browser from figures the page also states in prose and tables, so the report is complete with
  scripting switched off.
- **Typed contract.** `report.json` is structured, typed output. A versioned JSON Schema for it
  ships in [`schemas/`](../../schemas/), but it currently describes an earlier report shape and does
  not validate against live `bar report` output (confirmed against the shipped example with the
  actual JSON Schema validator) — a known gap, pending a schema regeneration in the private
  working repo, disclosed here rather than silently wrong.
- **Every claim resolves to a row — and the row has to be readable.** Facts carry identifiers back
  to the database that produced them. A tool output too large to store inline is kept in a
  content-addressed blob beside the database rather than in it. Two rules keep that from quietly
  costing you measurements:
  - **The size cap applies to the payload, not the block.** An oversized tool result keeps every
    field that identifies it — whether it errored, which call it answers — and loses only its body.
    It used to lose all of them, which meant a failure inside a large output was counted nowhere,
    and offloaded results looked like unpaired orphans, so the recorder reported a coverage gap it
    had created itself.
  - **Verdicts inside the body are read during *ingest*,** while the untruncated output is still in
    hand, and stored as typed rows. The answer therefore does not depend on a size threshold, on
    where a runner prints its summary line, or on whether the blob directory travelled with the
    database.

  Where a report is built from an older store that predates that extraction, the affected section
  says `partial` and names the count it could not read rather than presenting a confident total.
  In the rare case where a block was too large to keep even its identifying fields, the row itself
  records that, so a reader of the database learns it too — a count that exists only in the memory
  of the process that did the ingest is not a disclosure to anyone.
- **Integrity artifacts.** [`checksums/SHA256SUMS.txt`](../../checksums/SHA256SUMS.txt) and
  [`provenance/PROVENANCE.json`](../../provenance/PROVENANCE.json) ship with the repository.

## Absence semantics

The schema carries an explicit absence state, and it is finer-grained than a single "missing"
flag — because "we didn't look" and "we can't look yet" are not the same admission:

| State | What it means | Example from the shipped report |
|---|---|---|
| `observed` | the channel had rows, and they were used | `transcripts` — 9,132 turns |
| `partial` | rows landed, but a measured gap was detected | 629 dangling parents, 136 unpaired tool_use/tool_result |
| `not_recorded` | this channel had no rows in this store | `hooks`, `events`, `spans`, `requests` on a transcript-only ingest |
| `not_observed` | the writer or detector exists but nothing invoked it here | `plan_docs`, `raw_logs`, and the two unbuilt detectors |

None of the four is ever coerced to zero, empty, or unchanged. This is a design rule with teeth:
a cost figure of `$0.00` and a cost figure of `not_recorded` mean entirely different things, and
conflating them is how observability tools quietly lie. `bar doctor` exists to make the
distinction visible before you read a report, and the report's own capture-quality table repeats
it channel by channel with the reason attached.

## Capture channels

- **Transcript ingest** — always on, zero network calls, works retroactively. The primary path.
- **Lifecycle hooks** — 21 events, wired by the plugin. Unresolvable hook commands fail
  harmlessly and never block a session.
- **Proxy** — opt-in `ANTHROPIC_BASE_URL` interception for request-level detail.
- **OTLP receiver** — opt-in, native, for OpenTelemetry-emitting sources.

## Known limits, on the record

- **Two measurements still read only what is stored inline.** The task ledger's
  "created successfully" scan and the commit-output scan read the body of a tool result, so a large
  enough output is not visible to them. Both read output that is short by nature — a task
  acknowledgement, a `git commit` summary — so the exposure is small, but it is not zero and their
  counts are a floor. This is measured rather than assumed: the capture-quality table reports how
  many results were offloaded, so a reader is told when a denominator is incomplete.
- **Model-side delivery failures are invisible.** Results that failed to reach the model's
  context but were recorded correctly server-side do not appear. Disclosed as a candidate future
  detector, not swallowed.
- **Plugin binaries resolve via `PATH`.** No release pipeline assembles per-platform binaries
  into the plugin zip yet — a hook or MCP command Claude Code can't resolve fails harmlessly and
  never blocks a session, but it's not yet a bundled, zero-config install.
- **Uncaptured channels stay uncaptured.** Optional modules are off by default; the always-on
  path is transcript parsing only.
- **No git/commit binding yet.** Repository and branch binding is a planned future measurement,
  not implemented today — a report does not currently claim anything about commits.

## Documentation architecture

This project's documentation is written in three registers for three different readers — human
prose, structured agent-facing process docs, and AISP symbolic specs. See
[documentation-layers.html](../human-html/documentation-layers.html) for why, a tab switcher between the
three, and an honest account of which parts are generated versus hand-maintained today. For what a
generated *report* (as opposed to this documentation) actually contains, section by section:
[report-guide.html](../human-html/report-guide.html).

---

[← Back to the README](../../README.md) · [Comparison](comparison.md) · [Enterprise & offline use](enterprise.md)
