#!/bin/bash
export TRONADOR_ORG=${1:-cloudopsworks}
export TRONADOR_PROJECT=${2:-tronador}
export TRONADOR_BRANCH=${3:-master}
export GITHUB_REPO="https://github.com/${TRONADOR_ORG}/${TRONADOR_PROJECT}.git"

# Never block on a credential prompt (this runs inside make's $(shell) at parse
# time); fail fast instead. Callers may opt back in with GIT_TERMINAL_PROMPT=1.
export GIT_TERMINAL_PROMPT=${GIT_TERMINAL_PROMPT:-0}

if [ -z "$TRONADOR_PROJECT" ]; then
  echo "TRONADOR_PROJECT must not be empty" >&2
  exit 1
fi

# Clone next to the target first so a failed clone never leaves the project
# without a working tronador checkout. The old checkout is moved aside (not
# deleted) until the new one is in place.
TMP_CLONE="${TRONADOR_PROJECT}.tmp.$$"
OLD_CLONE="${TRONADOR_PROJECT}.old.$$"
trap 'rm -rf "$TMP_CLONE"' EXIT
trap 'exit 130' INT TERM
rm -rf "$TMP_CLONE"

echo "Cloning ${GITHUB_REPO}#${TRONADOR_BRANCH}..."
if ! git -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=30 \
    clone -q -b "$TRONADOR_BRANCH" "$GITHUB_REPO" "$TMP_CLONE"; then
  echo "Failed to clone ${GITHUB_REPO}#${TRONADOR_BRANCH}; keeping existing ${TRONADOR_PROJECT} (if any)." >&2
  exit 1
fi

if [ -e "$TRONADOR_PROJECT" ]; then
  echo "Replacing existing $TRONADOR_PROJECT"
  if ! mv "$TRONADOR_PROJECT" "$OLD_CLONE"; then
    echo "Cannot move existing $TRONADOR_PROJECT aside; leaving it untouched." >&2
    exit 1
  fi
fi
if ! mv "$TMP_CLONE" "$TRONADOR_PROJECT"; then
  echo "Cannot move new clone into $TRONADOR_PROJECT; restoring previous checkout." >&2
  [ -e "$OLD_CLONE" ] && mv "$OLD_CLONE" "$TRONADOR_PROJECT"
  exit 1
fi
if [ -e "$OLD_CLONE" ] && ! rm -rf "$OLD_CLONE"; then
  echo "Warning: could not fully remove previous checkout $OLD_CLONE; remove it manually." >&2
fi
#rm -rf $TRONADOR_PROJECT/.git # affects the git status of the project

cat >&2 <<'NOTICE'

Deprecation Notice: this make module is being deprecated in favor of our CLI.
Please refer to our resources documentation and GitHub project:

  Install guide:  https://cloudopsworks.co/resources/tronador-cli-installation/
  Resources:      https://cloudopsworks.co/resources/
  Docs:           https://tronador.cloudopsworks.co/
  GitHub project: https://github.com/cloudopsworks/tronador-cli

NOTICE
