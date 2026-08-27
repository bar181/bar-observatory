# Changelog

All notable changes to BAR Observatory.

## [0.3.0] — published to crates.io; GitHub docs updated

**Not breaking for any documented CLI usage.** Every crate in the family (all 15 publishable
crates) moved from 0.2.1 to 0.3.0 together — `bar-store`'s schema and a few downstream public
struct fields changed, and every dependent needed its own version bump so the whole dependency
graph resolves against one consistent `bar-store`, not two incompatible instances (Cargo's 0.x
caret semver treats the middle version position as the breaking one). Verified the same way prior
releases were: a real `cargo install --locked bar-observatory --version 0.3.0` and
`cargo install --locked bar-hook --version 0.3.0` from the published registry, then genuine runs
against the installed binaries (`bar --help`, and `bar-hook` invoked with every `OBSERVATORY_*`
env var removed) — not just a passing test suite.

**Thank you to Piotr** for the two pieces of real-session feedback that drove most of this
release: the "TOP PRIORITY FIXES" report on the two missing test-runner dialects (item 1 below),
and the separate consumer-side brief that surfaced the hook-wiring defect and five of the other
items here. Both are exactly the kind of field evidence — a real Python `unittest` harness run and
a real Vitest product-repo run — that a synthetic test suite doesn't surface on its own.

1. **Hook commands installed with no database path, so events silently fell back to a spool
   instead of `.bar/ambient.sqlite`.** `bar-hook` opened storage ONLY from `OBSERVATORY_DB`, and
   nothing wires that variable into the shipped hook command (`hooks/hooks.json` runs a bare
   `bar-hook <event>`) — so a plugin install with no external environment setup captured nothing
   into the real database, ever, without anyone noticing. Fixed: `bar-hook` now defaults to
   `.bar/ambient.sqlite` (relative to wherever it runs), creating the directory if needed, when
   `OBSERVATORY_DB` is unset — `OBSERVATORY_DB` still overrides it for anyone who wants a
   different location. Verified by spawning the real installed binary with every `OBSERVATORY_*`
   variable removed and confirming a real row lands in the database, not the spool.
2. **Two real test-runner dialects were invisible to ingest-time validation extraction.** Python's
   `unittest` prints its count and verdict as two SEPARATE lines (`"Ran N tests in Ms"` then a
   bare `"OK"`/`"FAILED (...)"`), and Vitest's own summary line has NO colon after `"Tests"` —
   both were silently unreadable even though pytest/npm/cargo/generic-exit already worked. Both
   are recognized now.
3. **`content_excerpt` truncates at 512 bytes with no signal distinguishing "this value is short"
   from "this value was cut."** A census over `content_excerpt` alone silently under-reported any
   signature past the cut point — measured at 32% of rows sitting exactly at the cap in a real
   store. A new `content_excerpt_truncated` column on `transcript_turns` makes the two cases
   distinguishable.
4. **`bar query`'s read-only refusal (correct) left no write path into scored layers at all.**
   `task_grades`/`method_scores` could only ever be populated by `bar` itself, and there was no
   `bar` command that did it. A new `bar score <db> --kind task_grade|method_score --json '{...}'`
   command writes through the same typed store methods `bar report` reads from — never raw SQL.
5. **`bar doctor` reported a flat `capture` OK on a store where most of the scored layers were
   empty.** A store carrying a transcript and nothing else can answer "what was said," never "what
   did we already try, and did it work" — the question that prevents redoing finished work. A new
   `depth` check reports how many of the 7 scored layers are actually populated (never a failure —
   a transcript-only store is a legitimate configuration, just no longer silently implied to be
   more than that).
6. **`run_uuid` defaulted to the literal constant `"bar-ingest"`** when `--run-uuid` was omitted,
   so every omitted-flag ingest, from every project, landed in one shared run — and the moment a
   caller started passing `--run-uuid` correctly, it forked a full duplicate of everything already
   ingested under the constant. Now generates a fresh id per call instead.
7. **No freshness signal existed at all.** `transcript_turns` carries no timestamp column, so a
   consumer had to guess from file mtimes — which breaks, because any reader touches SQLite's own
   `-wal`/`-shm` sidecars. A `.bar/.last-capture` heartbeat file, written ONLY by `bar ingest`,
   gives a dependency-free "did a capture happen" signal without opening the database at all.
8. **`MAX(turn_id)` is not a row count** — it's a global autoincrement that keeps climbing through
   upserts — and `bar query`'s table format puts a scripted consumer one off-by-one away from
   grabbing its own footer line instead of the value. A new `turns_count` named query plus
   `bar query --format value` (a bare scalar, no header/footer) removes both traps.
9. **Runs never finalized** — `runs.status` stayed `incomplete` indefinitely, with no explicit way
   to close one out. `bar ingest --finalize` marks the run complete once you know a session is
   really over (kept opt-in, not automatic-at-EOF, since an ambient/incremental capture calls
   `bar ingest` repeatedly against a still-growing transcript).
10. **`--task`/`--trial`/`--rep` are integers, undocumented as such** — `--task <id>` read as
    free-form, but `runs.task_id` has no lookup table and is a plain `INTEGER`. `bar --help` now
    says `<int>`.
11. **`bar compare --by condition` silently grouped everything into one `(unlabeled)` bucket**
    when no run carried a `--condition` — now warns how many runs have none, rather than rendering
    a meaningless comparison as if it were a real one.

See [process/03-ingestion.md](process/03-ingestion.md) for the session-start/session-end
`bar ingest` recipe these changes make possible (`--run-uuid`, `--finalize`, the heartbeat file).

## [0.2.1] — published to crates.io and pushed to GitHub

**Not breaking.** Every fix below is an internal correctness or security fix; no config schema or
CLI surface changed. All 16 crates are live on crates.io at 0.2.1 (verified via the crates.io API
and a real `cargo install --locked` from the published registry, then a genuine
`init`/`ingest`/`report`/`doctor` run against the installed binary), and `main` on
`github.com/bar181/bar-observatory` is synced to this same content (tag `v0.2.1`) — see the
`[0.2.0]` entry below for why crates.io publish and the GitHub push are two independent standing
gates on this repo, not one; both are now crossed for this version.

An independent review of the report-example redesign + measurement-bug-fix PR (merged 2026-08-20,
commit `914dd14c`) found and fixed six further issues before merging, beyond the PR's own
ADR-129/130/131 work documented under `[0.2.0]` below:

1. **Script injection in the shipped report renderer.** Tool names read from the transcript reached
   an inline `<script>` block via HTML-only escaping — a real script-injection path present in
   every generated report. Fixed with proper JSON escaping and DOM-safe (`textContent`) rendering
   in the shared plate JS runtime.
2. **The blind-store honesty guarantee failed on exactly the input it was written for.** A
   legacy/offloaded-only store rendered confidently clean instead of flagged blind. Fixed by
   deriving the flag from run coverage, not scan hits.
