**Developer Guide · Commentary — written by an LLM from fixed facts**

# Sixty errors. Twenty-seven of them never were failures.

> A root-cause read of seven real Claude Code sessions: what actually went wrong, what only looked
> like it did, where the rework concentrated, and the four things worth changing before the next run.

| | |
|---|---|
| **Audience** | Engineering / debug |
| **Window** | 2026-05-04 → 2026-05-17 (session labels; scope window 2026-05-04T19:07Z → 2026-05-18T06:06Z UTC) |
| **Volume** | 9,132 turns · 3,171 tool calls |
| **Evidence** | [`session.report.md`](../deterministic/session.report.md) · [`.html`](../deterministic/session.report.html) · [`.json`](../deterministic/session.report.json) |
| **Report id** | `barobs-94c4ff164bd8` |
| **Ingest mode** | Transcript-only, retroactive |

| Tool calls | Error results | Sub-agent dispatches | Rework hotspots | Test results | Tokens & cost |
|---:|---:|---:|---:|---:|---:|
| **3,171** | **60** | **40** | **96** | **373** | *not recorded* |
| across 17 tools | 1.9% of calls | 8 distinct roles | 482 repeat edits | 344 pass / 29 fail | no live request channel |

### What you are reading

This page is **commentary** on
[`session.report.html`](../deterministic/session.report.html) — grouping, causal reasoning
and recommendations, kept deliberately separate from the deterministic evidence it is built on. The
60-item taxonomy below was produced by pattern-matching the real excerpt text of **all 60** error rows
in that page's appendix. Not a sample; not invented.

---

**Contents**

