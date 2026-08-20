**Boss Mode · Commentary — written by an LLM from fixed facts**

# Forty of forty. The number to look at is seventy-seven.

> Two weeks of agent-assisted delivery, captured in full and read back. Every tracked work item
> closed, the last test run was green, and the error rate is under two percent. The one figure that
> deserves a conversation is not a failure at all: one document absorbed more revisions than the next
> four combined.

| | |
|---|---|
| **Audience** | Executive / client |
| **Window** | 2026-05-04 → 2026-05-17 (session labels; scope window 2026-05-04T19:07Z → 2026-05-18T06:06Z UTC) |
| **Sessions** | 7, captured in full |
| **Evidence** | [`delivery-memo.md`](../deterministic/delivery-memo.md) · [`.html`](../deterministic/delivery-memo.html) |
| **Report id** | `barobs-14fd056be293` |
| **Reading time** | 4 minutes (60 seconds for the box below) |

| Work items closed | Commits landed | Human instructions | Error rate | Capture losses | Cost |
|---:|---:|---:|---:|---:|---:|
| **40 / 40** | **41** | **68** | **1.9%** | **0** | *not recorded* |
| every tracked task | real `git commit` results | prompts a person typed | 60 of 3,171 tool actions | nothing dropped in transit | the meter was never switched on |

### What you are reading

This page is **commentary**. An LLM wrote the prose; it did not produce a single number. Every figure
here was lifted from [the evidence memo](../deterministic/delivery-memo.md) and, behind that, from
[`session.report.json`](../deterministic/session.report.json) — a machine extraction with no
model anywhere in its path. Turn the model off and the evidence underneath is unchanged.

---

**Contents**