3. **Offloading a large `tool_use.input` silently zeroed six detectors** — rework, hotspots, agent
   spawns, skill usage, TodoWrite, and the task ledger — because the size cap discarded the whole
   call's identity along with its payload. Fixed with a declared per-tool-type bulk-subfield list,
   so only the oversized field is trimmed and everything else survives.
4. **`HUB.aisp` asserted a false equation inside its own self-certifying evidence block**
   (`31≡29` tables against a real count of 32) and was missing `correlation_stats` from its routing
   map. Fixed and re-verified against a freshly migrated store via a real schema dump, not just
   cross-referenced migration files.
5. **Re-ingest — the documented remedy for a `partial` validation caveat — silently double-counted**
   instead of fixing anything, from two independent causes: a migration back-fill/live-ingest
   line-number mismatch, and `NULL` defeating a `UNIQUE` constraint on run-less ingest. Both fixed
   with one mechanism: clear a turn's facts before re-deriving them (ADR-131).
6. **pytest's verdict matcher accepted plain prose** (e.g. "The deploy failed in staging...") as a
   test result — the guard test written for exactly this case asserted the acceptance instead of
   the refusal. Fixed, and the test corrected to assert the refusal it was meant to.

`cargo test --workspace`: 699 green (0 failed, 6 ignored) at merge time; checksums and
`scripts/public-export.sh --check` both verified clean. Version bumped 0.2.0 → 0.2.1 across the
workspace, `bar-mcp`, `bar-observatory`, and the plugin/marketplace manifests — a patch release,
since every crate's public CLI surface and config schema are unchanged.

**Also found while staging this release:** the shipped deterministic example's own
`renderer_version` had been stale at `0.1.1` — two patch releases behind — because the examples
had been regenerated from data without a fresh `cargo build --release` afterward. Rebuilt from a
genuinely fresh 0.2.1 binary; the field-for-field diff against the previously-shipped example was
exactly the four fields expected to move on any regeneration (`renderer_version`, `source_db_hash`,
`template_hash`, and the `report.id` derived from the hash) — no measured figure changed. New
example id `barobs-14fd056be293`, propagated to every current cross-reference (`examples/README.html`,
the four hand-assembled report pages, `wiki/human-html/report-guide.html`,
`bar-obs-private/report-scorecard.html`); the id in this file's own `[0.2.0]` entry below and in `PROVENANCE.json`'s dated history was
deliberately left as `barobs-801e4778ddff` — those are a record of what was true when they were
written, not live claims.

**Caught by an independent adversarial review pass before this release shipped**, two fresh
reviewers reading the staged content cold (not the author) found four more real issues:
1. `examples/interpreted/management-read.md` stated **139** tool calls with no matching result;
   `session.report.json` and its own HTML twin both say **136**. The Markdown-only figure was
   wrong — fixed to match the measured value. **Correction, caught by a second independent
   review pass**: the first fix was incomplete — `examples/interpreted/diagnostic-review.md`
   had the identical 139-vs-136 defect (its own HTML twin was correct, same as management-read's
   had been), missed because the first pass grepped one file instead of the whole example set.
   Also fixed; both Markdown files now agree with their HTML twins and the source report.
2. `README.md` stated its own engine size two different ways in the same file ("15 engine
   crates" at one point, "16-crate `bar-*` engine" at another). Reconciled to `CRATES.md`'s
   generated, self-computing count (16), the only one of the two that can't drift.
3. `index.html`'s crate table listed `bar-root-resolve` twice (a copy-paste artifact), and its
   own prose said "fifteen-crate engine" — same drift as #2. Duplicate row removed, prose
   corrected.
4. `wiki/README.html` carried the identical duplicate-row and stale-count defects as `index.html`
   (it mirrors that page) — fixed the same way.
No other files were touched by this pass; the review's other findings (the version-sequencing
gap this changelog already discloses above, and a disclosed-not-automated "Boss Mode" view) are
real but are not documentation defects — they resolve when this version actually publishes, or
are open product scope, not something a text edit fixes.

## [0.2.0] — published to crates.io and pushed to GitHub

