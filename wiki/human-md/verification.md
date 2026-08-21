# How to check this isn't just marketing

Every claim on this project's front page — deterministic, byte-identical, local-only, honest
about what it can't see — is easy to assert and hard to prove. This page is about the second
part: how you check it yourself, without trusting a word of prose, including this one.

If you'd rather read the raw evidence than the explanation, skip straight to
[the test suite itself](../../tests/README.md) — this page is the "why," that page is the "how."

## The headline result

An install done exactly the way a stranger would do it — nothing borrowed from this project's own
development, no shortcuts — reproduced the shipped example report field for field:

> **99 of 101 fields matched exactly.** Every single measured figure — 60 errors, 373 test
> results, 96 rework hotspots, all 17 tool counts, every classification — identical. The only two
> differences (`source_db_hash`, `report.id`) are the ones this project's own docs already
> disclose as expected to vary between ingests, not a correctness gap.

That test — install from crates.io, ingest the example transcripts that ship in this repo, diff
the result against the shipped report — is now a real, repeatable script:
[`tests/verify.sh`](../../tests/verify.sh). Anyone can run it. Nothing about it depends on
trusting the person who wrote this page.

## Why this matters more than a test-passing badge

You'll see "699 tests, all green" mentioned elsewhere in this project's docs. That number is real,
but it's not something you can check yourself — the test suite it describes lives in a private
working repository, by design (this public repo carries the front door and the published crates,
not the source). A badge that says tests passed is still just a claim from the outside.

What you're reading on this page is different: a **black-box** check. It doesn't ask you to trust
that the internal tests exist or passed. It has you install the exact same binary anyone else
would install, from the exact same public registry, and checks whether it actually does what the
docs say — using only things you can see and re-run yourself.

## What the suite actually checks

Six checks, each tied to a specific claim this project makes about itself:

| # | Check | What it proves |
|---|---|---|
| 1 | Install | `cargo install bar-hook bar-mcp bar-observatory --locked` works cleanly from crates.io, no hidden path dependencies |
| 2 | Determinism | The "byte-identical" claim, above — real transcripts in, the exact same report out |
| 3 | Checksums | Every file in this repo matches its published hash — nothing was tampered with or drifted |
| 4 | `bar doctor` health | The tool's own honesty check reports a healthy store after a real capture |
| 5 | Config validity | The config `bar init` writes for you is one the binary actually accepts (a real bug, once, before it was caught) |
| 6 | MCP contract | The 12 MCP tools this project claims to expose are the 12 tools a real client actually gets back |

Full detail on each — the exact command, the exact expected output — lives in
[`tests/README.md`](../../tests/README.md).

## What it doesn't check, on purpose

This suite is honest about its own limits, the same way the reports it verifies are honest about
theirs. It does not re-prove the 699 internal unit and integration tests — those live in private
source and this suite has no access to them. It does not verify the deeper read-only-enforcement
inside the MCP server (that a write attempt is genuinely refused, not just absent from the tool
list) — that's covered by the private suite, not re-provable here without a much bigger harness.
Where a claim can't be checked from the outside, this page says so instead of implying otherwise.

## Run it yourself

```bash
git clone https://github.com/bar181/bar-observatory
cd bar-observatory
sh tests/verify.sh
```

Takes a few minutes — most of it is the one-time `cargo install`. If you already have `bar` and
`bar-mcp` on your `PATH`, add `SKIP_INSTALL=1` to skip straight to the checks.
