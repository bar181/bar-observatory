#!/usr/bin/env sh
# Rebuild every deterministic example from the capture in this folder.
# Requires `bar` on PATH (see ../../RUN.md). No network access is used at any point.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
work=${1:-./demo-run}

mkdir -p "$work"
cd "$work"

bar init --dir .
for f in "$here"/*.jsonl; do
  name=$(basename "$f" .jsonl)
  bar ingest .bar/ambient.sqlite "$f" --run-uuid "session-$name"
done
bar report .bar/ambient.sqlite --out out

echo
echo "Wrote out/ambient.report.{json,html,md}."
echo "Compare against examples/deterministic/session.report.* — they are the same three files."