**Breaking.** All 16 crates went live on crates.io on 2026-08-17 (human go-ahead given, verified
via a real `cargo install --locked` from the published registry), and this repository's own
commits were pushed to `github.com/bar181/bar-observatory` the same day — a separate
human-approval gate, crossed independently; crates.io publish and the GitHub push are two
independent standing gates on this repo, not one. A
`[privacy]` config key is removed with no compatibility shim, the capture schema moved six
migrations (v17 → v23), and stored-data semantics changed — a v17 store from a 0.1.x install
migrates automatically on the next write (verified against a real v17 store this session, and
locked in by a regression test so the next migration can't silently break it).

### Six real findings from an external reviewer, fixed

An external reviewer (Piotr) ran BAR Observatory 0.1.1 against real sessions and reported six
reproducible defects (`bar-obs-private/docs/piotr-feedback-aug15.md`, 2026-08-15). All six are
closed as of this release:

1. **The `[privacy]` config table was fully decorative** — zero code paths read
   `redact_home_paths`/`redact_secrets`/etc. Replaced, not deprecated, by a real `[redact]` table
   (`mode`/`paths`/`secrets`) that every field of which is read by non-test code (ADR-125/ADR-127).
2. **Archival ingest silently misresolved the workspace root**, masking all 22 edits in his
   reproduction and rendering a clean, empty report with no indication anything went wrong. Fixed
   by a disclosed workspace-root precedence chain (`--workspace-root` flag → env → transcript
   `cwd` → git root → ingest cwd) whose winning rung is now always visible in the report and the
   stored row (ADR-126).
3. **Write-seam masking damaged error detection itself** — the scrub ran before the error/pairing
   detectors ever saw the string, hiding two of four real errors and breaking tool-call pairing in
   his reproduction. Fixed by moving redaction to the render/export seam only; storage is now
   always verbatim (ADR-125).
4. **Masking could produce a "plausible" but silently empty result** with nothing distinguishing
   "genuinely nothing happened" from "the data was there and got masked away." Every `not_observed`
   result now carries a reason code (`no_data` / `parser_missing` / `filtered_by_policy`) instead
   of a bare, unexplained empty.
5. **The parser catalogue advertised 4 languages, shipped 1** — `["cargo","pytest","npm",
   "generic-exit"]` was configured, but only cargo's `test result:` line had a real matcher; his
   own pytest runs (3×) all silently read `not_observed`. pytest/npm/generic-exit matchers are now
   implemented and covered by fixture tests; the catalogue only ever lists what has a real
   matcher (`IMPLEMENTED_VALIDATION_PARSERS`), checked against the advertised config at parse time.
6. **Nothing recorded how any resolved value was derived** — no provenance for workspace root,
   redaction policy, or config layering. The report now names which layer/rung won for each
   (config resolution, workspace-root resolution, and the redaction policy in effect when the
   report was generated).

### Also fixed this release (not from the external report)

- **`bar-proxy`'s `bodies` capture channel** was dead-lettering every `/v1/messages/count_tokens`
  response with an opaque `"expected value at line 1 column 1"` — the raw bytes carried a
  deterministic, unexplained 3-byte wrapper around otherwise-valid JSON. `parse_envelope` now
  strips it; the dead-letter message for anything still unparseable now names the byte count and
  a hex preview instead of the bare parser error. (Root-cause investigation found these are
  Anthropic's `/count_tokens` diagnostic responses, not billed completions — so contrary to this
  release's original severity read, they carried no completion-usage data to lose; a routing fix,
  `NON_COMPLETION_PATH_SUFFIX`, is what actually stops them from reaching the parser at all.)
- **`bar --help` and bare `bar` exited 2** with `"unknown command: --help"` instead of printing
  usage and exiting 0 — the first thing a new user hits.
- **`bar doctor`** — a real, working self-diagnostic (`init`/`report`/`ingest`/`doctor`/
  `interpret`/`query`/`dlq`/`reap` — store validity, capture health, lifecycle, DLQ status in one
  command) so the next silent failure costs a `bar doctor` run, not a source dive across four
  crates the way this engagement started.

### Documentation and packaging

Content below: the deterministic report contract (schemas), the documented process, default
configs, real example reports, and a generated crate index (`CRATES.md`) pointing at the 16
gold-standard crates — see `CRATES.md` itself for each crate's real, current crates.io publish
status.

- **Corrected a stale crate count found during final pre-publish review**: `bar-root-resolve`
  (extracted from `bar-mcp` as a shared root-resolution crate, INV-10) was never folded into the
  "15 crates"/"14-crate engine" figures quoted in README.md and `scripts/public-export.sh`'s own
  generated prose — it's 16 published crates / a 15-crate engine. The engine-crate count in
  `CRATES.md`'s header is now computed from the real manifests at generation time instead of
  hand-typed, so this can't silently drift again the next time a crate is added.
- **`bar-root-resolve` had no README.md at all** (the only one of the 16 crates missing one —
  it predates a documentation pass the other 15 crates got). Added, grounded in its actual
  source (`resolve`/`resolve_or_fallback` for DB-root resolution, `workspace::resolve_workspace_root`
  for ADR-126 workspace-root resolution), matching the format the other 15 crate READMEs use.

- **Markdown catches up with HTML, and two rail defects surface on the way (2026-08-19).** The
  report scorecard's top finding was that Markdown is a second-class citizen: four of five pages
  were strongest in HTML and flatter in Markdown, yet Markdown is the copy that lands in a pull
  request. The generated report had fifteen sections and no way to move between them while its HTML
  twin had a numbered plate rail.
  - `to_markdown` now emits a numbered **contents index**, derived from the document's own `##`
    headings — like the HTML rail — so it cannot drift out of step with the sections that exist.
    Anchors follow GitHub's real slug rule, including the awkward `Evidence & integrity` →
    `#evidence--integrity`. The three hand-built example reports got the same index.
  - **Two defects in the shipped HTML surfaced while pinning that down**, both visible to a reader:
    the plate rail double-escaped its labels (`Evidence &amp;amp; integrity` on screen) and leaked
    the HTML entity into the section's own anchor (`#evidence-amp-integrity`). Fixed by un-escaping
    heading text once before deriving either.
  - **Four sections were named differently in the two formats** — a chip in HTML, a parenthetical in
    Markdown — so the two disagreed about what section 11 was called. Now `Rework · measured` in
    both, with the chip preserved. `Cost` also had two different Markdown titles depending on
    whether tokens existed while HTML had one; unified.
  - A new test asserts the index and the rail **agree on every section number and label**, that
    every index anchor resolves to a heading, and that the `&` case anchors the way GitHub does.
  - `cargo test --workspace` green at 685.

- **`REPORT-SCORECARD.md` is now `report-scorecard.html`.** The scorecard lived in Markdown while
  scoring four reports on design; the repository's own rule is that no table, contract, or score
  lives in more than one file, so it moved rather than being duplicated. It is built in the same
  plate system as the reports it scores, with one deliberate departure recorded in its stylesheet:
  the two layer accents sit ΔE 7.5 apart under normal vision — below the categorical floor — so the
  score meters encode magnitude in a single hue and layer identity stays written, which is the rule
  the reports themselves already follow.

- **Adversarial probes over the two fixes above found a defect in one of them (2026-08-19, ADR-131).**
  Both ADR-129 and ADR-130 removed a silent undercount that flattered the session, and both shipped
  new counting code. A probe suite was written to ask that new code the same question the ADRs asked
  the old code — *can you lose a fact and still sound confident?* Eight probes; two findings:
  - **`validation_facts` collapsed identical verdict lines.** It was keyed
    `UNIQUE(run_id, seq, evidence_line)` with `INSERT OR IGNORE`, so two byte-identical lines in one
    tool result became one row. Not a contrived shape: `cargo test --workspace` emits one
    `test result:` line per crate, and every doc-test-free crate emits exactly
    `test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s`.
    A workspace run under-reported its own verdict count, in the flattering direction. Identity is
    now `(run_id, seq, line_no)` — the line, not its text (migration 0026, a table rebuild;
    existing rows are back-filled, never dropped).
  - **The structure-lost count never reached the store.** ADR-130 promised the rare case where even
    a block's identifying fields exceed the cap would be "counted separately, so the rare real loss
    is not hidden". It was counted into an in-memory struct that evaporates when the ingest process
    exits — the same defect DD-08 had to fix for `plan_docs`, whose doc comment claimed a count no
    table ever held. The fallback row now marks itself, and the capture-quality row reports it.
  - **The example capture never had the shape that triggered the first defect**, which is exactly
    why it survived every previous pass. Re-deriving the published figures on the fixed code changes
    nothing — stated as the confirmation it is, not as evidence the fix was unnecessary.
  - Six probes found nothing and are kept as tests rather than deleted: array-shaped `content`,
    unlisted envelope fields, mixed-vintage stores, run-less ingest, marker forgery, re-ingest
    idempotency. "We checked this" is only durable if it runs.
  - The reported defect was also confirmed end-to-end against the pre-fix binary built from the
    commit before ADR-129, over a capture matching the reporter's description (5 of 138 tool results
    offloaded, full pytest runs, verdict at the tail). Before: `not_observed`, *"no cargo
    `test result:` lines in this transcript's tool outputs"* — the reporter's symptom verbatim, on a
    session containing five pytest runs. After: `observed`, 5 verdicts, 4 passed / 1 failed, last
    verdict FAILED.
  - `cargo test --workspace` green at 680.

