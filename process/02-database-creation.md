# Step 2 — Database creation: one local SQLite file, portable by design

Everything a BAR Observatory run produces — every captured tool call, every ingested transcript
turn — lands in **one local SQLite file**. No server, no separate migration step, nothing to
stand up.

## How the store comes to exist

- `bar init` (see [00 — Init](00-init.md)) and the ingest/capture paths **create the store if it
  doesn't already exist**.
- The read/report path — `bar report` — opens the store **read-only** and fails honestly if the
  file is missing. It will never fabricate an empty database just to have something to render.
- A **magic-byte guard** checks that the file is really SQLite before opening it in write mode,
  so a corrupted or unrelated file can't quietly get treated as a valid store.

## Why this makes the report trustworthy

Provenance is content-addressed with **blake3**: the report's `source_db_hash` is derived
directly from the database's own content. That's what makes BAR Observatory's core promise hold
— the same database always produces a byte-identical report, whether you render it today or a
year from now.

## Take your database anywhere

Because the store is a single file, moving it is just a file copy. Captured a session in one
codespace and want to look at it somewhere else? Copy `.bar/ambient.sqlite` to the new machine
and run `bar report <that-file>` there — no server, no schema migration, no setup. That's the
supported "hand someone your session data" path today.

Next: [03 — Data ingestion](03-ingestion.md), where you'll actually put a real Claude Code
session into this store.