01. [What this run was, in one paragraph](#what-this-run-was-in-one-paragraph)
02. [All 60 failures, sorted by what caused them](#all-60-failures-sorted-by-what-caused-them)
03. [Which tool is actually the problem](#which-tool-is-actually-the-problem)
04. [Who the 40 dispatches went to](#who-the-40-dispatches-went-to)
05. [Four things the data says](#four-things-the-data-says)
06. [Rework concentration — top 15 of 96 files](#rework-concentration--top-15-of-96-files)
07. [Validation, and the three tests that changed their answer](#validation-and-the-three-tests-that-changed-their-answer)
08. [What this capture could not see](#what-this-capture-could-not-see)
09. [Three experiments, each with a falsifiable bar](#three-experiments-each-with-a-falsifiable-bar)
10. [Four things to do differently next session](#four-things-to-do-differently-next-session)
11. [How much to trust each claim above](#how-much-to-trust-each-claim-above)

## What this run was, in one paragraph

**Release posture: Clear.** 40 of 40 tasks completed, 344 of 373 captured test result lines
passed, and the last captured line was a pass. No captured error points at the shipped crate
logic. What remains is reference hygiene (14 of 60 errors) and three specific tests to re-check
— not architecture.

| Reader | The one thing to take away |
|---|---|
| **If you sign off** | The risk number is smaller than it looks. A raw feed of 60 errors overstates exposure by roughly half — ask for the guardrail-refusal/detector-artefact split before reacting to a count. Today the tool can't produce that split on its own; that's the one real product gap this review found. |
| **If you write the code** | Two habits remove a sixth of the noise: re-read a file immediately before editing it late in a long session, and confirm a plugin agent or skill is available before dispatching it. Those two habits account for 10 of the 60 captured errors on their own. |
| **If you design the report** | Guardrail refusals and genuine failures render identically today. One tag on the data model turns a scary total into a three-part story that reads correctly at a glance, with no extra chart. |

For the reader who stops here, or the lead who needs the summary before the standup.

> ### 27 of 60 were not failures
> **The headline error count is misleading in the safe direction.** 17 of 60 errors are the permission
> system refusing destructive (`rm -rf`) or credential-exposing commands. A further 10 are detector
> artefacts — CI text and informational exit codes that never were this session's failures. Of the 33
> that remain, 14 are reference drift that a reference update fixes, 12 are workflow or throwaway-script
> issues, 5 are git and remote, and 2 stay unclassified.

> ### 33% Skill failure rate
> **Raw counts point at `Bash`; density points somewhere else.** `Bash` owns 45 of 60 errors — but it
> also owns 1,706 of 3,171 calls, a 2.6% failure rate. Per call, `Skill` (2 of 6) and `Agent` (5 of
> 40) failed far harder, and both for the same reason: plugin-provided capabilities referenced before
> they were installed.

> ### 5× the next file
> **Rework is concentrated, not diffuse.** One file took 77 of 482 repeat edits — five times the
> runner-up and 16% of all rework in the window. That is concentration *across days and sessions*,
> which reads differently from a single sitting spent wrestling one file.

---

## All 60 failures, sorted by what caused them

Every error row was matched against a fixed pattern set — the method is published below so the
grouping is checkable rather than asserted.

```
60 error results in six verdict classes

Guardrail refusal            ████████████████████████████  17   28.3%   working as intended
Detector artefact            ████████████████              10   16.7%   not a real error
Reference drift              ███████████████████████       14   23.3%   fix the reference or the setup
Workflow and tooling         ████████████████████          12   20.0%   real, low severity
Git and remote               ████████                       5    8.3%   mostly benign
Unclassified                 ███                            2    3.3%   manual review
```

```
The fourteen categories behind those six classes

Destructive command blocked           ██████████████████████████  10   guardrail refusal
Stale path after repo reorg           ██████████████████           7   reference drift
CI status text captured mid-command   ████████████████             6   detector artefact
Edit precondition                     █████████████                5   workflow and tooling
Git / GitHub push, fetch or ref       █████████████                5   git and remote
Ad-hoc script bug                     █████████████                5   workflow and tooling
Credential-scan blocked               ██████████                   4   guardrail refusal
Informational exit codes              ██████████                   4   detector artefact
Sleep / timing policy block           ████████                     3   guardrail refusal
Sub-agent not installed               ████████                     3   reference drift
Skill not installed                   █████                        2   reference drift
Hook not wired                        █████                        2   reference drift
Malformed tool input                  █████                        2   workflow and tooling
Low-confidence bucket                 █████                        2   unclassified
```

| Category | Count | Verdict class | Disposition |
|---|---:|---|---|
| Guardrail: destructive command blocked (`rm -rf`/`rm -f`) | 10 | Guardrail refusal | No action |
| Guardrail: credential scan blocked (grep TOKEN/KEY/.env) | 4 | Guardrail refusal | No action |
| Guardrail: timing policy or other command blocked | 3 | Guardrail refusal | No action |
| CI status text captured mid-command | 6 | Detector artefact | Detector gap, not a failure |
| Informational exit codes from search tooling | 4 | Detector artefact | Detector gap, not a failure |
| Stale path after in-flight repo reorganisation | 7 | Reference drift | Update the reference |
| Environment gap: plugin sub-agent not installed | 3 | Reference drift | Install it, or stop referencing it |
| Environment gap: plugin skill not installed | 2 | Reference drift | Install it, or stop referencing it |
| Environment gap: worktree hook not wired | 2 | Reference drift | Known and documented |
| Tool precondition: edit before read, or string not found | 5 | Workflow and tooling | Prompting and workflow fix |
| Ad-hoc script or tooling bug (Python, Node) | 5 | Workflow and tooling | Real bugs in throwaway scripts |
| Tool input malformed (JSON parse) | 2 | Workflow and tooling | Ad-hoc script fragility |
| Git or GitHub: push, fetch, or ref issue | 5 | Git and remote | 3 real, 2 misattributed successes |
| Other, low-confidence bucket | 2 | Unclassified | Manual review recommended |
| **Total** | **60** | | |

*Source: all 60 rows of `bar query <db> errors --limit 0`, reproduced in the evidence appendix.
Method: each row's excerpt matched against a fixed pattern set; ambiguous rows go to the
low-confidence bucket rather than a best guess.*

**Read it as:** the verdict split is the number that belongs in a status update. "60 errors" is
technically true and practically misleading — 27 of the 60 never were failures, and of the 33 that
remain, none describes a logic defect in shipped code.

---

## Which tool is actually the problem

Ranking tools by error count answers "where do errors come from". Ranking by errors *per call* answers
"which tool is unreliable". They give different answers here.

```
Errors per 100 calls, by tool

Skill    ██████████████████████████  33.3%   (2 errors in 6 calls)
Agent    ██████████                  12.5%   (5 errors in 40 calls)
Bash     ██                           2.6%   (45 errors in 1,706 calls)
Write    █                            1.0%   (1 error in 97 calls)
Edit     █                            0.6%   (3 errors in 496 calls)
Read     █                            0.5%   (2 errors in 410 calls)
```

| Tool | Calls | Errors | Rate | Rank by count | Rank by rate |
|---|---:|---:|---:|---:|---:|
| `Bash` | 1,706 | 45 | 2.6% | 1 | 3 |
| `Agent` | 40 | 5 | 12.5% | 2 | 2 |
| `Edit` | 496 | 3 | 0.6% | 3 | 5 |
| `Read` | 410 | 2 | 0.5% | 4= | 6 |
| `Skill` | 6 | 2 | 33.3% | 4= | 1 |
| `Write` | 97 | 1 | 1.0% | 6 | 4 |
| `unknown` | — | 2 | — | — | — |

*Source: `session.report.json` → `summary.tools` (calls) ÷ `failures.items` (errors).
Caveat: `Skill`'s 33% comes off a base of six calls — directionally real, statistically thin.*

**Read it as:** `Bash` dominates the raw count purely because it dominates the workload. The two tools
that failed *disproportionately* are the two that reach for plugin-provided capabilities — the same
root cause, showing up twice.

```
Where the 3,171 calls went

Bash            ██████████████████████████  1,706   53.8%
Edit            ████████                      496   15.6%
Read            ██████                        410   12.9%
TaskUpdate      ███                           209    6.6%
TaskCreate      ██                            132    4.2%
Write           █                              97    3.1%
Agent           █                              40    1.3%
10 other tools  █                              81    2.6%
```

Read-and-edit traffic (`Read` + `Edit` + `Write`) is 32% of all calls; task bookkeeping (`TaskCreate`
+ `TaskUpdate`) is another 11%. That is the shape of a documentation-and-release fortnight, and it
matches the file-type breakdown on the executive page.

---

## Who the 40 dispatches went to

```
Sub-agent dispatches by role

general-purpose            ██████████████████████████  17   42.5%
reviewer *                 ███████████████             10   25.0%
docs-researcher          ████████                     5   12.5%
requirements-validator* █████                        3    7.5%
docs-curator           ███                          2    5.0%
release-verifier *     ██                           1    2.5%
skeptic-reviewer *     ██                           1    2.5%
unspecified                ██                           1    2.5%

* = verification role, not production: 15 of 40 dispatches (37.5%)
```

*Source: `session.report.json` → `summary.agents`.*

**Read it as:** a quarter of every delegation went to `reviewer` alone. The single `unspecified` row is
a real, disclosed gap — one `Agent` call carried no resolvable `subagent_type`. Most likely a
plugin-namespaced agent name the detector does not parse yet; worth confirming rather than assuming it
was nothing.

**Skills invoked.** Five distinct skills fired six times: `review` (2×), then `release-protocol`,
`loop`, `quality-court` and `quality-assessment` once each. Two of those six calls errored — the quality
pair — which is the entire story behind the 33% `Skill` failure rate above.

---

## Four things the data says

Each is labelled by what kind of claim it is — a summary of facts, or an inference on top of them —
and how confident that claim is.

### Nearly a third of all "errors" are the safety system working
*fact summary · high confidence*

17 of 60 (28%) are permission refusals on destructive (`rm -rf`) or credential-exposing (`grep` for
`TOKEN`/`KEY`/`.env`) commands. Every one is the guardrail doing precisely its job. Counting them at
face value in a raw "60 errors" headline overstates risk to anyone who does not open the detail.

> **Recommendation — product gap, not a reporting nit:** the deterministic failure section should carry
> a `kind` that distinguishes guardrail refusals from genuine execution failures. Today both render as
> `kind: tool`, which is what makes the headline number misread in the first place.

### Plugin agents and skills were called before anything confirmed they existed
*fact summary · high confidence*

`requirements-validator` (agent, 3×) and `quality-assessment` / `quality-court` (skills, 2×) all
failed with "not found". The plugin providing them was not active in at least one of the three
sessions that reached for them — sequence positions 438, 685 and 804 for the agent; 441 and 845 for
the skills. This is the highest-yield fix on the page: five failures, one cause, and the error message
itself already lists what *was* available.

> **Recommendation:** before dispatching a plugin-provided agent or skill, confirm it is in the current
> session's available list. One check per session removes an entire failure class.

### Five Edit failures are a context-freshness problem, not a logic bug
*fact summary · medium confidence*

Two "file has not been read yet" plus three "string to replace not found". Both are the Edit tool's own
precondition guard catching a call made with stale or absent file context — exactly the failure mode
the guard exists to prevent, at the cost of a retry. The three string mismatches line up with edits
landing well after the matching read.

> **Recommendation:** when a file was read early in a long session and edited much later, re-read
> immediately before the edit rather than trusting a read from many turns ago.

### Two "git errors" are successful commits with the excerpt on the wrong line
*inference · medium confidence*

Two of the five git/GitHub rows are real remote-permission problems (push or fetch denied). Another two
are **successful** commit messages showing exit code 128 — almost certainly from a *later* command in
the same chain, with the captured excerpt landing on the commit line rather than the step that actually
failed.

> **Recommendation:** never root-cause a multi-command `Bash` chain from a 160-character excerpt. Pull
> the full sequence position with `bar query` first.

*Uncertainty, stated: this reading is based on excerpt content, not the full untruncated tool result.
Flagged as inference, not confirmed fact.*

---

## Rework concentration — top 15 of 96 files

482 repeat edits across 96 files. The distribution is the finding, not the total.

```
Files by repeat-edit count

orbit/README.md                             ██████████████████████████   77
orbit/index.html                            ███████                      22
orbit/docs/guide/README.md                  █████                        16
orbit/docs/manifest.json                    █████                        16
orbit/CHANGELOG.md                          █████                        15
orbit/docs/guide/handbook.html              █████                        15
.gitignore                                  ████                         12
specs/10-capabilities-review.md             ███                           9
specs/13-pre-release-checklist.md           ███                           9
orbit/RUN.md                                ███                           9
orbit/docs/layers.html                      ███                           9
review/verify/src/main.rs †                 ██                            7
NOTES.md                                    ██                            7
review/pr-a/crates/orbit/src/detectors.rs†  ██                            6
AGENTS.md                                   ██                            6

```

*Source: `session.report.json` → `rework.hotspots` (96 files, 482 edits; top 15 shown). Full
ranked list with language, location and tier columns: the evidence page's Rework section.*

**Read it as:** the 77-to-22 gap between first and second place is five-fold, and it accumulated
*across days*, not inside one sitting — a materially different signal from a single session spent
fighting one file.

---

## Validation, and the three tests that changed their answer

373 recorded `test result:` lines: 344 passed, 29 failed (92.2% / 7.8%), and the last line of the
window was a pass. One `cargo test --workspace` emits several result-lines — one per crate — so this
counts lines, not invocations. On multi-day, multi-crate iterative work that is normal; it is evidence
the completion claims are backed by something measured, not a quality grade.

| Test | Passes | Fails |
|---|---:|---:|
| `round_trips_losslessly` | 5 | 3 |
| `query_failures_are_disclosed_not_silent` | 3 | 2 |
| `committed_hooks_match_generator` | 2 | 1 |

*Source: `session.report.json` → `flaky`, measured from real `test … ok` / `FAILED` lines.*

**What to change:** all three are the shape that rewards a targeted flaky-test investigation — fixture
ordering, worktree state bleeding between test-file edits, or a genuine intermittent regression —
rather than being waved off. Three names out of everything that ran is a small, specific, checkable
list.

---

## What this capture could not see

Measured, not estimated — and never rendered as a zero.

| Channel | Recorded | Note |
|---|---|---|
| **Transcripts** | **9,132 turns** | `partial` — gap detected and measured |
| Hooks | not recorded | no hook recorder wired during these sessions |
| Events | not recorded | no log/metric rows in this store |
| Spans | not recorded | no OTLP exporter running |
| Requests | not recorded | no request proxy; hence no token counts |
| File history | not recorded | no file-history rows in this store |
| Plan docs | not observed | detector not built yet |
| Raw logs | not observed | detector not built yet |
| Provider cost | not recorded | subscription auth exposes no per-token USD |

This was a retroactive, transcript-only ingest — `bar ingest <db> <transcript.jsonl>` after the fact,
not a live-wired capture. That is a mode limitation, disclosed, and the reason cost, hook and span rows
read *not recorded* rather than showing a number.

Inside the one active channel, the gaps were measured directly rather than assumed: of 9,132 turns,
**629** reference a parent turn absent from the store and **136** `tool_use`/`tool_result` pairs are
unmatched. Those are structural holes in the raw JSONL rather than defects in the reader — but they are
real, and they are why no count on this page should be treated as exhaustive to the last unit.

Two detector categories remain `not_observed` in the underlying deterministic report:
`human_ai_recovery` classification, and micro-observation / silent-signal extraction. This commentary
does not paper over either gap with invented findings.

---

## Three experiments, each with a falsifiable bar

Written as RED → GREEN → OPTIMIZE so each one can fail honestly rather than be declared done.

### Priority 1 — distinguish guardrail refusals from real tool failures in the deterministic layer

- **RED** — add a fixture transcript mixing guardrail-denied and genuinely-failing tool calls; confirm
  today's detector renders them identically.
- **GREEN** — tag guardrail denials with a distinct `kind` (e.g. `policy_denied`), separate from `tool`
  and `mcp`.
- **OPTIMIZE** — surface "N of M errors were policy refusals, not failures" in the report summary once
  the tag exists.

*Why first: it is the single change that stops the headline error number from misleading every future
reader of every future report — 28% of this window's errors are affected.*

### Priority 2 — confirm plugin agent and skill availability before dispatch

- **RED** — reproduce the five "not found" events on a session where the plugin providing them is not
  installed.
- **GREEN** — add a pre-dispatch availability check, or a documented convention: list available agents
  and skills once per session before relying on plugin-provided ones.
- **OPTIMIZE** — track whether this failure class drops to zero across the next five sessions once the
  convention is followed.

*Expected yield: five of sixty failures, and both of the two worst per-call error rates on this page.*

### Priority 3 — investigate the three tests that changed verdict

- **RED** — re-run `round_trips_losslessly`, `query_failures_are_disclosed_not_silent`
  and `committed_hooks_match_generator` in isolation versus full-suite, to test for order
  dependence.
- **GREEN** — fix the root cause once identified: shared fixture state, timing, or a real intermittent
  regression.
- **OPTIMIZE** — add each to a standing flaky-test watchlist so a future report can show the trend
  rather than a point-in-time count.

---

## Four things to do differently next session

1. **Check availability before dispatching a plugin-provided agent or skill.** Do not assume it is
   installed — the session's own available list is one call away.
   *Would have prevented 5 of 60 failures.*
2. **Re-read a file immediately before editing it** when the original read happened many turns earlier
   in a long session. Stale in-context file state is the mechanism, not a logic bug.
   *Accounts for at least 3 of the 5 Edit-precondition failures.*
3. **After any path reorganisation, grep for the old path across scripts and docs in the same pass.**
   This window moved a documentation tree and left references behind.
   *7 of 60 failures are stale references to pre-move paths.*
4. **Pull the full transcript position before root-causing a `Bash` chain** from a report excerpt. A
   160-character excerpt can land on the wrong line of a multi-command chain.
   *At least 2 "git errors" in this window were successful commits.*

---

## How much to trust each claim above

| Confidence | What it covers |
|---|---|
| **High** — every count | All counts were pattern-matched against the real, complete excerpt text of all 60 error rows — not a sample, not an estimate. The same holds for tool, agent, skill, rework, validation and flaky figures, each of which resolves to a field in the machine contract. |
| **Medium** — causal claims | Statements about mechanism — "stale in-context file state", "the excerpt landed on the wrong line" — are reasonable inferences from the evidence, not confirmed by re-running the sessions. They are marked as inference where they appear. |
| **Not observed** — two detectors | `human_ai_recovery` and micro-observation extraction are not built. They read `not_observed` in the deterministic report, and nothing here fills that space with invented findings. |

---

**The evidence behind this page:**
[`session.report.md`](../deterministic/session.report.md) — session-by-session breakdown,
capture-channel diagram, the full 68-prompt ledger, and all 60 raw error rows in its appendix.
**The executive companion:** [`management-read.md`](management-read.md) — the same window
in value, cost and risk terms.
**The facts this page was written from:**
[`brief.engineering.md`](brief.engineering.md) — the exact brief handed to the
model, generated deterministically.

BAR Observatory — Base Agentic Reporter. Independent open-source project by Bradley Ross /
Bradley.Academy. No third-party marks are used and no endorsement is implied. Commentary layer, generated by `bar interpret --audience engineering`; the evidence layer it
reads is produced by `bar report` with no model in its path.
