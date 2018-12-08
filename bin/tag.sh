#!/bin/bash

set -eu

git_sha_head() {
    git rev-parse --short=8 HEAD
}

clean_head() {
    [ -n "${CI_FORCE_CLEAN:-}" ] || git diff-index --quiet HEAD --
}

if clean_head ; then
    echo $(git_sha_head)
else
    echo "$(git_sha_head)-$USER"
fi
