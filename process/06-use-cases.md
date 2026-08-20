# Step 6 — Use cases: what you can actually answer

Every figure and every line of output below was produced by the tool, from the capture shipped
in [`examples/capture/`](../examples/capture/) — nothing here is a mock-up written to look
convincing. You can reproduce all of it: `sh examples/capture/run.sh` builds the same database,
and then the `bar query` and `bar report` commands below return exactly what you see.

One thing to be clear about up front, because the reports read as if you were looking over
someone's shoulder: **the project in the capture, `orbit`, is a stand-in.** The measurements are
real — the counts, rates and rankings are the tool's own output over those transcripts. The
identifiers are not: the paths, commit subjects, prompt titles and sub-agent names belong to a
demo project rather than to anyone's private repository. Point the same commands at a session of
your own and the shape of the answers is identical; only the names change.

## "What silently failed in my session?"

An agent session runs dozens of tools over its lifetime; failures scroll past in the transcript
and are easy to forget by the time you're debugging something else. BAR Observatory captures
every tool result and lets you surface the errors on demand:

```
$ bar query .bar/ambient.sqlite errors --limit 0
seq   tool  excerpt
----  ----  ------------------------------------------------------------------------------
133         Permission to run `rm -rf /work/orbit/target/debug` was denied by policy: destr…
489         Permission denied: a search for TOKEN across the workspace is blocked by the cr…
690         Agent type 'requirements-validator' not found. Available: general-purpose, revi…
453         String to replace not found in file. `orbit/README.md` was read 240 turns ago a…
186         cd: /work/orbit/docs/legacy-guide/index.md: No such file or directory (moved du…
1104        SyntaxError: Unexpected token '<' in JSON at position 0 (tools/summarise.mjs)
…
(60 row(s))
```

**60 error results** across a seven-session window — guardrail refusals, a blocked credential
scan, a sub-agent that was never installed, an edit against a file that had moved on, stale paths
after a docs reorganisation, a throwaway script parsing HTML as JSON. Each one keeps its exact
sequence number and text, still queryable months later. Nothing was swallowed.

Not all sixty are defects, and the report does not pretend otherwise. Seventeen are guardrail
refusals — the safety system working exactly as designed — and ten more are detector artefacts,
things like `grep` exiting 1 because a search found nothing. That leaves roughly half the list as
work actually worth doing.
[`examples/interpreted/diagnostic-review.html`](../examples/interpreted/diagnostic-review.html)
sorts all sixty into six root-cause families and says which is which.

## "Which tools did this session lean on, and what did it cost?"

```
$ bar query .bar/ambient.sqlite tools   # Bash 1,706 · Edit 496 · Read 410 · TaskUpdate 209 · …
$ bar report .bar/ambient.sqlite        # deterministic json/html/md: tasks, rework, cost-equiv
```

Seventeen distinct tools, 3,171 calls, in one table — and the tail is kept rather than folded
into an "other" bucket, because a tool called once is still a fact about how the work was done.

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

*Every number above is the tool's own output over `examples/capture/` — reproduce it with
`sh examples/capture/run.sh`, then run the same `bar query` / `bar report` / `bar doctor`
commands against any session database you capture yourself.*
