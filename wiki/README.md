# BAR Observatory wiki

This folder is deep-dive material, organized by reader. If you haven't yet, start at the
**[root README](../README.md)** or **[index.html](../index.html)** — both work as compact hubs
with a "longer version: wiki/…" link into each page below. This file is a map, not a fourth copy
of that content — nothing here restates what those two already say.

Prefer one long page instead of a folder to click through? **[README.html](README.html)** covers
the same ground as everything below in a single page, with a Human / Advanced / AISP reading-mode
switch (CSS-only, no JavaScript).

## By reader

- **New to this, no assumed background:** [`human-md/README.md`](human-md/README.md) — a
  click-along setup guide, including how to open a terminal.
- **Deciding whether to commission or trust AI-assisted work:**
  [`human-html/guides/guide-executive.html`](human-html/guides/guide-executive.html)
- **New to reviewing AI-written code:**
  [`human-html/guides/guide-junior-dev.html`](human-html/guides/guide-junior-dev.html)
- **Evaluating this against something else you already run:**
  [`human-md/comparison.md`](human-md/comparison.md)
- **Security / compliance / air-gapped review:**
  [`human-md/enterprise.md`](human-md/enterprise.md)
- **Technical reference — crates, determinism, absence semantics:**
  [`human-md/architecture.md`](human-md/architecture.md)
- **What's actually in a report, field by field, against a real example:**
  [`human-html/report-guide.html`](human-html/report-guide.html)
- **Why the docs exist in three registers (human / AI / AISP):**
  [`human-html/documentation-layers.html`](human-html/documentation-layers.html)
- **An AI agent consuming this project over MCP:** [`agent/AI-CONTEXT.md`](agent/AI-CONTEXT.md)
- **Machine-readable capability registry:** [`aisp/HUB.aisp`](aisp/HUB.aisp)

## Would you rather just look at the output?

Skip all of the above and open [`examples/`](../examples/README.md) — four reports over one
capture, and the capture ships with them, so you can rebuild every deterministic file yourself
with one script. Start with
[`session.report.html`](../examples/deterministic/session.report.html): that is literally what
`bar report` writes, not a styled copy of it. The project it describes, `orbit`, is a stand-in —
the measurements are real, the repository is not.

## Folder shape

```
wiki/
├── README.md      this file — a map, by reader
├── README.html    the same ground as one long page, with a reading-mode switch
├── human-md/      reference pages: setup tutorial, comparison, enterprise, architecture
├── human-html/    blog-style deep dives
│   └── guides/    one page per reader: executive, junior developer
├── agent/         for AI agents consuming this project over MCP
└── aisp/          machine-readable capability registry
```

## One rule this folder holds itself to

No table, contract, or score lives in more than one file. `human-md/` is the single source for
each topic; the root README and `index.html` carry only condensed teasers pointing back here.
If you find the same fact stated two different ways in two different files, that's a bug —
[open an issue](https://github.com/bar181/bar-observatory/issues).