- **The size cap now offloads the payload and keeps the envelope (2026-08-19, ADR-130).** ADR-129
  disclosed three measurements that shared its blind spot. Measuring that blind spot properly found
  something worse than a blind spot, in one line of the ingest path: an oversized block was not
  trimmed, it was **replaced** by a `{"blob_sha":…}` pointer. Everything went with it, including the
  fields that have nothing to do with size and everything to do with identity. For the fixture's
  small errored block the discarded envelope is 56 bytes and the pointer that replaced it is 79 —
  the cap threw away structure smaller than the pointer it wrote instead. On a four-result fixture:
  - `summary.error_results` read **1** where the truth was 2, and `bar query <db> errors` returned
    one row instead of two: `is_error` went with the block, so a failure inside a large output was
    counted nowhere. The biggest outputs are disproportionately the interesting failures.
  - `flaky` read **`not_observed` — "none both passed and failed"** over a capture where two tests
    flipped, because one of the two runs was large. A confident wrong answer on exactly the capture
    most likely to contain a real flip.
  - the transcript channel reported **"2 unpaired tool_use/tool_result"** that did not exist:
    `tool_use_id` went with the block too, so the pairing oracle could not match an offloaded result
    to its call. The recorder was disclosing a coverage gap it had manufactured — the mirror image
    of ADR-129's defect, and it has been inflating that figure on every capture with a large tool
    result.
  - **The fix:** offload the payload field only (`content` for a tool result, `input` for a call),
    keep every other field, and add `blob_sha` / `offloaded` / `offloaded_field`. A declared
    per-block-type list rather than "whichever field is largest", so two structurally identical
    blocks always store the same way. A block whose envelope alone still exceeds the cap falls back
    to the bare pointer and is counted **separately**, so the rare real loss is not hidden behind the
    common harmless one.
  - **Per-test verdicts** (`test <name> ... ok|FAILED`) live inside the payload, so keeping the
    envelope cannot reach them; they get ADR-129's treatment — extracted at ingest into
    `test_verdict_facts` (schema v25), resolved per run, with the same `partial`-not-`none` rule.
  - **The legacy pointer shape is still recognised**, so upgrading the binary does not silently
    shrink an old store's disclosed gap to zero. Existing stores are not rewritten: a migration that
    edits captured data is not something this project does. Re-running `bar ingest` upgrades them.
  - Still not fixed, and now the only two left: the task-ledger and commit-output scans read body
    text. Both read output that is short by nature, and the offload count is disclosed either way.
    Stated in `wiki/human-md/architecture.md` as a floor on their counts.
  - 11 new tests, one per ADR rule. `cargo test --workspace` green at 672. The shipped examples were
    rebuilt: the demo capture has no offloaded results, so every measured figure is unchanged —
    which is itself the cross-check that the new fact path and the old scan agree where both can see.

- **A validation verdict is now extracted at ingest, not scanned at render (2026-08-19, ADR-129).**
  Reported by a user: `validation` still read *not observed* on real sessions despite the 0.2.0
  cargo/pytest/npm/exit matchers, because long tool outputs are offloaded to the blob store at
  ingest — so the report-time search over stored turn content never sees them — and the short
  excerpt keeps only the head while pytest prints its verdict last. Confirmed here before designing
  anything, and the reproduction was worse than the report:
  - A two-result capture (one small pytest run that passed, one 16 KB run that **failed**) rendered
    as `runs: 1, passed: 1, failed: 0, last_ok: true`, `status: "observed"`. Not a missing
    measurement — a **wrong** one: a session whose last test run failed reported as green, with no
    qualification. It now reads `runs: 2, passed: 1, failed: 1, last_ok: false`.
  - **The fix is the one the reporter proposed:** verdicts are read while the full output is still
    in hand and stored as typed rows (`validation_facts`, schema v24), so the measurement no longer
    depends on the offload threshold or on where a runner prints its summary.
  - **Resolving blobs at render time was considered and rejected**, and the ADR says why: it is the
    smaller change and would fix more detectors at once, but it would make the report depend on a
    directory the documented "copy the one SQLite file to another machine" path does not carry — and
    it would fail *silently*, reporting fewer runs with nothing on the page saying so. A test now
    renders a copied database with the blob directory deliberately absent and asserts the numbers
    are identical.
  - **Two holes were found reviewing the ADR before implementing it**, and both are load-bearing. A
    store holding runs from both before and after the change could not tell "ingested before this
    existed" from "ran no tests" — resolution is now per run, keyed on a recorded marker that the
    extraction pass ran. And the new stored text column bypassed the write-seam redaction that
    every other stored text column goes through; a verdict line routinely carries an absolute path.
  - **No existing store regresses and none silently lies.** A capture ingested before this change
    still reports what the old scan can read — but if that store also holds offloaded results, the
    section is `partial`, not `observed`, with a reason naming the count and the remedy (re-ingest).
    The same count is disclosed on the transcript capture-quality row, because the blindness affects
    the failure, flaky and commit scans too. Those remain blind; that is stated in
    `wiki/human-md/architecture.md` as a floor on their counts rather than left to be discovered.
  - The section note also stopped calling every verdict a cargo `test result:` line whichever
    matcher fired, and now names the runner and counts per runner.
  - 13 new tests, one per ADR rule plus the matchers' own; `cargo test --workspace` green at 661.

