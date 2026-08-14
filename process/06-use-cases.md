# Step 6 — Use cases: what you can actually answer

Here are real proof points, captured from **actual Claude Code sessions** by BAR Observatory —
not mockups. Every figure below is reproducible from a captured session database with `bar
query` or `bar report`; run the same commands against your own session and you'll get your own
numbers.

## "What silently failed in my session?"

An agent session runs dozens of tools over its lifetime; failures scroll past in the transcript
and are easy to forget by the time you're debugging something else. BAR Observatory captures
every tool result and lets you surface the errors on demand:

```
$ bar query <db> errors --limit 0
seq   tool  excerpt
----  ----  -----------------------------------------------------------------
150         Permission to use Bash with command rm -rf … has been denied. (a guardrail refusal)
438         Agent type 'qe-requirements-validator' not found. Available agents: …
603         Exit code 143 Command timed out after 2m 0s … (a killed long-running command)
1490        <tool_use_error> Found 2 matches of the string to replace, but replace_all is false.
```

**60 error results** turned up across a real 7-session window — guardrail refusals, a missing
sub-agent, a killed command, ambiguous edits — each one with its exact seq and text, still
queryable months later. Nothing was swallowed. (Guardrail refusals like the first one above are
the safety system working as intended, not a defect — see
[`examples/interpreted/interpreted-engineering.html`](../examples/interpreted/interpreted-engineering.html)
for the root-cause breakdown.)

## "Which tools did this session lean on, and what did it cost?"

```
$ bar query <db> tools                  # Bash 1,700+, Edit 490+, Read 410+, …
$ bar report <db>                       # deterministic json/html/md: tasks, rework, cost-equiv
```

Same database in, byte-identical report out — a shareable receipt of an agent run, with no LLM
anywhere in the render path. It's a full AI agent session report you can hand to a teammate,
attach to a PR, or archive, and trust it'll look the same when someone opens it later.

## "Prove the recorder itself is healthy"

```
$ bar doctor <session>.sqlite           # live: is capture wired? what landed? what's a blind spot?
```

Before you trust a report, check whether the thing that produced it was actually working —
`bar doctor` says plainly which channels had data and which didn't.

## The honest edge: what BAR Observatory does *not* see

A real finding from building this documentation: some tool results **failed to reach the
model's context** ("internal error") yet were **recorded correctly server-side**
(`is_error:false`, full output). BAR Observatory reads the session transcript — server-side
truth — so a *model-side delivery* failure is invisible to it. We'd rather tell you that plainly
than hide it: the instrument measures what the session recorded, not what the model received.
(Candidate for a future detector — disclosed now, not swallowed.)

## Let your AI agent pull these facts itself

Everything above was run by hand from a terminal. If you'd rather have your AI agent answer its
own "what actually happened in that session?" question, point it at
**[`bar-mcp`](https://crates.io/crates/bar-mcp)** instead — the same read-only queries (`tools`,
`timeline`, `errors`, and more) are exposed as MCP (Model Context Protocol — the standard
interface AI agents use to call external tools) tools an agent can call directly, no shelling
out to the CLI:

```bash
claude mcp add bar-observatory -- bar-mcp --db-root .bar
```

See the [README](../README.md) for both front doors — the `bar` CLI for you, `bar-mcp` for your
agent.

*All numbers above are from a real captured session; reproduce them yourself with the `bar
query`/`report`/`doctor` commands on any session database you capture.*
