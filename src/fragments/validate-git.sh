#!/bin/bash

# Set defaults
git_has_remote=0
has_git=1

# Check if git repo
[ ! -d .git ] && has_git=0

# Upgrade git info
if [ ${has_git} -eq 1 ]; then
    git fetch
    [ -n "$(git remote 2>/dev/null | grep origin)" ] && git_has_remote=1
    [ ${git_has_remote} -eq 1 ] && git remote prune origin
fi