- **Wiki and docs pass (2026-08-19).** Every public page was read against the shipped example rather
  than against what it used to say, and the figures that had drifted were corrected at the source:
  - **`CRATES.md` was out of sync and the drift gate proved it.** `bar-root-resolve` was missing from
    the table entirely — 17 crates, not 15, 16 of which publish. `scripts/public-export.sh` now
    *derives* those counts from the manifests instead of carrying a hand-typed sentence that could go
    stale again, and the same correction landed in `README.md`, `wiki/human-md/architecture.md`,
    `index.html`, `wiki/README.html` and `llms.txt`.
  - **`template_hash` was weaker than the page claimed.** It hashed a fixed literal, so editing a
    stylesheet rule left the "hash of the template that rendered it" untouched. It now hashes the
    inlined stylesheet and page runtime themselves; a new test suite fails if either stops being an
    input. `wiki/human-html/report-guide.html` says so plainly rather than leaving the reader to
    assume the stronger claim.
  - **`not_recorded` and `not_observed` are no longer used interchangeably.** The schema has four
    absence states and the difference between the last two — "no rows in this store" versus "the
    writer exists but nothing invoked it" — is exactly the kind of distinction this project refuses
    to flatten elsewhere. `README.md`, `index.html`, `wiki/README.html`,
    `wiki/human-md/architecture.md`, `comparison.md`, `RUN.md`, `process/00`, `process/03`,
    `guide-junior-dev.html` and `llms.txt` were corrected, and architecture.md and both HTML hubs now
    carry the full four-state table with a real example of each.
  - **`process/01-config.md` described an environment allowlist that does not exist.** It named
    `BAR_ENABLED` / `BAR_DIR` / `BAR_RETAIN_DAYS` and said a non-allowlisted variable is "rejected
    outright". The real surface is `BAR__SECTION__FIELD` with three allowlisted paths, and an
    unknown one is warned and ignored. It also called the resolver five layers; the code calls it
    four, and says in as many words that the first two are fused. All corrected, table included.
  - **`process/06-use-cases.md` showed invented `bar query` output** and opened by calling the
    capture "actual Claude Code sessions". Both replaced with the tool's real rows and the stand-in
    disclosure the rest of the repo already carries.
  - **`wiki/human-html/report-guide.html` had drifted section by section** — a four-item
    recommendation list where the report emits three, "fifteen distinct tools" against seventeen, a
    sub-agent type that does not appear in the capture, an old stat bar, stale flaky-test names, "five
    of six channels" against nine, and — worst — a rework row still naming a real private path.
    Every one now matches `session.report.json`.
  - **Stale figures on the front pages.** `index.html` and `wiki/README.html` headlined
    "Twenty-five failures" over a 60-failure capture, showed a fabricated error list, rounded tool
    counts to `1,700+`, and claimed the capture "came out of one genuine Claude Code session".
    Corrected against the record, stand-in disclosure included.
  - **Three real CSS defects, found by rendering rather than reading.** A grid track in
    `report-guide.html` let a wide code block push its own label off-screen at 390px; the receipt's
    `REPRODUCIBLE` stamp lost its rotation the moment its reveal animation finished (`transform:none`
    in the shared keyframe) and sat half off the paper; and `.hero p` was quietly out-specifying both
    `.receipt-cap` and `.tagline`, rendering 11.5px captions at the lede's 19.5px. The same
    stacked-row overflow was fixed in the renderer's own stylesheet, where a long value would have
    pushed a user's report past the viewport on a phone.
  - **`assets/site-hero.png` still showed the previous crimson design** and the previous capture's
    numbers; regenerated, along with `examples/session-report.png`.
  - **`wiki/aisp/HUB.aisp`** now describes the real 17-key `ReportDoc`, the four-state `Absence`
    type, all nine capture channels with both coverage and status axes, the current example artifact
    set and the stand-in disclosure — and `Ε.δ` says honestly that it was not recomputed for this
    edit rather than re-asserting a stale number. The inline AISP specification on
    `wiki/README.html` got the same absence correction.
  - **The branding disclaimer described a palette the tool no longer uses.** `affiliation_disclaimer`
    still read "Academic crimson palette; no Harvard University marks…" while every page renders in
    the plate palette; the clause existed to pre-empt an association that no longer exists.
    Simplified to "No third-party marks are used and no endorsement is implied" in the crate default,
    both shipped configs and the paired fixtures, and the example footers were aligned to match. Two
    example pages also still linked a bundled-font licence file that was deleted two passes ago.
  - **Reproduced, not assumed:** the deterministic examples were rebuilt by running `bar report` over
    the shipped capture again. New report id `barobs-801e4778ddff`; the field-for-field diff against
    the previous JSON was exactly the three expected entries. `cargo test --workspace` is green at
    648 tests (the README said 543), and every public page re-validated at 1280 / 760 / 390 px in both
    themes with no horizontal overflow, no console errors, and nothing hidden with JavaScript off.

- **The generated report now IS the high-quality report (2026-08-18, third pass).** The plate design
  moved out of the hand-built example pages and into the renderer, so a user gets it on their own
  data:
  - New `bar-observatory/src/theme.rs` holds the inlined stylesheet, the page runtime, and
    `platify()`, which turns the flat `<h2>` body the section writers emit into numbered plates with
    a sticky index. Changing how a report *looks* no longer means editing the code that decides what
    it *says*.
  - `to_html` now emits a dark title plate, a six-figure run strip, a tool-composition signature
    band, a plate index with scroll-spy, light/dark following the OS with an in-page toggle, print
    styles, and a `<noscript>` note. It is still ONE self-contained file: no stylesheet, no script,
    no font, no image is fetched from anywhere — asserted by a test.
  - `to_markdown` gained an at-a-glance band and plain-text bar charts, so the two formats stay level.
  - Two shipped tests asserted on the old markup to prove a fact; they now assert the fact against
    the new markup, with a comment saying why the assertion changed.
- **Fixed two real bugs in the flaky-test detector**, both found by generating a capture and checking
  the tool's answer against the input rather than trusting it:
  - The FIRST `test … ok` line of every tool_result was silently dropped, because the stored JSON
    prefix left no space before the word `test` and the guard demanded an exact token.
  - The LAST verdict line of every result was dropped too, because the verdict token still carried
    its trailing JSON punctuation (`ok"}`).
  - Together these lost half of the real verdict lines in a capture — 8 of 16 in the demo. Both are
    covered by a new regression test that also proves prose like `the latest greatest ... ok` is
    still refused.
- **Every file in `examples/` is new.** The published examples no longer derive from a private
  repository:
  - `examples/capture/` ships the seven session transcripts everything is measured from, with a
    `run.sh` that rebuilds every deterministic file in three commands. The reproduced JSON matches
    field for field; only `integrity.source_db_hash` and the id derived from it differ, because they
    hash the SQLite file and two ingests are not byte-identical. That caveat is stated on the page.
  - `examples/deterministic/session.report.{json,html,md}` is literally `bar report` output over that
    capture — not a styled copy of it.
  - `delivery-memo.{html,md}`, `management-read.{html,md}` and `diagnostic-review.{html,md}` replace
    the old boss-mode / interpreted-* files, with the briefs beside them as `brief.*.md`.
  - The project in the reports is `orbit`, a stand-in. Every count, rate and ranking is measured;
    the paths, commit subjects, prompt titles and sub-agent names are not real. Both halves are
    stated on the index, in the capture README, and in `process/05`.
  - The bundled web fonts and the shared `assets/report.{css,js}` are gone. Every example page is
    self-contained and uses the same system-font stack the renderer emits, so the examples show what
    a user actually gets rather than a better-dressed version of it.
- Figures updated to what the demo capture actually measures: 41 commits (not 47), 136 unpaired
  tool calls, nine capture channels rather than six, and a language mix of 270 Markdown / 77 Rust /
  61 TOML / 46 HTML / 16 JSON / 12 other.
- **Adopted the plate design system across every example report (2026-08-18, second pass).** Working
  from a proposed developer-commentary page supplied by Bradley, the visual direction for all five
  pages in `examples/` is now a single system: a dark "plate" title block with a blueprint rule grid,
  a numbered plate index in a sticky left rail with scroll-spy, Fraunces / IBM Plex Sans / IBM Plex
  Mono, and one signature artifact per report that carries its thesis — the 60-tick error strip on
  the diagnostic review, the session strip on the two executive-facing pages, the tool-call
  composition band on the technical report, and the four-report matrix on the index.
  - **Shared, not copy-pasted:** `assets/report.css` and `assets/report.js` now hold the system, so
    the five pages stay consistent and a fix lands once. `report.js` only draws numbers the page
    already states in text.
  - **Fonts are bundled, not linked.** The proposed page pulled three families from Google Fonts.
    This repo's own pitch is that nothing leaves your machine, so the latin subsets ship in
    `assets/fonts/` (335 KB, eight files) with full SIL Open Font License text and attribution in
    `assets/fonts/OFL.txt`. Every example page now makes **zero network requests**.
  - **One taxonomy everywhere.** The failure grouping is now six verdict classes — guardrail refusal
    17, detector artefact 10, reference drift 14, workflow and tooling 12, git and remote 5,
    unclassified 2 — replacing the earlier four-family split, and the Markdown reports were updated
    to match so the two formats cannot drift.
  - **Layer identity is explicit, not colour-coded.** Evidence pages carry a plate-blue accent,
    Commentary pages an iris one, and both carry a written badge in the top bar, so the distinction
    survives for a reader who cannot separate the two hues.
  - Every page was checked at 1280, 760 and 390 px in both themes with zero horizontal overflow and
    zero console errors, and with JavaScript fully disabled: nothing is hidden, every page keeps its
    full argument in prose and tables, and a `<noscript>` note says the drawings are what is missing.
