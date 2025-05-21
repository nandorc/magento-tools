#!/bin/bash

# Show current git status
if [ ${has_git} -eq 1 ]; then
    git status
    [ ${?} -ne 0 ] && error_message "Can't get current git status" && exit 1
fi

# Check not commited files and stash if allowed
if [ ${has_git} -eq 1 ] && [ -n "$(git status -s)" ]; then
    if [ ${git_use_stash} -eq 1 ]; then
        [ -n "$(git stash list)" ] && error_message "Can't create a new stash if there is an existent one" && exit 1
        git stash push -u
        [ ${?} -ne 0 ] && error_message "Can't stash current changes" && exit 1
    else
        [ "${git_pull_mode}" == "soft" ] && error_message "Can't execute git actions. Pending data to commit found in repo. Review env files or set git_use_stash param to 1 or use --use-stash flag to try to save and re-apply pending changes." && exit 1
    fi
fi

# Switch to target branch
if [ ${has_git} -eq 1 ] && [ -n "${git_deploy_branch}" ]; then
    git switch "${git_deploy_branch}"
    [ ${?} -ne 0 ] && error_message "Can't switch to branch with name ${git_deploy_branch}" && exit 1
fi

# Pull changes from origin
if [ ${has_git} -eq 1 ] && [ ${git_has_remote} -eq 1 ] && [ -n "${git_deploy_branch}" ]; then
    if [ "${git_pull_mode}" == "hard" ]; then
        git reset --hard "origin/${git_deploy_branch}"
        [ ${?} -ne 0 ] && error_message "Can't force pull branch ${git_deploy_branch} from origin" && exit 1
    elif [ "${git_pull_mode}" == "soft" ]; then
        git pull
        [ ${?} -ne 0 ] && error_message "Can't pull branch ${git_deploy_branch} from origin" && exit 1
    fi
fi

# Restore not commited files if stash is allowed and used
if [ ${has_git} -eq 1 ] && [ ${git_use_stash} -eq 1 ] && [ -n "$(git stash list)" ]; then
    git stash pop
    [ ${?} -ne 0 ] && error_message "Can't restore changes from stash" && exit 1
fi
