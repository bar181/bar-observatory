# Architecture

BAR Observatory is a thin `bar` CLI (crate `bar-observatory`) over a 14-crate `bar-*` engine.
Crate source lives and publishes from a private working repository; this public repository is
the front door — documentation, plugin assets, schemas, and contracts, no crate source, by
design. Full crate list with live crates.io links: [CRATES.md](../../CRATES.md).

## The crates

| Crate | Tier | Role |
| --- | --- | --- |
| `bar-store` | L0 | SQLite schema and substrate trait. Depends on nothing internal. |
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
| `bar-sanitize` | — | Publication sanitizer: scrub PII from a capture DB into a publish-safe copy. |
| `bar-observatory` | facade | The `bar` CLI: init, ingest, report, query, doctor, interpret. |

Fifteen crates published to crates.io; `bar-testenv` is internal/dev-only and unpublished.
Crates publish incrementally in dependency-tier order — a link in `CRATES.md` means cleared for
publish, not necessarily live. `bar-engine`, an older internal-only CLI that predates the public
`bar-observatory` facade, is deliberately not ported — see [CRATES.md](../../CRATES.md) for the
disclosed rationale.

## The determinism contract

- **No model in the render path.** Report generation is a pure function of the capture database.
  Any interpreted output is a separate, optional command (`bar interpret`).
- **Byte-identical across formats.** JSON, HTML, and Markdown render in one pass from one
  database, so they cannot disagree.
- **Typed contract.** `report.json` is structured, typed output. A versioned JSON Schema for it
  ships in [`schemas/`](../../schemas/), but it currently describes an earlier report shape and does
  not validate against live `bar report` output (confirmed against a real captured session with
  the actual JSON Schema validator) — a known gap, pending a schema regeneration in the private
  working repo, disclosed here rather than silently wrong.
- **Every claim resolves to a row.** Facts carry identifiers back to the database that produced
  them.
- **Integrity artifacts.** [`checksums/SHA256SUMS.txt`](../../checksums/SHA256SUMS.txt) and
  [`provenance/PROVENANCE.json`](../../provenance/PROVENANCE.json) ship with the repository.

## Absence semantics

The schema carries an explicit absence state. A channel with no data renders as `not_observed`,
never coerced to zero, empty, or unchanged. This is a design rule with teeth: a cost figure of
`$0.00` and a cost figure of `not_observed` mean entirely different things, and conflating them is
how observability tools quietly lie. `bar doctor` exists to make the distinction visible before
you read a report.

## Capture channels

- **Transcript ingest** — always on, zero network calls, works retroactively. The primary path.
- **Lifecycle hooks** — 21 events, wired by the plugin. Unresolvable hook commands fail
  harmlessly and never block a session.
- **Proxy** — opt-in `ANTHROPIC_BASE_URL` interception for request-level detail.
- **OTLP receiver** — opt-in, native, for OpenTelemetry-emitting sources.

## Known limits, on the record

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
