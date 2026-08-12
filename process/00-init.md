# 00 — Init

`bar init` bootstraps a project. It is **idempotent** and **never clobbers** existing config.

```bash
bar init --dir .
```

What it does:
- writes `.bar/config.toml` (typed config; see [01-config](01-config.md)) only if absent,
- creates the local SQLite stores under `.bar/` (see [02-database-creation](02-database-creation.md)),
- prints where everything landed.

No network, no API key, no account. Everything is local to `--dir`.

## Health check
`bar doctor [<db>]` is a **live** environment diagnostic (separate from the deterministic report):
it confirms BAR itself, validates a store (SQLite magic bytes), and reports which capture channels
actually carry rows (honest-absence) — so "is the recorder working, and what did it actually capture?"
is a reported fact, never a silent blind spot. It stays blind to the build flywheel by identity.
```bash
bar doctor .bar/ambient.sqlite
```
