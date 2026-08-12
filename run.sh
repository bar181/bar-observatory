#!/usr/bin/env bash
# BAR Observatory — front-door runner. Builds `bar`, ingests a transcript, renders the report.
# Local-only, no API key. Usage: ./run.sh <session.jsonl> [outdir]
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
TX="${1:-}"; OUT="${2:-$HERE/_run}"
if [ -z "$TX" ] || [ ! -f "$TX" ]; then
  echo "usage: ./run.sh <path-to-session.jsonl> [outdir]" >&2
  echo "  (a Claude Code transcript, e.g. ~/.claude/projects/<proj>/<session>.jsonl)" >&2
  exit 2
fi

# 1) Locate or build the `bar` CLI.
BAR=""
if command -v bar >/dev/null 2>&1; then
  BAR="$(command -v bar)"
elif [ -x "$HERE/../bar-obs-private/crates/target/release/bar" ]; then
  BAR="$HERE/../bar-obs-private/crates/target/release/bar"
elif [ -f "$HERE/../bar-obs-private/crates/Cargo.toml" ]; then
  echo "building bar from ../bar-obs-private/crates ..."
  ( cd "$HERE/../bar-obs-private/crates" && cargo build --release -p bar-observatory --bin bar >/dev/null )
  BAR="$HERE/../bar-obs-private/crates/target/release/bar"
else
  echo "no bar binary found — install with: cargo install bar-observatory" >&2
  exit 3
fi
echo "using bar: $BAR"

# 2) Fresh local store, ingest, render, health-check.
mkdir -p "$OUT"
"$BAR" init   --dir "$OUT" >/dev/null
DB="$OUT/.bar/ambient.sqlite"
"$BAR" ingest "$DB" "$TX"
"$BAR" report "$DB" --out "$OUT"
"$BAR" doctor "$DB"
echo ""
echo "report ready in: $OUT   (open the .report.html)"