01. [If you read nothing else](#if-you-read-nothing-else)
02. [What the headline numbers actually mean](#what-the-headline-numbers-actually-mean)
03. [Who actually did the work](#who-actually-did-the-work)
04. [The concentration worth a conversation](#the-concentration-worth-a-conversation)
05. [Two decisions only you can close](#two-decisions-only-you-can-close)
06. [One item to not lose track of](#one-item-to-not-lose-track-of)
07. [What this report could not see](#what-this-report-could-not-see)
08. [How much to trust this page](#how-much-to-trust-this-page)

## If you read nothing else

Three numbers, in the order they matter, with what each one should and should not make you think.

> ### 40 of 40 closed
> **Delivery is not the story here — it's settled.** Every tracked work item in the two-week window
> closed, across seven separate sittings, and the last recorded test run of the window was green.
> Nothing on this page argues with that.

> ### 77 edits, one file
> **This is the thing to look at.** One document — the public README — absorbed 77 revisions, more
> than the next four most-edited files put together. It maps to a deliberate multi-reviewer pass, so
> it is almost certainly fine. But it is indistinguishable, from the outside, from a document nobody
> could get right. Decision 1 below is about closing that gap.

> ### 1.9% error rate
> **Low, and lower than it looks.** 60 errors across 3,171 tool actions — and 27 of the 60 never
> were failures. 17 are the safety system *refusing* a risky command; another 10 are text the
> detector caught mid-command that was never this session's failure at all.

---

## What the headline numbers actually mean

Three figures get quoted out of context more than any others in a report like this. Here is how each
one should be read.

### 1. "60 errors" overstates the risk by roughly half

An error count is a count of tool calls that came back unhappy. It bundles together two very
different things: a command that failed, and a command that was *stopped*. In this window, 17 of the
60 were stopped by the safety system, and another 10 were never this session's failures at all.

```
60 error results, sorted into six verdict classes

Guardrail refusal           ████████████████████████████  17   28.3%   working as intended
Never was an error          ████████████████              10   16.7%   detector artefact
Missing tool or stale path  ███████████████████████       14   23.3%   fix the reference
Real, low-severity defect   ████████████████████          12   20.0%   retry or a small bug
Git and remote              ████████                       5    8.3%   mostly benign
Unclassified                ███                            2    3.3%   manual review
                                                          ──
                                                          60
```

| Verdict class | Count | Share | What it is |
|---|---:|---:|---|
| Guardrail refusal | 17 | 28.3% | Destructive or credential-exposing commands blocked before running |
| Never was an error | 10 | 16.7% | CI text and informational exit codes the detector caught mid-command |
| Missing tool or stale path | 14 | 23.3% | A plugin not installed, or a file reference left behind by a repo move |
| Real, low-severity defect | 12 | 20.0% | Retryable tool preconditions and bugs in throwaway helper scripts |
| Git and remote | 5 | 8.3% | Two genuine permission problems; two are successful commits misread |
| Unclassified | 2 | 3.3% | Manual review recommended |
| **Total** | **60** | **100%** | |

*Source: 60 error rows in `session.report.json` → `failures`, grouped by the method published
in the [engineering companion](diagnostic-review.md).*

**Read it as:** 27 of the 60 never were failures — 17 refusals plus 10 detector artefacts, 45% of the
headline figure. Of the 33 that remain, 14 are fixed by updating a reference and none describes a
logic defect in shipped code.

### 2. "29 failing tests" is what iteration looks like, not a red flag

373 test-result lines were recorded across the two weeks. 344 passed. The temptation is to read 29
failures as 29 broken things. It isn't: those 373 lines are spread over dozens of runs during active
development, so a test that failed on Tuesday and passed on Thursday appears in both columns. The
figure that answers "is it working now?" is the *last* run in the window — and it was green.

```
373 recorded test results across the window

Passed              ██████████████████████████████████████████████  344   92.2%
Failed at some point ███                                             29    7.8%

Final run of the window: PASS
```

*Source: `session.report.json` → `validation.items[0]` — 373 runs, 344 passed, 29 failed,
`last_ok: true`.*

**Read it as:** a 92% pass rate with a clean finish. The one caveat worth keeping is in the watch
list: three individual tests changed their answer mid-window, and those are worth a look regardless
of the final green.

### 3. Two commits for every three instructions

68 human prompts produced 41 real commits. That ratio is the one people rarely quote and probably
should. Far fewer commits than prompts suggests work that stalls before it lands; far more suggests
changes going in without a pause for review. Two-to-three sits in the middle, and matches what the
session logs show: iterate, check, commit.

> **The delivery figure tells you the work finished. The commit-to-prompt ratio tells you *how* it
> finished — and that is the part that predicts the next two weeks.**

---

## Who actually did the work

Forty pieces of work were handed to specialist sub-agents. How that split fell is a direct read on
whether anything was checked.

```
40 delegated work items, by the role that received them

general-purpose            ██████████████████████████  17   42.5%
reviewer *                 ███████████████             10   25.0%
docs-researcher          ████████                     5   12.5%
requirements-validator* █████                        3    7.5%
docs-curator           ███                          2    5.0%
release-verifier *     ██                           1    2.5%
skeptic-reviewer *     ██                           1    2.5%
unspecified                ██                           1    2.5%

* = a role whose job is checking someone else's work: 15 of 40 dispatches (37.5%)
```

*Source: `session.report.json` → `summary.agents` (40 dispatches, 8 distinct roles).*

**Read it as:** more than a third of all delegated work — and a quarter on the reviewer role alone —
was somebody checking somebody else's output rather than producing new material. On a two-week push
with no human reading every line, that ratio is the single best available evidence that the work was
reviewed.

---

## The concentration worth a conversation

96 files were edited more than once. The top one took more revisions than the next four combined.

```
Most-revised files — top 6 of 96

orbit/README.md             ██████████████████████████  77   16% of all edits
orbit/index.html            ███████                     22
orbit/docs/guide/README.md  █████                       16
orbit/docs/manifest.json    █████                       16
orbit/CHANGELOG.md          █████                       15
orbit/docs/guide/handbook.html █████                    15
the other 90 files          ███████████                321   (3.6 average)
```

*Source: `session.report.json` → `rework.hotspots` (96 files, 482 repeat edits).*

**Read it as:** a five-to-one gap between first and second place. That much concentration on one
document is either unusually careful review or a document that resisted being finished — and the
numbers alone cannot tell the two apart. That is decision 1.

The composition of the work explains a lot of it. Grouping every revision by file type, roughly
**two in three landed in documentation and web pages** rather than code — consistent with a
fortnight spent preparing a public release rather than building new features.

| File type | Edits | Share of 482 |
|---|---:|---:|
| Markdown docs | 270 | 56.0% |
| Rust code | 77 | 16.0% |
| TOML config | 61 | 12.7% |
| HTML pages | 46 | 9.5% |
| JSON data | 16 | 3.3% |
| Everything else | 12 | 2.5% |

Documentation and web pages together account for **66%** of all revisions; code accounts for 16%. If
you were expecting a fortnight of feature work, this is the number that says otherwise — and it
matches what the sessions were actually asked to do.

---

## Two decisions only you can close

Neither is a fault. Both are open because the data can describe the situation but not choose what
should happen next.

### Decision 1 · Process — is 77 revisions to one document the standard, or the exception?

The 77 edits map to a known multi-reviewer pass — separate passes for a first-time reader, an
executive reader, a fact-checker and search visibility, each finding real problems. Read that way it
is diligence, and the output is better for it.

The risk is that nothing records that. The next time a file shows this pattern without a documented
review process behind it, it will look identical to a document nobody could get right — and there
will be no way to tell from the numbers which one it was.

> **What closing this looks like:** decide whether the multi-reviewer pass is standard practice, and
> write it down where a reader of the next report can find it.

### Decision 2 · Budget — cost tracking is off, and this report will keep saying so

Every money and token figure in this window reads **not recorded**. That is deliberate wording: the
tooling refuses to print a zero it did not measure, because a zero would read as "free" rather than
"unmeasured".

The sessions ran on a flat subscription, so no per-request price existed to capture in the first
place. Getting a cost figure means turning on a separate capture channel — a one-time setup, not
something that backfills.

> **What closing this looks like:** if sessions like these need to be billed, budgeted or compared on
> cost, enable the cost-capture channel before the next block of work. Nothing recovers the two weeks
> already past.

---

## One item to not lose track of

Not a problem today. Small, specific, and checkable — which is exactly why it belongs somewhere it
can be found again.

**3 tests both passed and failed inside the same window.** Not simply "failed once": these three went
from passing to failing and back across different runs. On code that is actively changing, that can
mean a fix landing — or a problem that keeps coming back. Only opening the runs tells you which.

| Test | Passes | Fails |
|---|---:|---:|
| `round_trips_losslessly` | 5 | 3 |
| `query_failures_are_disclosed_not_silent` | 3 | 2 |
| `committed_hooks_match_generator` | 2 | 1 |

*Source: `session.report.json` → `flaky` (3 tests, measured from real pass/fail lines).*

> **Why it is here and not in the decisions:** three named tests out of hundreds is a finite list. It
> needs an engineer for an hour, not a decision from you — it is on this page so that hour actually
> gets scheduled.

---

## What this report could not see

The honest part. Nine recording channels exist; one was running.

| Channel | Recorded | What it would have added |
|---|---|---|
| **Transcripts** | **9,132 turns** *(partial — gaps measured)* | everything on this page |
| Hooks | not recorded | lifecycle events, coverage |
| Events | not recorded | logs and metrics |
| Spans | not recorded | timing telemetry |
| Requests | not recorded | token counts |
| File history | not recorded | before/after file state |
| Plan docs | not observed | detector not built yet |
| Raw logs | not observed | detector not built yet |
| Provider cost | not recorded | subscription billing exposes no per-request price |

*Source: `session.report.json` → `capture.channels` (9 channels; 1 recorded, 6 `not_recorded`, 2 `not_observed`).*

**Read it as:** everything on this page comes from one channel — a very rich one, but one. That is
why cost, timing and token rows read *not recorded* rather than showing a number. A missing
measurement is printed as missing.

Within that channel, the gaps were measured rather than assumed: of 9,132 recorded turns, **629**
reference a parent turn that is not in the store and **136** tool calls have no matching result.
Those are real structural holes in the raw session logs — small against the total, disclosed rather
than smoothed over, and the reason no count on this page should be treated as exhaustive to the last
unit.

---

## How much to trust this page

| Confidence | What it covers |
|---|---|
| **High** — the figures | Every number traces to a row in a database built from seven independently captured real sessions. None is a summary of a summary, an estimate, or a round number chosen for effect. |
| **Moderate** — the explanations | Statements about *why* — that the 77 edits were a review pass, that the flaky tests are worth an hour — are reasoning over the figures. They are the part of this page a model wrote, and the part to push back on. |
| **Absent** — what was never measured | Cost, timing, token use and hook-level activity were not captured. Nothing here estimates them, and no conclusion on this page rests on them. |

---

**The evidence behind this page:** [`delivery-memo.md`](../deterministic/delivery-memo.md) —
the same window with no commentary.
**The engineering companion:** [`diagnostic-review.md`](diagnostic-review.md) — why the
run went the way it did, and what to change next time.
**The machine contract:** [`session.report.json`](../deterministic/session.report.json).
**The facts this page was written from:**
[`brief.executive.md`](brief.executive.md) — the exact brief handed to the model,
generated deterministically.

BAR Observatory — Base Agentic Reporter. Independent open-source project by Bradley Ross /
Bradley.Academy. No third-party marks are used and no endorsement is implied. Commentary layer, generated by `bar interpret --audience executive`; the evidence layer it
reads is produced by `bar report` with no model in its path.
