---
name: bar-report
description: Generate the deterministic BAR Observatory report (JSON + HTML + Markdown) for a session
---
$ARGUMENTS

Generate BAR Observatory's deterministic engineering report — no LLM in the render path, same
database in, byte-identical output out.

1. If `$ARGUMENTS` names a database path, use it. Otherwise default to `.bar/ambient.sqlite`
   relative to the current project (the path `bar init --dir .` creates); if that file doesn't
   exist, tell the user to run `bar init --dir .` then `bar ingest .bar/ambient.sqlite
   <session>.jsonl` first, and stop.
2. Run: `bar report <db> --out .`
3. Report the three output paths it wrote (`*.report.json`, `*.report.html`, `*.report.md`) and
   tell the user to open the `.html` file for the human view.
4. If the command fails, run `bar doctor <db>` and surface what it reports before guessing at
   the cause — a missing or corrupt store is the most common reason `bar report` fails.
