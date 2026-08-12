# 02 — Database creation

BAR stores everything a run produces in **one local SQLite file** (create-if-not-exists).

- `bar init` and the capture/ingest paths **create the store if it does not exist**; the read/report
  path opens **read-only** and errors honestly if the file is missing (it never fabricates an empty DB).
- A **magic-byte guard** refuses to open a non-SQLite / corrupt file in write mode.
- Provenance is content-addressed (**blake3**); the report's `source_db_hash` derives from DB content,
  so the **same DB → byte-identical report**.

**Portability (codespace → codespace):** the store is a single file. Copy `.bar/ambient.sqlite`
to another machine and run `bar report <that-file>` — no server, no migration step. This is the
supported "upload your database" path today.