- Fixed, while adopting that design: the proposed page's test-result matrix distributed its 29
  failures across a synthetic sequence and captioned it "in capture order". The store records how
  many result lines passed and failed, not the order they arrived in, so the grid now groups squares
  by outcome and says so. Also corrected against the record: a prompt-ledger link that said 69
  prompts (it is 68), three rework paths that had escaped the earlier redaction pass, and a
  `12 other tools` figure that read 121 rather than 218.
- Re-stepped one chart colour after validating the six-class palette: the neutral "detector artefact"
  class sat 10.8 dE from the guardrail class under normal vision — below the 15 dE floor, and those
  two classes are exactly the pair the report asks a reader to add together. It moved from `#546E82`
  to `#93A7B6`, and the unclassified class is now hatched rather than coloured, so it is told apart by
  texture and never by hue alone.
- Disclosed a cosmetic mismatch rather than editing captured data: `real-session.report.json` carries
  the store's own branding string, which still describes an "academic crimson palette" while the
  pages are presented in the plate palette. The JSON is left exactly as captured.
- Both dates the record carries are now stated on every report — the store's scope window
  (2026-07-31T18:57Z → 2026-08-13T23:43Z UTC) and the local-day session labels (2026-08-01 →
  2026-08-14) — rather than one being quietly preferred over the other.
- **Rebuilt every example report for publication (2026-08-18).** The four reports in `examples/`
  now read as designed, publishable documents rather than raw renders, and each ships in **both**
  HTML and Markdown:
  - **New:** `examples/interpreted/interpreted-executive.md` and `interpreted-engineering.md` — the
    Commentary layer previously had no Markdown form at all, only the deterministic briefs it was
    written from.
  - **Redesigned:** both interpreted HTML pages, `boss-mode.report.html`, and `examples/README.html`
    — a real masthead and hero, a figure band of headline numbers, charts with captions and a
    per-chart source line naming the exact `report.json` field, a collapsible table view under every
    chart, decision/watch callouts, and light/dark themes that follow the OS or the page's own
    toggle.
  - **New charts, all from already-published fields:** the 60 failures grouped into four root-cause
    families, the fourteen categories behind them, error density per tool (errors ÷ calls — a
    different ranking from the raw count), tool-call distribution, sub-agent delegation, rework
    concentration, file-type mix, test pass/fail, and a six-channel capture strip.
  - **Chart colour is now load-bearing and validated.** Evidence pages stay crimson and sans;
    Commentary pages are violet and serif, so the layer is legible at a glance. The status trio
    (working-as-intended / needs-attention / real defect) was validated for colour-vision
    separation and surface contrast in both themes, and every mark carries a direct label plus a
    2px surface gap so identity is never colour-alone.
  - **Rewritten prose in both layers** to explain what each number means and what it should *not*
    be read as — including that "60 errors" and "29 failing tests" both overstate risk, with the
    arithmetic shown rather than asserted.
  - `boss-mode.report.md` and `real-session.report.md` rewritten/enriched with the same figures as
    plain-text bar charts, plus a derived errors-per-call column on the failures table.
  - Screenshots `examples/interpreted/interpreted-executive.png` and
    `examples/deterministic/real-session.report.png` regenerated from the new pages (the README
    alt text was updated to match what the image now shows).
- Fixed, in `examples/deterministic/real-session.report.html`: six lines of template text leaked
  literal Markdown backticks into the HTML (e.g. `` `bar-observatory/README.md` `` rendered as
  backticks, not code); and a "not recorded" value rendered in large crimson display type, the same
  treatment as a real measurement — absence now renders small and grey, per this project's own
  palette rule. Three stale unredacted scratch paths in `interpreted-engineering.html` were aligned
  to the redacted paths already used in `report.json` and the deterministic pages.
- Regenerated `checksums/SHA256SUMS.txt`: 61 entries, up from 57. Four files were missing from the
  manifest entirely (`examples/deterministic/boss-mode.report.{html,md}` plus the two new
  interpreted `.md` files), and one entry — `.claude-plugin/plugin.json` — was stale against the
  committed file. Both were pre-existing gaps, found by regenerating rather than trusting the
  manifest; `sha256sum -c` now verifies clean across the whole folder.
- Added the Claude Code plugin marketplace manifest (`.claude-plugin/marketplace.json`) so
  `/plugin marketplace add bar181/bar-observatory` works as documented.
- Added a fifth slash command, `/bar-init`, for project setup (previously only report-generation
  commands were covered).
- Added `index.html`, a self-contained landing page.
- Rewrote README.md and wiki/human/README.md for a broader, less technical audience, and
  lightly glossed unexplained jargon throughout process/00-06.md.
- Fixed `bar-observatory`'s generated report text: MCP-failure remediation guidance no longer
  cites an internal-only path/decision-record (`bar-mcp` bumped to 0.1.1 for this fix); corrected
  a stale error count (25, not 31) in documentation quoting the shipped example report.
- Fixed a real plugin-load bug: `.claude-plugin/plugin.json` declared `hooks: "./hooks/hooks.json"`
  explicitly, but Claude Code already auto-loads `hooks/hooks.json` by convention — the explicit
  declaration caused a "duplicate hooks file" error and the plugin failed to load entirely.
  Confirmed via a real `plugin marketplace add` / `plugin install` / `plugin uninstall` cycle
  before and after the fix.
- Added the four wiki pages the README's own docs map referenced but didn't yet contain:
  `wiki/comparison.md`, `wiki/enterprise.md`, `wiki/architecture.md`, and
  `wiki/documentation-layers.html` (adapted from a draft, with its Google Fonts CDN dependency
  removed and its "generated" claim corrected to honestly state the three documentation layers —
  human, AI, AISP — are hand-maintained today, not generated).
- Reconciled a set of session-example figures that had no traceable source (61/62 tasks, 19/24
  errors, 56 commits, 121/259 edits, 13 sleep cycles) against the real numbers in the shipped
  `examples/deterministic/real-session.report.json` (27 tasks, 25 errors, 603/293/98 Bash/Edit/Read
  calls, 157-of-293 edits concentrated in one file). The commit-count and sleep-cycle claims were
  dropped entirely — neither is a channel this report captures today.
