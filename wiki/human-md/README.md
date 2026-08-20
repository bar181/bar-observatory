# BAR Observatory — the plain-language getting-started guide

This page is for **anyone** — you don't need to be a developer to follow it. If a step involves
typing something, you'll be told exactly what to type and what it does.

**What you'll get by the end:** a report, in your web browser, that honestly shows what an AI
coding agent did during a session — what it built, where it struggled, and what (if anything)
went wrong.

If you're setting this up for an AI agent to use on its own instead of a human, see
**[the AI agent guide](../agent/AI-CONTEXT.md)** instead.

## Is this safe to use?

Before you install anything, the honest short answer: yes, and here's exactly why. BAR
Observatory reads a record your Claude Code session already wrote to your own disk, keeps
everything it finds in one local file, and never sends any of it anywhere. There's no account to
create, no company server it talks to, and nothing to configure to make that true — it's how the
tool is built, not a setting you could accidentally turn off. If you ever want to hand a captured
session to someone else, there's a built-in step that scrubs sensitive text out first, so sharing
is a choice you make, not something that happens by default. Full detail, including how this
holds up for regulated or fully offline environments: [wiki/human-md/enterprise.md](enterprise.md).

## Step 1 — Install the plugin (recommended)

If you use Claude Code, the easiest setup is the plugin — it does most of the work for you. Type
this inside your Claude Code session:

```
/plugin marketplace add bar181/bar-observatory
/plugin install bar-observatory@bar-observatory
```

