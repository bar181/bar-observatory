# Examples

Four reports, one record. Two audiences (**Boss Mode** for executive/client readers, **Developer
Guide** for engineering) × two layers (**Evidence** = deterministic, no LLM; **Commentary** =
optional LLM synthesis), each in HTML and Markdown — plus the machine contract they all read, and
**the seven transcripts they were all measured from**, so you can run the tool and get these exact
numbers back.

| Report | Layer | Files |
| --- | --- | --- |
| **The generated report** — every table the record produces. This is the file `bar report` writes. | Developer Guide · Evidence | [`.html`](deterministic/session.report.html) · [`.md`](deterministic/session.report.md) · [`.json`](deterministic/session.report.json) |
| **Delivery memo** — key stats and ranked top-5 lists for someone who signs things off. | Boss Mode · Evidence | [`.html`](deterministic/delivery-memo.html) · [`.md`](deterministic/delivery-memo.md) |
| **Management read** — what the numbers mean, what needs deciding, what to watch. | Boss Mode · Commentary | [`.html`](interpreted/management-read.html) · [`.md`](interpreted/management-read.md) · [brief](interpreted/brief.executive.md) |
| **Diagnostic review** — all 60 failures by root cause, error density per tool, what to change next run. | Developer Guide · Commentary | [`.html`](interpreted/diagnostic-review.html) · [`.md`](interpreted/diagnostic-review.md) · [brief](interpreted/brief.engineering.md) |
| **The capture** — the seven session transcripts everything above is measured from. | — | [`capture/`](capture/) · [`run.sh`](capture/run.sh) |

## Three of these files are literally `bar report` output

That distinction matters more than the design does, so it comes first:

| File | Produced by | Hand-assembled? |
|---|---|---|
| `deterministic/session.report.{json,html,md}` | `bar report` | **No** |
| `deterministic/delivery-memo.{html,md}` | `session.report.json` + `bar query` | Yes — a `--view summary` mode does not exist yet |
| `interpreted/*.{html,md}` | a model, from the briefs shipped beside them | Prose yes, figures no |

**Open [the generated report](deterministic/session.report.html) to see the standard you get.** The
plate layout, the numbered index, the charts and the light/dark handling are not a treatment applied
to these examples — they are what the renderer emits, in a single self-contained file that fetches
no stylesheet, no script, no font and no image. Your own report looks like this one because it is
made by the same code.

## Every number here is reproducible in three commands

```sh
bar init --dir .
for f in examples/capture/*.jsonl; do
  bar ingest .bar/ambient.sqlite "$f" --run-uuid "session-$(basename "$f" .jsonl)"
done
bar report .bar/ambient.sqlite --out out/
```

`out/ambient.report.json` comes back identical to `deterministic/session.report.json`, field for
field. Two values differ and should: `integrity.source_db_hash` and the `report.id` derived from it
hash the SQLite file, and two separate ingests of the same transcripts do not produce a
byte-identical database. Everything the report *measures* is identical.

## A stand-in project, on purpose

The project in these reports is **`orbit`**, and it does not exist.

**Real:** every count, rate and ranking — measured from the shipped capture by `bar report`, not
typed in. The failure shapes: a blocked `rm -rf`, a plugin agent called before it was installed, a
stale path after a docs move, a CI line caught mid-command. The distribution: one file taking 77 of
482 repeat edits, three tests changing verdict, eight of nine channels holding no rows.

**Stood in:** the project itself — its name, its paths, its commit subjects, its prompt titles, its
sub-agent names. A published example should show what the tool sees without publishing somebody's
repository, and the honest way to do that is to say so on the page rather than to blur a screenshot.

## Two layers, two accents

Both layers share one design system, so nothing is told apart by colour alone: every page also
carries a written badge in its top bar. **Evidence pages are plate blue** — a machine extraction with
no model anywhere in its path, where figures are substituted into fixed template text. **Commentary
pages are iris** — a model wrote every sentence, from a deterministic brief of facts it was not
allowed to change, and each one ships with that brief so the inputs are checkable.

## Known gaps, disclosed

- **Schema drift.** `session.report.json` does not currently validate against
  `schemas/report.schema.json` — that schema describes an earlier report shape than what `bar report`
  produces today. Same story for `schemas/interpretation.schema.json` against the interpreted layer.
  Both are pending a schema regeneration.
- **Assembly gap.** The delivery memo and the Commentary layer's root-cause grouping are assembled
  from `session.report.json` plus real `bar query` exports — not a dedicated `bar report --view
  summary` CLI mode. A genuine product gap, not a silent one.
- **Cost is not measured anywhere in this capture.** These sessions were read back from transcripts
  after the fact, so the cost, token, hook and span channels were never running. Every such row reads
  *not recorded*, never 0 — the tool behaving correctly, and also a limit on what these examples can
  show you.

See **[wiki/human-md/README.md](../wiki/human-md/README.md)** for a section-by-section guide to
reading a report, and **[wiki/human-html/report-guide.html](../wiki/human-html/report-guide.html)**
for an annotated walkthrough.
