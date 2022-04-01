#!/bin/bash
export ACCELERATE_ORG=${1:-cloudopsworks}
export ACCELERATE_PROJECT=${2:-accelerate}
export ACCELERATE_BRANCH=${3:-master}
export GITHUB_REPO="https://github.com/${ACCELERATE_ORG}/${ACCELERATE_PROJECT}.git"

if [ "$ACCELERATE_PROJECT" ] && [ -d "$ACCELERATE_PROJECT" ]; then
  echo "Removing existing $ACCELERATE_PROJECT"
  rm -rf "$ACCELERATE_PROJECT"
fi

echo "Cloning ${GITHUB_REPO}#${ACCELERATE_BRANCH}..."
git clone -b $ACCELERATE_BRANCH $GITHUB_REPO
