#!/bin/bash
# Regression checks for the consumer bootstrap (templates/Makefile.tronador-base
# and bin/install.sh). Fully offline: GitHub URLs are rewritten to local repos.
#   - the auto-init remote check runs once per top-level make in a project,
#     even with TRONADOR_AUTO_INIT=true on the command line, and a marker left
#     by a different project does not suppress it;
#   - install.sh replaces an existing checkout only after a successful clone,
#     keeps it on failure, and survives an old checkout it cannot fully delete.
#
# Usage: MAKE_BIN=gmake tests/tronador-bootstrap.sh
set -u

ROOT=$(cd "$(dirname "$0")/.." && pwd)
MAKE_BIN=${MAKE_BIN:-make}
WORK=$(mktemp -d)
trap 'chmod -R u+w "$WORK" 2>/dev/null; rm -rf "$WORK"' EXIT
FAILED=0

fail() { echo "FAIL: $*"; FAILED=1; }
pass() { echo "PASS: $*"; }
run_limited() {
  local secs=$1; shift
  if command -v timeout >/dev/null 2>&1; then
    timeout "$secs" "$@"
  else
    perl -e 'alarm shift; exec @ARGV' "$secs" "$@"
  fi
}
gitc() { git -c user.name=t -c user.email=t@t -c init.defaultBranch=master "$@"; }

echo "Using $("$MAKE_BIN" --version | head -n 1)"

# git wrapper that logs every call
mkdir -p "$WORK/bin"
cat > "$WORK/bin/git" <<EOF
#!/bin/bash
echo "git \$*" >> "$WORK/git.log"
exec $(command -v git) "\$@"
EOF
chmod +x "$WORK/bin/git"

# Snapshot of the working tree (including uncommitted changes) on branch master,
# published as a local bare repo standing in for github.com/cloudopsworks/tronador.
SNAP="$WORK/snapshot"
mkdir "$SNAP"
(cd "$ROOT" && tar --exclude ./vendor --exclude ./tmp --exclude ./.git -cf - .) | tar -xf - -C "$SNAP"
gitc -C "$SNAP" init -q
gitc -C "$SNAP" add -A
gitc -C "$SNAP" commit -q -m snapshot
mkdir -p "$WORK/src/cloudopsworks"
gitc clone -q --bare "$SNAP" "$WORK/src/cloudopsworks/tronador.git"
# Rewrite https://github.com/ -> local repos for every git call in this test.
export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0="url.file://$WORK/src/.insteadOf"
export GIT_CONFIG_VALUE_0="https://github.com/"
unset TRONADOR_AUTO_INIT_DONE

# --- consumer project ---------------------------------------------------------
CONSUMER="$WORK/consumer"
gitc init -q "$CONSUMER"
gitc -C "$CONSUMER" commit -q --allow-empty -m init
gitc clone -q "$WORK/src/cloudopsworks/tronador.git" "$CONSUMER/tronador"
cp "$ROOT/templates/Makefile.tronador-base" "$CONSUMER/.tronador"
printf 'TRONADOR_AUTO_INIT := true\n-include .tronador\n' > "$CONSUMER/Makefile"

count_checks() {  # $@: extra make args; prints number of remote checks
  : > "$WORK/git.log"
  (cd "$CONSUMER" && PATH="$WORK/bin:$PATH" run_limited 60 "$MAKE_BIN" "$@" help </dev/null >/dev/null 2>&1)
  local rc=$?
  [ "$rc" -eq 0 ] || { echo "make-exit-$rc"; return; }
  grep -c "ls-remote https://github.com/cloudopsworks/tronador.git" "$WORK/git.log"
}

n=$(count_checks)
[ "$n" = 1 ] && pass "auto-init remote check ran once across recursive sub-makes" \
             || fail "auto-init remote check: expected 1, got $n"

n=$(count_checks TRONADOR_AUTO_INIT=true)
[ "$n" = 1 ] && pass "command-line TRONADOR_AUTO_INIT=true does not bypass the once-per-run guard" \
             || fail "command-line TRONADOR_AUTO_INIT=true: expected 1 check, got $n"

n=$(TRONADOR_AUTO_INIT_DONE=/some/other/project count_checks)
[ "$n" = 1 ] && pass "a marker from another project does not suppress this project's check" \
             || fail "foreign TRONADOR_AUTO_INIT_DONE: expected 1 check, got $n"

# --- install.sh ---------------------------------------------------------------
INST="$WORK/install"
leftovers() { ls -d "$INST"/*.tmp.* "$INST"/*.old.* 2>/dev/null; }

# success: existing checkout is replaced by a fresh clone
mkdir -p "$INST/tronador" && echo old > "$INST/tronador/marker"
(cd "$INST" && run_limited 60 bash "$ROOT/bin/install.sh" cloudopsworks tronador master </dev/null >/dev/null 2>&1)
rc=$?
if [ "$rc" -ne 0 ]; then fail "install.sh success path exited $rc"
elif [ -e "$INST/tronador/marker" ] || [ ! -f "$INST/tronador/Makefile" ]; then fail "install.sh did not replace the existing checkout"
elif [ -n "$(leftovers)" ]; then fail "install.sh left temporary directories: $(leftovers)"
else pass "install.sh replaced the existing checkout with a fresh clone"
fi

# failure: clone of a missing repo keeps the existing checkout
rm -rf "$INST" && mkdir -p "$INST/tronador-missing" && echo keep > "$INST/tronador-missing/marker"
(cd "$INST" && GIT_TERMINAL_PROMPT=0 run_limited 60 bash "$ROOT/bin/install.sh" cloudopsworks tronador-missing master </dev/null >/dev/null 2>&1)
rc=$?
if [ "$rc" -eq 0 ]; then fail "install.sh returned 0 for a repository that cannot be cloned"
elif [ ! -f "$INST/tronador-missing/marker" ]; then fail "install.sh removed the existing checkout after a failed clone"
elif [ -n "$(leftovers)" ]; then fail "install.sh left temporary directories: $(leftovers)"
else pass "install.sh failed cleanly (rc=$rc) and kept the existing checkout"
fi

# partially undeletable old checkout: new clone still lands in place
rm -rf "$INST" && mkdir -p "$INST/tronador/vendor" && echo x > "$INST/tronador/vendor/locked" && chmod a-w "$INST/tronador/vendor"
(cd "$INST" && run_limited 60 bash "$ROOT/bin/install.sh" cloudopsworks tronador master </dev/null >/dev/null 2>&1)
rc=$?
if [ "$rc" -ne 0 ]; then fail "install.sh exited $rc when the old checkout could not be fully removed"
elif [ ! -f "$INST/tronador/Makefile" ] || ls -d "$INST"/tronador/tronador.tmp.* >/dev/null 2>&1; then fail "install.sh did not place the new clone correctly"
else pass "install.sh placed the new clone even though the old checkout was not fully removable"
fi

exit $FAILED
