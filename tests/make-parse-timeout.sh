#!/bin/bash
# Regression: GNU Make >= 4.4 hung while parsing tronador because exported
# variables defined with $(shell ...) were re-expanded into the environment of
# every $(shell) call (factorial blow-up). Parsing must finish quickly.
#
# Usage: MAKE_BIN=gmake tests/make-parse-timeout.sh
# Exits 0 with SKIP when MAKE_BIN is older than 4.4 (the bug cannot trigger there).
set -u

ROOT=$(cd "$(dirname "$0")/.." && pwd)
MAKE_BIN=${MAKE_BIN:-make}
LIMIT=${LIMIT:-30}

run_limited() {
  local secs=$1; shift
  if command -v timeout >/dev/null 2>&1; then
    timeout "$secs" "$@"
  else
    perl -e 'alarm shift; exec @ARGV' "$secs" "$@"
  fi
}

version=$("$MAKE_BIN" --version | head -n 1)
echo "Using $version"
ver=$(echo "$version" | sed -nE 's/^GNU Make ([0-9]+)\.([0-9]+).*/\1 \2/p')
read -r major minor <<<"${ver:-0 0}"
if [ "$major" -lt 4 ] || { [ "$major" -eq 4 ] && [ "$minor" -lt 4 ]; }; then
  echo "SKIP: GNU Make >= 4.4 required to exercise this regression"
  exit 0
fi

cd "$ROOT" || exit 1
start=$(date +%s)
run_limited "$LIMIT" "$MAKE_BIN" -s init >/dev/null 2>&1
rc=$?
elapsed=$(( $(date +%s) - start ))

if [ "$rc" -ne 0 ]; then
  echo "FAIL: '$MAKE_BIN init' exited $rc after ${elapsed}s (limit ${LIMIT}s)"
  exit 1
fi
echo "PASS: '$MAKE_BIN init' finished in ${elapsed}s"