Then run this once in your **terminal** (a text-based window for typing commands to your
computer — on Mac, search for "Terminal" in Spotlight; on Windows, search for "Command Prompt" or
"PowerShell"; on Linux, it's usually in your applications menu), to get the underlying tools the
plugin uses. Type the line below exactly, then press Enter:

```bash
cargo install bar-hook bar-mcp bar-observatory
```

This will print a lot of text while it works — that's normal. It's done when you see your prompt
again (the blinking cursor waiting for the next command).

*Don't have `cargo` installed?* That's the tool that installs BAR Observatory. Get it for free
at [rustup.rs](https://rustup.rs) — it takes about a minute, then come back to the command above.

Not using the plugin? You can still install and use everything by hand — see
[the manual path](#the-manual-path-no-plugin) further down. Both paths end up in exactly the
same place.

## Step 2 — Set up your project

Type this inside your Claude Code session:

```
/bar-init
```

This creates a small, hidden folder called `.bar` in your project — that's where BAR Observatory
keeps its notes. It's completely safe to run this command again later; it will never erase
anything that's already there.

## Step 3 — Use Claude Code normally

That's it — just do your work. Once the plugin is installed, BAR Observatory quietly keeps
notes in the background. You don't need to remember to turn it on or think about it while you
work.

## Step 4 — Generate your report

When you're ready to see what happened, type:

```
/bar-report
```

This produces three versions of the same report:
- **An HTML file** — open it in any web browser, like a normal webpage. This is the one most
  people want.
- **A Markdown file** — good for pasting into a chat, doc, or GitHub comment.
- **A JSON file** — the raw data, for anyone who wants to process it with other software.

## How to read the report

Reports are organized top to bottom, from "what was the goal" down to "what almost slipped
through unnoticed":

1. **Tasks completed** — what the agent was asked to do, and the proof it actually did it (not
   just a claim — real evidence).
2. **Places it had to redo work** — where the agent got something wrong the first time and had
   to circle back. A little of this is completely normal; a lot of it in one spot is worth a
   second look.
3. **Team handoffs** — if the AI used helper agents for parts of the job, this shows how work
   moved between them.
4. **Tools and skills used** — which capabilities the agent actually exercised.
5. **Tests and checks** — what got verified, and whether it passed.

Two sections you'll see planned in this project's own docs but won't find in today's report:
**who fixed what** (did the AI catch its own mistake, or did a human have to step in?) and a
**small-but-important findings** section for things that are easy to miss just by watching the
conversation. Both are real, disclosed gaps — not built yet, not silently skipped — and the
report itself says so plainly (`not_observed` — the detector exists in the schema, nothing has
built it yet) rather than showing an empty section that looks
finished.

Every single fact in the report is pulled directly from what was actually recorded — never
guessed, never rounded up to look better. If something wasn't captured, the report says so
plainly instead of quietly showing a "0" that looks like a real answer.

### A real example

Here's the kind of thing the report surfaces that a summary never would — real problems from a
captured session, found in one command, that would otherwise have scrolled off the screen and been
forgotten. These lines come from the capture that ships with this project, in `examples/capture/`:

```
$ bar query <db> errors --limit 0
seq    what happened
----   -----------------------------------------------------------------
14     A skill was called before it was installed
133    A safety guardrail blocked a risky command
186    A path that a docs reorganisation had already moved
453    An edit whose target text had changed since the file was read
690    A helper agent was dispatched by a name that does not exist
```

That session recorded sixty of them. Not all sixty are defects — the guardrail on line 133 is the
safety system doing its job — and the report sorts them by root cause rather than lumping them
together. Run the same command over your own store and you get your own list. The point is not
these five lines; it is that nothing had to be remembered to find them.

## Optional: get a plain-English writeup

The report above is all facts, no commentary. If you'd also like a written summary — "here's
what this means and what to do differently next time" — that's a separate, optional step:

```
/bar-interpret
```

Type `/bar-interpret engineering` for more technical detail, or `/bar-interpret executive` for a
version focused on cost, risk, and business value.

Good to know: BAR Observatory itself never writes this summary. It hands your Claude Code
session the exact facts, and *that* AI session writes the prose. This matters because it keeps
the two jobs separate — the facts always come from real data and can't drift, while the writing
is free to explain things in plain language.

## Optional: check that everything is working

If you're ever unsure whether things are being recorded correctly, ask:

```
/bar-doctor
```

This gives you an honest, plain-language health check — not "here's what happened," but "is the
recorder itself actually working right now, and is anything missing?"

## The manual path (no plugin)

Everything above can also be done by typing commands directly in a terminal, if you're not using
the Claude Code plugin or just prefer the command line:

```bash
cargo install bar-observatory
bar init --dir .
bar ingest .bar/ambient.sqlite <your-session>.jsonl
bar report .bar/ambient.sqlite --out .
bar interpret .bar/ambient.sqlite --audience engineering
bar doctor .bar/ambient.sqlite
```

`<your-session>.jsonl` is the record Claude Code already keeps of your conversation, usually
found under `~/.claude/projects/<project>/<session>.jsonl` on your computer. See
**[RUN.md](../../RUN.md)** for a script that runs all of these for you in one go.

## If something goes wrong

- **"Command not found" after `cargo install`** — close and reopen your terminal, then try
  again. The install adds a new location your terminal needs to notice.
- **A slash command doesn't seem to do anything** — make sure you ran the `cargo install` step
  first; the plugin's commands rely on those tools being present.
- **You're stuck on something not covered here** — open an
  [issue](https://github.com/bar181/bar-observatory/issues) and describe what you typed and what
  happened. That's a normal, expected way to get help, not a failure on your part.

## Why keep doing this

One report tells you how one session went. Kept over time, the same local database becomes
something more useful: the next time you or an AI agent starts a similar piece of work, it can
check what was already tried and what already failed, instead of re-discovering it the hard way
at your expense. That's the difference between a single receipt and a history you can actually
learn from.

## Where to go next

- **[CRATES.md](../../CRATES.md)** — the full list of components this project is built from
- **[process/](../../process/)** — a more detailed, step-by-step tour for the technically curious
- **[examples/](../../examples/)** — four sample reports you can open right now, no setup needed,
  plus the capture they were all measured from
- **[wiki/human-md/comparison.md](comparison.md)** — how this differs from a live dashboard or a
  telemetry backend, if you're weighing it against something else

---

Created by **Bradley Ross**, Agentic Engineer —
[linkedin.com/in/bradaross](https://www.linkedin.com/in/bradaross). Full bio and
acknowledgements: [the main README](../../README.md#about-the-author).