- Scrubbed an internal-only MCP tool name (`search_ruvnet` / `ruvnet-brain`) from illustrative
  prose in `index.html` and `process/06-use-cases.md`, matching the generic phrasing README.md
  already used. The raw generated example reports in `examples/deterministic/` were left
  untouched — they're byte-for-byte captured evidence, not narrative copy.
- Added an "About the author" and an "Acknowledgements" section to README.md.
- Regenerated `checksums/SHA256SUMS.txt` to match the above.
- Added a kicker line ("Don't ask the agent what happened. Check the record.") and a "Zero-SDK,
  zero-clone" section to README.md, naming both claims explicitly.
- Corrected README's MCP section: verified against the live `bar-mcp` schema which 5 of 12 tools
  are actually cross-run (`list_runs`, `compare_conditions`, `search_observations`,
  `list_findings`, `recall_context`) rather than assuming a list from external feedback, which
  turned out to include two tools (`get_convergence`, `get_completeness`) that require a single
  `db` and are not cross-run.
- Added the "0 failures vs `not_observed`" contrast as a standalone visual block, and a "Two ways
  to generate, two audiences" table to README.md — correcting, mid-edit, a first draft that
  incorrectly implied `bar report` takes an `--audience` flag (only `bar interpret` does).
- Added a real screenshot of `real-session.report.html` (captured via Playwright) under README's
  numbers table, saved to `examples/deterministic/real-session.report.png`.
- Added AgentOps to the comparison table's named examples (README.md + `wiki/comparison.md`).
- Added `llms.txt`, a curated index for LLM crawlers.
- Added a live human/AI/AISP tab switcher to `wiki/documentation-layers.html`, with two worked
  examples (`bar init`, and the `not_observed` rule) shown in all three registers — verified
  working via a real browser click, not just code review.
- Added `wiki/report-guide.html`, a new section-by-section annotated walkthrough of a real report
  (stat bar, executive summary, key findings, recommendations, task ledger, tool usage, sub-agent
  dispatches, rework hotspots, validation/flaky signals, unbuilt-feature disclosure, capture
  honesty, integrity hashes), every quoted value verified verbatim against
  `examples/deterministic/real-session.report.json`.
- Rebuilt `wiki/documentation-layers.html`'s register tab switcher as CSS-only (radio inputs +
  the general sibling combinator), removing its JavaScript dependency entirely. The prior
  button+`<script>` version didn't work in a static preview pane; the new one was verified
  working with JavaScript fully disabled in a real browser context, including keyboard/label
  clicks and correct div nesting (52 open / 52 close, checked programmatically).
- Added a "What data actually gets stored" section to `wiki/enterprise.md` — an explicit
  inventory of what the local capture database holds (full message text, the agent's `thinking`
  blocks, recovered file versions, tool I/O, raw process logs) versus the narrow, specific set of
  fields redacted automatically on write (a small list of secret-key prefixes, email-shaped
  tokens, absolute home paths) versus what only the separate, explicit `bar-sanitize` step
  removes. Sourced from the real `bar-store`/`bar-sanitize` schema and code, not restated from
  existing marketing copy. Cross-linked from README's "send my code anywhere" FAQ answer.
- Added `wiki/master-guide.html`, adapted from a Bradley-provided draft: Google Fonts CDN removed,
  a stale reverted "31 failures" figure corrected back to 25, the `search_ruvnet` internal tool
  name genericized, a fabricated `bradley.academy` URL replaced with the verified LinkedIn link,
  the unpublished `aisp-validator` CLI reference labeled as illustrative rather than real, and its
  three-way Plain/Advanced/AISP mode switch rebuilt as CSS-only (radio inputs, no JavaScript) —
  the prior JS version didn't work in a static preview pane. Verified with JavaScript fully
  disabled in a real browser context across all three modes.
- Added two new persona guides: `wiki/guide-executive.html`, `wiki/guide-junior-dev.html` —
  blog-style pages targeting different readers (client/manager, junior developer), each
  grounded in real product facts and figures already verified elsewhere in this repo.
- **Discovered and disclosed a real schema/output mismatch**: `schemas/report.schema.json` and
  `schemas/interpretation.schema.json` describe an earlier report/interpretation shape than what
  the current `bar report`/`bar interpret` commands actually produce (confirmed with the real
  JSON Schema validator against `examples/deterministic/real-session.report.json` — invalid,
  missing required fields). Every "validates against a versioned JSON Schema" claim in
  README.md, index.html, wiki/architecture.md, wiki/master-guide.html, process/05-sample-report.md,
  RUN.md, and llms.txt was reworded to disclose this gap honestly rather than repeat an inaccurate
  claim. The schema itself needs regenerating in the private working repo — out of scope for this
  public-docs pass.
