# Examples

One example per report type, real data, clearly named. Previously this folder had ten-plus files
mixing a real capture, a seeded fixture, and a hand-authored mock — confusing to tell apart. It's
now nine files across two report types:

| File(s) | What it is |
| --- | --- |
| [`deterministic/real-session.report.{json,html,md}`](deterministic/) | The calculated report (`bar report`) — no AI, $0.00, byte-identical every time. Rendered by the real `bar` CLI from a genuine, multi-thousand-turn Claude Code transcript. This is the best preview of what your own report will look like. |
| [`deterministic/real-session.report.png`](deterministic/real-session.report.png) | A screenshot of the `.html` version above, used in the README and wiki. |
| [`interpreted/interpreted-executive.html`](interpreted/interpreted-executive.html) | The optional interpreted report (`bar interpret --audience executive`) — plain-language, value/cost/risk framing. LLM-written, clearly labeled, from the real brief below. |
| [`interpreted/interpreted-executive.png`](interpreted/interpreted-executive.png) | A screenshot of the interpreted-executive page above, used in the README. |
| [`interpreted/interpreted-engineering.html`](interpreted/interpreted-engineering.html) | The same optional layer, `--audience engineering` — precise, technical, actionable. |
| [`interpreted/interpret-brief.executive.md`](interpreted/interpret-brief.executive.md), [`interpret-brief.engineering.md`](interpreted/interpret-brief.engineering.md) | The real, deterministic briefs `bar interpret` generated — the exact facts each interpreted report above was written from. Nothing in either report exists that isn't in its brief. |

## Two different real sessions, on purpose

The deterministic example and the interpreted pair come from **different** real captured
sessions, not the same one split two ways — the deterministic example is a substantial coding
session; the interpreted pair is from a live capture of the documentation session that built
these example pages. Both are real, both are reproducible, and mixing origins here is disclosed
rather than implied to be one continuous story.

## How to read them

Open any `.html` file for the human view, the `.md` for a terminal- or diff-friendly view, or the
`.json` for the machine-readable form. **One known gap, disclosed:** `deterministic/real-session
.report.json` does not currently validate against `schemas/report.schema.json` — that schema
describes an earlier report shape than what `bar report` produces today. Same story for
`schemas/interpretation.schema.json` against the interpreted layer, which now ships as a
brief-plus-prose pair rather than the richer JSON structure that schema describes. Both are
pending a schema regeneration in the private working repo; this README says so rather than
leaving a reader to discover the mismatch by hand.

## Why the deterministic layer only has one example

Earlier drafts also shipped a seeded fixture and a hand-authored "fully populated" mock, on the
theory that showing every possible section at once had more reference value. It didn't hold up:
the mock was built against the same earlier schema, and would have shown detectors this version
of the product doesn't actually run yet (`human_ai_recovery`, `micro_observations`) as if they
were live — exactly the kind of overclaiming this project's `not_observed` discipline exists to
prevent. One real example, honestly incomplete in the same ways your own reports will be, is more
useful than a synthetic one that quietly promises more than the tool delivers.

See **[wiki/human-md/README.md](../wiki/human-md/README.md)** for a section-by-section guide to reading
a report, and **[wiki/report-guide.html](../wiki/human-html/report-guide.html)** for a fully annotated
walkthrough of the deterministic example above.
