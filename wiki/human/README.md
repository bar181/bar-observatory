# BAR Observatory Human Wiki

## Start

1. Install released packages — `cargo install bar-observatory` (the `bar` CLI). See
   [CRATES.md](../../CRATES.md) for the full crate list, what each one does, and its crates.io
   status.
2. Run `bar init` to create TOML configuration.
3. Run a Claude Code task/session.
4. Run `bar report` for the deterministic engineering report.
5. Optionally enable the separate self-improvement report.
6. Run `bar doctor <db>` to confirm the recorder and its capture channels are actually healthy
   (not part of the deterministic report — a live diagnostic, honest about what wasn't captured).

## Read the reports

Start with tasks and completion evidence, then rework hotspots, agents/handoffs, skills, human-versus-AI recovery, validation, micro-observations, and silent signals.

The self-improvement report contains LLM interpretation. Facts remain in the deterministic report.

Every report carries `report.schema_version`. Check it before trusting an old report on disk against a newer contract — a report generated under a prior schema version may be missing fields a current reader expects, and that is the intended way to tell the two apart, not a bug.
