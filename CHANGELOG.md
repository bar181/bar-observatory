# Changelog

All notable changes to BAR Observatory.

## [0.2.0] — published to crates.io, GitHub push still pending

**Breaking.** All 16 crates are live on crates.io as of 2026-08-17 (human go-ahead given, verified
via a real `cargo install --locked` from the published registry). Pushing this repository's own
commits to `github.com/bar181/bar-observatory` is a separate, still-pending human-approval gate —
crates.io publish and the GitHub push are two independent standing gates on this repo, not one. A
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
