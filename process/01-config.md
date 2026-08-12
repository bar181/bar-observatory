# 01 — Config

Configuration is **typed TOML** resolved through a 5-layer precedence chain
(compiled defaults < shipped < project < env < flags). A closed env allowlist means only three
known `BAR_*` variables are read (`BAR_ENABLED`, `BAR_DIR`, `BAR_RETAIN_DAYS`); any other `BAR_*`
variable is rejected outright rather than silently ignored, and a malformed value on an allowed
one errors instead of silently falling through to a lower-precedence layer.

- Defaults ship in `config/` (see the exported `config/*.toml`).
- The resolved config is emitted as deterministic JSON (schema: `schemas/resolved-config.schema.json`)
  so a downstream tool can validate exactly what the run used.
- `integrity.hash_algorithm` is **blake3** (BAR ADR-020); branding has a single source of truth.

Config is data, not code: a bad value is rejected at parse/use, never coerced.
