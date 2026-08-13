# BAR Observatory — Human Quick-Start Wiki

You just ran a Claude Code session and you want to know what actually happened: which tools got
called, where the agent looped on itself, what failed silently, what it cost. BAR Observatory
turns the session transcript already sitting on your disk into a report that answers that — no
LLM re-reading your session, no API key, nothing leaving your machine.

This page is the human path: install the `bar` CLI, generate your first report, and learn how to
read it. If you're wiring an AI agent up to query BAR Observatory's databases directly instead,
see **[wiki/agent/AI-CONTEXT.md](../agent/AI-CONTEXT.md)**.

> **Using Claude Code?** Install [this repo's plugin](../../README.md#get-started--the-plugin-recommended-front-door)
> instead — it wires hooks + the MCP server for you and adds `/bar-init`, `/bar-report`,
> `/bar-interpret`, `/bar-doctor`, `/bar-query` slash commands, so every step below is one line
> inside your session instead of a terminal round-trip. The manual path below still works
> either way — the plugin's commands just run these same `bar` commands for you.

## 1. Install

```bash
cargo install bar-observatory
```
(Plugin equivalent: `/bar-init` after installing the plugin + `cargo install bar-hook bar-mcp
bar-observatory`.)

That gets you the `bar` binary. Crates publish incrementally — see
[CRATES.md](../../CRATES.md) for each crate's real, current crates.io status if `cargo install`
isn't live yet for you.

## 2. Generate your first report

```bash
bar init --dir .                                     # create local config + SQLite stores (idempotent)
bar ingest .bar/ambient.sqlite <your-session>.jsonl   # parse a real Claude Code transcript, no API calls
bar report .bar/ambient.sqlite --out .                # JSON + HTML + MD, deterministic
```
(Plugin equivalent: `/bar-init` once, then `/bar-report` any time you want a fresh one.)

`bar init` is safe to run more than once — it never overwrites a config that's already there.
`<your-session>.jsonl` is a Claude Code transcript file, typically under
`~/.claude/projects/<project>/<session>.jsonl`. Open the `.html` file BAR just wrote — that's
your report. Prefer one script that does all of this for you? See
**[RUN.md](../../RUN.md)** at the repo root.

## 3. Read the report

Reports are meant to be read top to bottom, in this order:

1. **Tasks and completion evidence** — what the agent was asked to do, and what proves it did it.
2. **Rework hotspots** — where the agent circled back and redid work, and how often.
3. **Agents and handoffs** — sub-agent dispatches, if any, and how work moved between them.
4. **Skills** — which skills/tools got exercised.
5. **Human-versus-AI recovery** — who caught and fixed a problem when one came up.
6. **Validation** — test/check runs the session performed.
7. **Micro-observations and silent signals** — smaller findings that don't fit the categories
   above, plus anything that happened quietly enough you'd otherwise miss it (see the errors
   example below).

Every field in the report is a fact pulled straight from the capture database — nothing is
guessed. A channel BAR didn't capture is reported as `not_observed`, never filled in with a
fabricated zero. That's the same report every time you re-render an unchanged database: byte for
byte identical, a year later, on a different machine.

A quick example of what "silent signals" catches — a real session, one command:

```
$ bar query <session>.sqlite errors
seq   tool  excerpt
----  ----  -----------------------------------------------------------------
308         MCP server "…ruvnet-brain…" tool "search_ruvnet" timed out after 60s
436         Exit code 143 … (a killed long-running command)
1391        <tool_use_error> Blocked: sleep 90 … (a guardrail refusal)
```

Errors that scrolled past in your terminal and would otherwise be forgotten, each with its exact
position in the transcript, queryable months later.

## 4. The optional self-improvement report

The report from step 2 is entirely deterministic — no LLM touches it. If you also want a
narrative writeup (what should this agent do differently next time?), that's a separate, opt-in
step:

```bash
bar interpret .bar/ambient.sqlite --audience engineering   # or: --audience executive
```
(Plugin equivalent: `/bar-interpret engineering` or `/bar-interpret executive`.)

This doesn't call an LLM itself. It writes a **deterministic brief** — the exact facts from your
report plus audience-specific tone guidance (technical depth for `engineering`, cost/risk/value
framing for `executive`). Hand that brief to a Claude Code session (or any LLM) and it writes the
self-improvement report from it. BAR owns every number in the brief; the LLM only owns the
prose — so the facts underneath never drift even though the writeup will read differently each
time you generate it.

## 5. Confirm the recorder is actually healthy

```bash
bar doctor .bar/ambient.sqlite
```
(Plugin equivalent: `/bar-doctor`.)

This is a live diagnostic, not part of the deterministic report — it answers "is capture working,
and what are its blind spots right now?" rather than "what happened in this session?" Run it any
time you're not sure the numbers you're seeing reflect everything that happened.

## What's next

- **[CRATES.md](../../CRATES.md)** — every crate BAR Observatory is built from, and its real
  crates.io publish status.
- **[process/](../../process/)** — a guided, step-by-step walkthrough of the whole pipeline: init,
  config, database creation, ingestion, optional modules, and a real sample report.
- **[examples/](../../examples/)** — real, current sample reports you can open without running
  anything yourself.
- Every report carries `report.schema_version`. Check it before trusting an older report on disk
  against a newer contract — a report generated under a prior schema version may be missing
  fields a current reader expects. That's the intended way to tell the two apart, not a bug.
