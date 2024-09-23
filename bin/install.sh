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
git clone -q -b $TRONADOR_BRANCH $GITHUB_REPO
