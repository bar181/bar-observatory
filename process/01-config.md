# Step 1 — Config: how BAR resolves your settings

`bar init` (see [00 — Init](00-init.md)) wrote a `.bar/config.toml` for you. This step explains
what's in it and, more importantly, how BAR decides which value actually wins when the same
setting is set in more than one place.

## Typed TOML, five layers, one clear winner

BAR's configuration is **typed TOML** — every field has a real type, so a bad value fails loudly
at parse time instead of being silently coerced into something else. Settings are resolved
through five layers, each one able to override the layer before it:

```
compiled defaults  <  shipped config  <  project config  <  environment  <  CLI flags
```

In practice: the defaults shipped in `config/*.toml` are your baseline, your project's
`.bar/config.toml` can override them, a `BAR_*` environment variable can override that, and a
command-line flag wins over everything. Nothing is hidden — the fully resolved config is emitted
as deterministic JSON (validated against `schemas/resolved-config.schema.json`), so any tool
downstream can see exactly what settings a given run actually used.

## A closed environment allowlist

Only three environment variables are ever read: `BAR_ENABLED`, `BAR_DIR`, and
`BAR_RETAIN_DAYS`. Any other `BAR_*` variable is **rejected outright**, not silently ignored —
if you meant to set something and mistyped the name, you'll find out immediately rather than
wondering later why it had no effect. The same discipline applies to values: a malformed value
on one of the three allowed variables (say, `BAR_RETAIN_DAYS=abc`) is an error, not a silent
fall-through to a lower-precedence layer.

## Integrity

The resolved config is hashed with **blake3**, BAR's single hash algorithm across the whole
project — branding and integrity checks both key off it, so there's one source of truth for
"did this config change."

The short version: config is data, not code. A bad value is rejected at parse time or at use,
never guessed at or coerced.

Next: [02 — Database creation](02-database-creation.md), where your resolved config becomes a
real local SQLite store.
