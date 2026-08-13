---
name: bar-query
description: Direct read-only query against a BAR Observatory capture database (tools, timeline, errors, or raw SQL)
---
$ARGUMENTS

Answer a specific question about a session that the pre-built report doesn't cover, using BAR
Observatory's direct read-only query surface.

1. Determine the database path, defaulting to `.bar/ambient.sqlite`.
2. Parse `$ARGUMENTS` for intent:
   - "what tools" / "tool usage" → `bar query <db> tools`
   - "timeline" / "what happened" / "in order" → `bar query <db> timeline`
   - "errors" / "what failed" / "silent failures" → `bar query <db> errors`
   - anything else that needs a specific slice → `bar query <db> --sql "SELECT ..."` (the
     connection is opened read-only; a write statement is refused by SQLite itself, not a filter
     you need to enforce yourself)
3. Add `--format json` if the result is for you to parse, `--format table` if it's for the user
   to read directly. `--limit N` windows the output (`--limit 0` = all rows).
4. Run `bar query <db> --list` first if you're unsure what's available.
