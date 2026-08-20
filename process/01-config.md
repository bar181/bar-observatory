# Step 1 — Config: how BAR resolves your settings

`bar init` (see [00 — Init](00-init.md)) wrote a `.bar/config.toml` for you. This step explains
what's in it and, more importantly, how BAR decides which value actually wins when the same
setting is set in more than one place.

## Typed TOML, four layers, one clear winner

BAR's configuration is **typed TOML** (TOML is a plain-text, human-readable config-file format)
— every field has a real type, so a bad value fails loudly at parse time instead of being
silently coerced into something else. Settings resolve through four layers, each able to
override the one before it:

```
compiled defaults + shipped TOML  <  project TOML  <  environment  <  CLI flags
```

The first box is one layer, not two, and the code says so in as many words: there is no
Rust-literal default distinct from the shipped `config/*.toml` today, so the resolver names that
layer `CompiledDefaultsAndShippedToml` rather than implying two independent sources contributed.
It is the kind of small honesty this project would rather write down than round off.

In practice: the shipped defaults are your baseline, your project's `.bar/config.toml` overrides
them, an allowlisted `BAR__*` environment variable overrides that, and a command-line flag wins
over everything. Nothing is hidden — the resolved config carries the list of layers that actually
contributed, is emitted as deterministic JSON (the same inputs always produce the exact same JSON
output, byte for byte) and is validated against
[`schemas/resolved-config.schema.json`](../schemas/resolved-config.schema.json), so any tool
downstream can see exactly what settings a given run used.

## A closed environment allowlist

Environment overrides use a doubled-underscore path under a `BAR` prefix —
`BAR__SECTION__FIELD` maps to `section.field`. Exactly three paths are on the allowlist:

| Environment variable | Config path | What it sets |
|---|---|---|
| `BAR__STORAGE__DIRECTORY` | `storage.directory` | where the local stores live |
| `BAR__STORAGE__RETAIN_DAYS` | `storage.retain_days` | how long captured data is kept |
| `BAR__REPORTS__SELF_IMPROVEMENT__ENABLED` | `reports.self_improvement.enabled` | the optional self-improvement layer |

Anything else matching the prefix is **ignored and reported** — the resolver records a warning
naming the variable rather than silently dropping it, so a mistyped name shows up in the run's
own warnings instead of leaving you to wonder later why it had no effect.

The allowlist is deliberately short. Redaction policy, in particular, is configurable through
TOML and the CLI *only*: an inherited environment variable is a weaker trust boundary than an
operator typing a flag, and privacy settings are not somewhere to be casual about that
distinction.

## Integrity

The resolved config is hashed with **blake3** (a fast cryptographic hash algorithm — it turns
any input into a short fixed-length fingerprint, so even a one-character change produces a
completely different hash), BAR's single hash algorithm across the whole project — branding and
integrity checks both key off it, so there's one source of truth for "did this config change."

The short version: config is data, not code. A bad value is rejected at parse time or at use,
never guessed at or coerced.

Next: [02 — Database creation](02-database-creation.md), where your resolved config becomes a
real local SQLite store.
