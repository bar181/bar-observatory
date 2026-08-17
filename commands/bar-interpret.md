---
name: bar-interpret
description: Generate BAR Observatory's optional self-improvement report (engineering or executive audience)
---
$ARGUMENTS

Generate the optional, LLM-written self-improvement report — a narrative writeup layered on top
of the deterministic facts, never mutating them.

1. Determine the audience from `$ARGUMENTS`: `engineering` (technical depth) or `executive`
   (cost/risk/value framing). `--audience` is required by the CLI — there is no default; ask the
   user which one they want if `$ARGUMENTS` doesn't say.
2. Determine the database path the same way as `/bar-report` (default `.bar/ambient.sqlite`,
   confirm it exists first).
3. Run: `bar interpret <db> --audience <engineering|executive>`
4. This does NOT call an LLM itself — it writes a deterministic **brief** (the exact facts plus
   audience-specific guidance) to a file. Read that brief file yourself, then write the actual
   self-improvement report from it: what should this agent/session do differently next time,
   grounded only in facts the brief cites — never invent a number that isn't in the brief.
5. Present the report to the user, clearly labeled as AI-generated interpretation, distinct from
   the deterministic report `/bar-report` produces.
