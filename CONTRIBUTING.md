# Contributing

Thanks for taking a look at BAR Observatory. This repository is the front door and documentation
for the project — no crate source lives here by design; crate source publishes to crates.io
directly from a private working repo. Everything you see here is hand-maintained and open to a
PR, **with one exception**: `CRATES.md` is regenerated straight from the real published crates'
manifests, so please don't hand-edit it — open an issue instead if it looks stale or wrong.

- **Bug reports & feature requests:** GitHub issues are welcome, both for this documentation and
  for the crates themselves (crate-specific issues: link the crate from [CRATES.md](CRATES.md)).
  Found a real bug and already have a fix in mind? Say so in the issue — see "Code contributions"
  below.
- **Docs/examples PRs:** welcome directly here — README, RUN.md, `index.html`, `process/*.md`,
  `wiki/`, `examples/`, the Claude Code plugin (`.claude-plugin/`, `commands/`, `hooks/`). If
  something's unclear, confusing, or out of date, a PR fixing it is genuinely useful — you don't
  need permission to send one.
- **Code contributions:** the crate source lives in a private working repo, not here, so there's
  no public PR path to it yet — general policy is still deferred while there isn't enough contributor
  volume to justify designing one. If you have a patch for a real, reproduced bug, open a GitHub
  issue describing the bug and the fix you have in mind; if it's a good fit we'll follow up about
  the fastest way to get it in (typically a direct invite as a private collaborator, or you sending
  the patch and us landing it credited to you). This isn't a formal process yet, just: don't let a
  working fix go to waste because you couldn't find a path — ask.
- **Determinism contract:** the report render path is pure — same database in, byte-identical
  output out. If you're proposing a change to a crate that would introduce wall-clock time, RNG,
  or a network call into that render path, please open an issue first; that class of change needs
  discussion before code.
