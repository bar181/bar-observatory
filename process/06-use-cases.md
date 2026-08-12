# 06 — Use cases & evidence

Real proof points, captured from **actual Claude Code sessions** by BAR Observatory — not mockups.
Every figure below is reproducible from a captured session DB with `bar query` / `bar report`.

## Use case 1 — "What silently failed in my session?"
An agent session runs dozens of tools; failures scroll past and are forgotten. BAR Observatory
captures every tool result and surfaces the errors on demand:

```
$ bar query <session>.sqlite errors
seq   tool  excerpt
----  ----  -----------------------------------------------------------------
308         MCP server "…ruvnet-brain…" tool "search_ruvnet" timed out after 60s
316         search_ruvnet error: brain worker timed out after 240s on tools/call
389         MCP server "…ruvnet-brain…" tool "search_ruvnet" timed out after 60s
436         Exit code 143 … (a killed long-running command)
1391        <tool_use_error> Blocked: sleep 90 … (a guardrail refusal)
```

**31 error results** were captured across this one real session — MCP timeouts, a killed command,
guardrail refusals — each with the exact seq and text, queryable months later. Nothing was
swallowed.

## Use case 2 — "Which tools did this session lean on, and what did it cost?"
```
$ bar query <session>.sqlite tools      # Bash 600+, Edit 290+, Read 90+, …
$ bar report <session>.sqlite           # deterministic json/html/md: tasks, rework, cost-equiv
```
Same DB → byte-identical report. A shareable receipt of an agent run, no LLM in the render path.

## Use case 3 — "Prove the recorder itself is healthy"
```
$ bar doctor <session>.sqlite           # live: is capture wired? what landed? what's a blind spot?
```

## The honest edge (what it does NOT see)
A real finding from building this doc: some tool results **failed to reach the model's context**
("internal error") yet were **recorded correctly server-side** (`is_error:false`, full output).
BAR Observatory reads the session transcript — server-side truth — so a *model-side delivery*
failure is invisible to it. We surface this rather than hide it: the instrument measures what the
session recorded, not what the model received. (Candidate future detector; disclosed, not swallowed.)

*All numbers above are from a real captured session; reproduce with the `bar query`/`report`/`doctor`
commands on any session DB you capture.*
