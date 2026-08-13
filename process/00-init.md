# Step 0 — Init: set up your local project

This is where every BAR Observatory session starts. `bar init` creates a small local
project — a config file and a couple of SQLite stores — so BAR has somewhere safe to keep
what it captures about your Claude Code agent sessions.

## Run it

From wherever you want your BAR project to live:

```bash
bar init --dir .
```
Using the Claude Code plugin? Run `/bar-init` instead — same command, one line inside your
session. It's also what wires the plugin's hooks and MCP server to find your data with zero
extra configuration, since they default to this same `.bar` directory.

You'll see BAR create:
- `.bar/config.toml` — your typed configuration, covered next in [01 — Config](01-config.md)
- local SQLite stores under `.bar/`, covered in [02 — Database creation](02-database-creation.md)

`bar init` is **idempotent**: run it again on the same directory and it will never overwrite a
config file that's already there — treat it as "make sure this is ready," not "reset this."

Everything happens on disk, under `--dir`. No network call, no API key, no account to create —
the same local-only design behind every BAR Observatory command.

## Check your setup: `bar doctor`

Once you've initialized a project — and ideally ingested a real session (see
[03 — Data ingestion](03-ingestion.md)) — ask BAR to check on itself:

```bash
bar doctor .bar/ambient.sqlite
```
(Plugin: `/bar-doctor`.)

`bar doctor` is a **live** health check, distinct from the deterministic report you'll generate
later. It confirms the `bar` binary is working, validates that your store is a real,
uncorrupted SQLite file, and reports honestly which capture channels actually have rows in
them — a missing channel renders `not_observed`, never a fabricated `0`, the same honesty rule
you'll see everywhere in BAR Observatory. It checks only what BAR Observatory itself captured; it
has no visibility into whatever internal tooling was used to build the binary.

Next: [01 — Config](01-config.md), where you'll see exactly what `bar init` wrote and how BAR
resolves your settings.
