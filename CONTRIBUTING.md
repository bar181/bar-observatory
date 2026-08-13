# Contributing

Thanks for taking a look at BAR Observatory. This repository is the front door and documentation
for the project — no crate source lives here by design; crate source publishes to crates.io
directly from a private working repo. Everything you see here is hand-maintained and open to a
PR, **with one exception**: `CRATES.md` is regenerated straight from the real published crates'
manifests, so please don't hand-edit it — open an issue instead if it looks stale or wrong.

- **Bug reports & feature requests:** GitHub issues are welcome, both for this documentation and
  for the crates themselves (crate-specific issues: link the crate from [CRATES.md](CRATES.md)).
- **Docs/examples PRs:** welcome directly here — README, RUN.md, `process/*.md`, `wiki/`,
  `examples/`. If something's unclear, confusing, or out of date, a PR fixing it is genuinely
  useful — you don't need permission to send one.
- **Determinism contract:** the report render path is pure — same database in, byte-identical
  output out. If you're proposing a change to a crate that would introduce wall-clock time, RNG,
  or a network call into that render path, please open an issue first; that class of change needs
  discussion before code.