- **Reorganized examples/** from 12 files (a real capture, a seeded fixture, and a hand-authored
  mock, mixed together with no explanation of which was which) down to 8, one example per report
  type: the real deterministic capture (kept, since it's cited throughout README/wiki with
  verified real numbers), and two newly-generated, genuinely real interpreted examples
  (executive + engineering audience) produced by actually running `bar interpret` against a live
  capture and writing the interpreted prose from the resulting brief, replacing an old mock built
  against the same stale interpretation schema. Deleted the seeded fixture and the stale mock.
  Added `examples/README.md` and `examples/README.html` explaining the new structure and both
  schema gaps plainly.
- Fixed `index.html`'s Plain/Advanced reading-mode switch: the same button+JavaScript pattern as
  `wiki/documentation-layers.html` and `wiki/master-guide.html` had, confirmed not to work in a
  static preview pane. Rebuilt as CSS-only (radio inputs, no `<script>`), verified with
  JavaScript fully disabled in a real browser context. This was the site's own front page and had
  not been caught in the earlier two fixes.
- **Found and fixed a real fabricated-figures bug in `wiki/master-guide.html`**, via an
  independent 5-persona review swarm: its "Outcomes" stat block still asserted "56 commit
  confirmations" and "13 needless sleep / wait cycles" as real captured figures — the exact
  untraceable numbers already reconciled everywhere else in this repo, missed in this one file
  during the earlier pass. Corrected to the same real, verified figures used throughout (27
  tasks/12 completed, 25 errors, 603 Bash calls, 157-of-293 edits in one file), with the
  commit-count and sleep-cycle claims dropped and disclosed as uncaptured channels.
- Fixed `wiki/guide-executive.html` and `wiki/guide-junior-dev.html` being completely orphaned
  (zero inbound links from README.md or index.html, also caught by the review swarm) — added
  links from README's "Who is this for?" section, the Repository map table, and index.html's
  footer.
- **Reorganized `wiki/` into four flat subfolders**, per the review swarm's recommendation plus
  two follow-up refinements from Bradley: `wiki/human-md/` (the setup tutorial, comparison,
  enterprise, architecture — reference pages) and `wiki/human-html/` (documentation-layers,
  report-guide, and a `guides/` subfolder for guide-executive and guide-junior-dev — blog-style
  deep dives), alongside the unchanged `wiki/agent/` and `wiki/aisp/`. (Deliberately flat —
  `human-md/`/`human-html/` as direct siblings of `agent/`/`aisp/`, not nested under a shared
  `human/` parent.) Added `wiki/README.md`, a short nav-only page by reader.
- **Revived `wiki/master-guide.html` as `wiki/README.html`** rather than leaving it archived: it
  had been cut for being ~90% duplicated content with zero inbound links, but as the designated
  single-page companion to the new `wiki/README.md` nav page — a genuine "read everything in one
  page, with a Human/Advanced/AISP depth switch" option — the same content earns a real, findable
  role instead of being an orphaned duplicate. Re-verified its CSS-only tab switcher still works
  with JavaScript disabled at the new path, and added a visible one-line hint plus a hover title
  near the mode switch after Bradley found the Plain/Advanced difference non-obvious (the hero
  and receipt example are intentionally identical in both modes — only sections further down the
  page toggle, confirmed with real visible-element counts: 0 of 7 advanced-only elements visible
  in Plain mode, 7 of 7 in Advanced).
- Fixed every relative link inside every moved file for its new depth, plus every external
  cross-reference site-wide (README.md, index.html, RUN.md, llms.txt, examples/README.{md,html},
  process/04-optional-modules.md, wiki/agent/AI-CONTEXT.md, wiki/aisp/HUB.aisp's WIKI= registry)
  — verified zero dead links repo-wide after every move.
- Added images and short real-content excerpts to README.md, per Bradley's request. New
  `assets/` folder (separate from `examples/`, which stays strictly report-output examples) holds
  `site-hero.png` — a real screenshot of index.html's hero (the receipt visual, captured at 2x
  scale), now the lead image at the top of the README for visual impact. Added a real `report.md`
  excerpt (the actual Key Findings section, verbatim) and a real `report.json` excerpt (a rework
  event plus a `not_recorded` capture channel, both copied from the shipped example) to the
  "What does a report contain" section, so the three format claims (JSON/HTML/MD) each have a
  concrete example, not just a description. Added a second screenshot —
  `examples/interpreted/interpreted-executive.png` — to the "Two ways to generate" section, which
  previously had no image despite describing the interpreted layer.
- **Verified real GitHub links for every Acknowledgements entry** (via the GitHub API, not
  guessed): ruvnet → [github.com/ruvnet](https://github.com/ruvnet) (Reuven Cohen, confirmed
  founder of the Agentics Foundation via web search); QE Fleet →
  [github.com/proffesor-for-testing/agentic-qe](https://github.com/proffesor-for-testing/agentic-qe)
  (confirmed "created by Dragan Spiridonov" in the repo's own description); ruvnet-brain →
  [github.com/stuinfla/ruvnet-brain](https://github.com/stuinfla/ruvnet-brain) (owner confirmed
  as Stuart Kerr); AISP → [github.com/bar181/aisp-open-core](https://github.com/bar181/aisp-open-core)
  (confirmed real via the GitHub API, owned by bar181).
- Enriched "About the author" with Bradley's background (25 years in data science and software
  engineering, agentic engineer and architect specializing in near-deterministic AI and applied
  research, teaches agentics) and a positioning paragraph: this repository is the open-core
  edition of BAR Observatory, designed for immediate use with guides explaining what the
  resulting data means.
- **Restructured the Quickstart section**: the Claude Code plugin is now the lead path (three
  plugin commands presented first, prominently, right after the pitch), with the direct
  `cargo`/CLI path relabeled "Advanced: the CLI directly, no plugin" and moved second — matching
  the standing "the front door is the Claude Code plugin, not crates" positioning. Fixed one
  internal anchor link that broke when the old "Or: install the Claude Code plugin" subheading
  was removed in the restructure.
- Added an "open-core edition" clause to README's License section (no feature gate, no separate
  paid tier; commercial/support inquiries go to the author directly) and a new "Recommended
  reading" section organizing the HTML wiki by audience — executive/client/team-lead, advanced
  agentic engineer (with an explicit steer to hand swarms the AI/AISP registers instead of the
  human pages), and software developer — plus a short outline of the Markdown wiki.
- Verified, hands-on, that the Claude Code plugin installs end-to-end from a local folder path
  with zero network dependency (`claude plugin marketplace add <path>` → `plugin install` → all
  5 commands/21 hooks/MCP server load; uninstall is clean). Added that local-path fallback to
  README.md's and RUN.md's Quickstart, which previously documented only the GitHub-reference
  form.
- **Closed five findings from a self-audit of every public-facing file**: (1) `SECURITY.md`
  overstated redaction as "PII is scrubbed on write"; reworded to match
  `wiki/human-md/enterprise.md`'s accurate, narrower scope (a specific prefix/pattern list, not a
  general PII/secrets scanner). (2) `wiki/human-md/README.md`'s "How to read the report" list
  presented two undelivered detectors (`human_ai_recovery`, `micro_observations`) as shipped
  sections; moved them out of the numbered list into an explicit "not built yet" disclosure,
  matching the product's own `not_observed` discipline. (3) Cut every unverifiable AISP figure
  (`0.150`/`0.425` ambiguity score, `10,469` formal atoms, `72/72` cross-vendor pilot) from
  `wiki/human-html/documentation-layers.html` and `wiki/README.html` — both pages previously
  badged these as "Measured" with no reader-reachable source; replaced with one unbadged line
  pointing to `aisp-open-core`, no figures reproduced on either page. (4) `examples/README.html`'s
  file count ("eight") was stale against the real nine-file folder and its table was missing a
  row for `interpreted-executive.png`; fixed both and synced with `examples/README.md`.
  (5) Renamed `examples/interpreted/interpreted-developer.html` → `interpreted-engineering.html`
  to match the `--audience engineering` flag/brief name it was always describing; updated both
  inbound references.
- **Removed every reference to the private working repo's literal filesystem path**
  (`bar-obs-private/...`) and internal-only planning-doc paths (`human-specs/...`) from
  public-facing files: `run.sh`'s hardcoded `../bar-obs-private/crates` build fallback (removed
  entirely — PATH resolution or `cargo install` only, matching the "zero-clone" pitch),
  `scripts/public-export.sh`'s generated `CRATES.md` header, `CRATES.md` and
  `provenance/PROVENANCE.json`'s own generation notes, `schemas/report.schema.json`'s
  reserved-fields description, and internal review-note comments in
  `config/branding.default.toml` and `config/bar-observatory.default.toml`. The underlying facts
  those comments stated (branding-table duplication with no precedence rule; the `TBD` fields
  being genuinely undecided, not placeholders) are preserved — only the private path citations
  were removed. Verified repo-wide afterward: zero remaining hits for `bar-obs-private` or
  `human-specs` outside the gitignored `_run/` folder.
- Regenerated `checksums/SHA256SUMS.txt` for all of the above (15 of 57 entries changed).
