# End-user verification suite

This is not the 699-test suite the private working repository runs on every change — that source
isn't public, by design (see [`CRATES.md`](../CRATES.md)). This is smaller and does a different
job: it checks, as a black box, that the **published** crates.io artifacts actually do what this
project's docs claim, the way a real adopter would find out. See
[`wiki/human-md/verification.md`](../wiki/human-md/verification.md) for the full write-up of why
this exists and what it does and doesn't prove.

## Run it

```bash
sh tests/verify.sh
```

Already have `bar` and `bar-mcp` on your `PATH` and don't want to reinstall?

```bash
SKIP_INSTALL=1 sh tests/verify.sh
```

Requires: `cargo`, `jq`, and `timeout` (macOS: `brew install coreutils` gives you `gtimeout`, which
the script falls back to automatically). Takes a few minutes — almost all of it is the one-time
`cargo install` compile.

## What each check does, why, and what to expect

### 1. Install

Runs `cargo install bar-hook bar-mcp bar-observatory --locked` against the real crates.io
registry — no path dependencies, nothing borrowed from a local checkout.

**Why:** if this fails, nothing else in this suite can run, and it's also the first thing any real
adopter does.

**Expected:** `[PASS] installed cleanly from crates.io, no path dependencies`

### 2. Determinism / reproducibility

Ingests the seven transcripts shipped in [`examples/capture/`](../examples/capture/), renders a
report, and diffs it field-by-field against the shipped
[`examples/deterministic/session.report.json`](../examples/deterministic/session.report.json).

**Why:** this is the project's central claim — same database in, byte-identical report out. This
check doesn't take that on faith; it reproduces it from scratch and compares.

**Expected:** `[PASS] every field matches the shipped report except source_db_hash / report.id
(expected to vary between ingests)`. Those two fields are expected to differ — they're derived
from the SQLite file's own content hash, and two ingests of the same input are not byte-identical
at the database-file level, only in the facts they extract. Every other field — every count, every
classification, every rework hotspot — matches exactly.

### 3. Checksum integrity

Runs `sha256sum -c checksums/SHA256SUMS.txt` over the whole repo.

**Why:** confirms every shipped file matches its published hash — nothing drifted or was tampered
with between what the manifest says and what's actually on disk.

**Expected:** `[PASS] every shipped file verifies against the manifest`

### 4. `bar doctor` health

Runs `bar doctor` against the store built in check 2.

**Why:** `bar doctor` is this project's own honesty check — "is the recorder itself actually
working, and is anything missing?" This confirms it reports a healthy store after a real capture,
not just that the binary runs.

**Expected:** `[PASS] bar doctor exits 0 over a real capture store`

### 5. Config validity

Runs `bar init` in a clean directory, then `bar doctor` against the config it just wrote.

**Why:** this exact class of bug — a shipped default config the binary itself rejects — is a real
regression that happened once before it was caught (see the ADR-128 gate log in the private
repo's `DECISIONS.md`, referenced from `CHANGELOG.md`). This check exists specifically so it can't
happen silently again.

**Expected:** `[PASS] the config bar init writes is accepted by the binary with no error`

### 6. MCP contract

Starts `bar-mcp`, sends a real `initialize` then `tools/list` JSON-RPC request over its actual
stdio transport, and counts the tools in the response.

**Why:** this project claims a 12-tool, strictly read-only MCP surface. This check doesn't read
that claim from a doc — it starts the real server and counts what a real client actually gets
back.

**Expected:** `[PASS] bar-mcp returns exactly 12 tools over real newline-delimited stdio JSON-RPC`

**Not checked here:** that write attempts are genuinely refused, not just absent from the tool
list — that's deeper than a shell script can prove without a much bigger harness, and stays
covered by the private test suite instead. Disclosed, not silently skipped.

## Reading the output

Every check prints one `[PASS]` or `[FAIL]` line. On failure, the script also prints the relevant
diff or log path so you can see exactly what didn't match — nothing is hidden behind a bare exit
code. The script itself exits `0` only if every check passed; any single `[FAIL]` makes it exit
`1`, so it works as a CI gate as well as something to read by eye.

```
----------------------------------------
6 passed, 0 failed
```

is the only fully-passing output. Anything else means something real changed between what this
repo claims and what the published binary actually does — please
[open an issue](https://github.com/bar181/bar-observatory/issues) with the `[FAIL]` output if you
see one.
