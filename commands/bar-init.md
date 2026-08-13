---
name: bar-init
description: Set up BAR Observatory for this project — local config + SQLite stores, idempotent
---
$ARGUMENTS

Set up BAR Observatory in the current project. This is the first command to run — everything
else (`/bar-report`, `/bar-interpret`, `/bar-doctor`, `/bar-query`, and the plugin's own hooks/MCP
server) reads and writes the `.bar/` directory this creates.

1. Determine the target directory from `$ARGUMENTS` (a path), defaulting to `.` (the current
   project root — the directory the `.bar` folder should live under so the plugin's hooks and
   `bar-mcp --db-root .bar` find it with zero extra configuration).
2. Run: `bar init --dir <dir>`
3. This is **idempotent** — safe to run again on an existing project, it never overwrites a
   config that's already there ("Kept" instead of "Created" on a second run). Report exactly what
   it did (created vs. kept) and where: `.bar/config.toml`, `.bar/ambient.sqlite`,
   `.bar/index.sqlite`.
4. If `bar` isn't found on PATH, tell the user to run `cargo install bar-observatory` first (and
   `cargo install bar-hook bar-mcp` too, for the plugin's hooks and MCP server to actually
   capture anything — see this repo's README for why those resolve via PATH today).
5. Once init succeeds, tell the user their next step: run a real Claude Code task/session (the
   plugin's hooks capture it automatically from here on), then `/bar-report` to see it.
