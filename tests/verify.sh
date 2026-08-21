#!/usr/bin/env sh
# End-user verification suite for BAR Observatory.
#
# Tests the PUBLISHED crates.io artifacts as a black box -- no private source,
# no internal test harness, nothing this script can't show you the output of.
# See tests/README.md for what each check verifies, why, and the expected
# output.
#
# Requires: cargo, jq, timeout (or gtimeout on macOS via `brew install coreutils`).
# Usage:    sh tests/verify.sh            # installs from crates.io, then runs everything
#           SKIP_INSTALL=1 sh tests/verify.sh   # reuse an already-installed `bar`/`bar-mcp` on PATH
set -eu

here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/.." && pwd)
work=$(mktemp -d 2>/dev/null || mktemp -d -t barverify)
pass=0
fail=0

ok()  { pass=$((pass + 1)); printf '  [PASS] %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '  [FAIL] %s\n' "$1"; }

echo "BAR Observatory end-user verification suite"
echo "Working dir: $work"
echo

# ---------------------------------------------------------------------------
# 1. Install
# ---------------------------------------------------------------------------
echo "1. Install (cargo install bar-hook bar-mcp bar-observatory --locked)"
if [ "${SKIP_INSTALL:-0}" = "1" ] && command -v bar >/dev/null 2>&1 && command -v bar-mcp >/dev/null 2>&1; then
  ok "SKIP_INSTALL=1 set, and bar/bar-mcp already on PATH"
else
  if cargo install bar-hook bar-mcp bar-observatory --locked --root "$work/.cargo" >"$work/install.log" 2>&1; then
    PATH="$work/.cargo/bin:$PATH"
    export PATH
    ok "installed cleanly from crates.io, no path dependencies"
  else
    bad "cargo install failed -- see $work/install.log"
    echo
    echo "Cannot continue without a working install; stopping."
    exit 1
  fi
fi
echo

# ---------------------------------------------------------------------------
# 2. Determinism / reproducibility
# ---------------------------------------------------------------------------
echo "2. Determinism (ingest the shipped example, diff against the shipped report)"
mkdir -p "$work/repro"
(
  cd "$work/repro"
  bar init --dir . >/dev/null 2>&1
  for f in "$repo"/examples/capture/*.jsonl; do
    name=$(basename "$f" .jsonl)
    bar ingest .bar/ambient.sqlite "$f" --run-uuid "verify-$name" >/dev/null 2>&1
  done
  bar report .bar/ambient.sqlite --out out >/dev/null 2>&1
)
jq -S 'del(.integrity.source_db_hash, .report.id)' \
  "$work/repro/out/ambient.report.json" >"$work/fresh-normalized.json"
jq -S 'del(.integrity.source_db_hash, .report.id)' \
  "$repo/examples/deterministic/session.report.json" >"$work/shipped-normalized.json"
if diff -q "$work/shipped-normalized.json" "$work/fresh-normalized.json" >/dev/null 2>&1; then
  ok "every field matches the shipped report except source_db_hash / report.id (expected to vary between ingests)"
else
  bad "a field differs that should not -- see the diff below"
  diff -u "$work/shipped-normalized.json" "$work/fresh-normalized.json" | head -40
fi
echo

# ---------------------------------------------------------------------------
# 3. Checksum integrity
# ---------------------------------------------------------------------------
echo "3. Checksum integrity (checksums/SHA256SUMS.txt)"
if (cd "$repo" && sha256sum -c checksums/SHA256SUMS.txt >"$work/checksums.log" 2>&1); then
  ok "every shipped file verifies against the manifest"
else
  bad "checksum mismatch -- see $work/checksums.log"
fi
echo

# ---------------------------------------------------------------------------
# 4. bar doctor health
# ---------------------------------------------------------------------------
echo "4. bar doctor (capture health over the reproduced store)"
if (cd "$work/repro" && bar doctor .bar/ambient.sqlite >"$work/doctor.log" 2>&1); then
  ok "bar doctor exits 0 over a real capture store"
else
  bad "bar doctor reported a problem -- see $work/doctor.log"
fi
echo

# ---------------------------------------------------------------------------
# 5. Config validity
# ---------------------------------------------------------------------------
echo "5. Config validity (bar init's shipped default config loads cleanly)"
mkdir -p "$work/config-check"
if (
  cd "$work/config-check"
  bar init --dir . >"$work/config-check.log" 2>&1 \
    && bar doctor .bar/ambient.sqlite >>"$work/config-check.log" 2>&1
); then
  ok "the config bar init writes is accepted by the binary with no error"
else
  bad "config rejected -- see $work/config-check.log"
fi
echo

# ---------------------------------------------------------------------------
# 6. MCP contract smoke test
# ---------------------------------------------------------------------------
echo "6. MCP contract (bar-mcp answers initialize + tools/list with exactly 12 tools)"
TIMEOUT_BIN=timeout
command -v timeout >/dev/null 2>&1 || TIMEOUT_BIN=gtimeout
mcp_resp=$(
  printf '%s\n%s\n' \
    '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' \
    '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
    | "$TIMEOUT_BIN" 5 bar-mcp 2>"$work/mcp-stderr.log" || true
)
tool_count=$(printf '%s\n' "$mcp_resp" | grep '"id":2' | jq '.result.tools | length' 2>/dev/null || echo 0)
if [ "$tool_count" = "12" ]; then
  ok "bar-mcp returns exactly 12 tools over real newline-delimited stdio JSON-RPC"
else
  bad "expected 12 tools, got '$tool_count' -- see $work/mcp-stderr.log"
fi
echo

# ---------------------------------------------------------------------------
echo "----------------------------------------"
echo "$pass passed, $fail failed"
if [ "$fail" -gt 0 ]; then
  exit 1
fi
