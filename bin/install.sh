#!/bin/bash
export TRONADOR_ORG=${1:-cloudopsworks}
export TRONADOR_PROJECT=${2:-tronador}
export TRONADOR_BRANCH=${3:-master}
export GITHUB_REPO="https://github.com/${TRONADOR_ORG}/${TRONADOR_PROJECT}.git"

if [ "$TRONADOR_PROJECT" ] && [ -d "$TRONADOR_PROJECT" ]; then
  echo "Removing existing $TRONADOR_PROJECT"
  rm -rf "$TRONADOR_PROJECT"
fi

echo "Cloning ${GITHUB_REPO}#${TRONADOR_BRANCH}..."
git clone -q -b $TRONADOR_BRANCH $GITHUB_REPO 2>/dev/null
#rm -rf $TRONADOR_PROJECT/.git # affects the git status of the project

cat >&2 <<'NOTICE'

Deprecation Notice: this make module is being deprecated in favor of our CLI.
Please refer to our resources documentation and GitHub project:

  Install guide:  https://cloudopsworks.co/resources/tronador-cli-installation/
  Resources:      https://cloudopsworks.co/resources/
  GitHub project: https://github.com/cloudopsworks/tronador-cli

NOTICE
