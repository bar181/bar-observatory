# Contributing

This public repository is a **generated export** of a private factory build. Source changes are made
in the factory and re-exported deterministically; pull requests that hand-edit generated files
(everything except this note's intent) will not survive the next export.

- **Bug reports & feature requests:** GitHub issues are welcome.
- **Determinism contract:** the report render path is pure — same DB → byte-identical output. Any
  contribution that introduces wall-clock/RNG/network into the render path will be rejected.
- **Tests:** `cargo test -p bar-observatory` must pass; schema + front-end gates must stay green.
