#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Get parameters
declare env_name=default
declare target_branch=
declare must_pull_repo=1
declare must_force_pull=1
declare has_remote_origin=0
declare use_stash=1
declare must_install_deps=1
declare must_upgrade=1
declare must_refresh=1
declare must_enable_maintenance=1
declare must_disable_maintenance=1
declare use_fs=0
while [ -n "${1}" ]; do
    if [ "${1}" == "--help" ]; then
        [ ! -f ~/.magetools/src/docs/deliver.txt ] && error_message "No help documentation found" && exit 1
        (cat ~/.magetools/src/docs/deliver.txt | less -c) && exit 0
    elif [ "${1}" == "--branch" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "branch must be defined" && exit 1
        target_branch="${2}" && shift
    elif [ "${1}" == "--name" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "name must be defined" && exit 1
        env_name=$(echo "${2}" | sed -e "s| |-|") && shift
    elif [ "${1}" == "--no-git" ]; then
        must_pull_repo=0
    elif [ "${1}" == "--no-force-pull" ]; then
        must_force_pull=0
    elif [ "${1}" == "--no-deps" ]; then
        must_install_deps=0
    elif [ "${1}" == "--no-upgrade" ]; then
        must_upgrade=0
    elif [ "${1}" == "--no-refresh" ]; then
        must_refresh=0
    elif [ "${1}" == "--no-enable-maintenance" ]; then
        must_enable_maintenance=0
    elif [ "${1}" == "--no-disable-maintenance" ]; then
        must_disable_maintenance=0
    elif [ "${1}" == "--with-fs" ]; then
        use_fs=1
    elif [ "${1}" == "--no-stash" ]; then
        use_stash=0
    fi
    shift
done

# Check bin/magento executor
[ ! -f bin/magento ] && error_message "No ${color_yellow}bin/magento${color_none} found to execute commands" && exit 1

# Upgrade git info
if [ ${must_pull_repo} -eq 1 ]; then
    git fetch
    [ -n "$(git remote 2>/dev/null | grep origin)" ] && has_remote_origin=1
    [ ${has_remote_origin} -eq 1 ] && git remote prune origin
fi

# Stash current changes
if [ ${use_stash} -eq 1 ]; then
    git status -s
    [ ${?} -ne 0 ] && error_message "Can't get current git status" && exit 1
    [ -n "$(git stash list)" ] && error_message "Can't create a new stash if there is an existent one" && exit 1
    git stash push -u
    [ ${?} -ne 0 ] && error_message "Can't stash current changes" && exit 1
fi

# Enable maintenance
if [ ${must_enable_maintenance} -eq 1 ]; then
    bin/magento maintenance:enable
    [ ${?} -ne 0 ] && error_message "Can't enable maintenance mode" && exit 1
fi

# Initial cache flush
if [ ${must_refresh} -eq 1 ]; then
    bin/magento cache:flush
    [ ${?} -ne 0 ] && error_message "Can't flush cache" && exit 1
fi

# Switch to target branch
if [ -n "${target_branch}" ]; then
    git switch "${target_branch}"
    [ ${?} -ne 0 ] && error_message "Can't switch to branch with name ${target_branch}" && exit 1
fi

# Pull changes from origin
if [ -n "${target_branch}" ] && [ ${must_pull_repo} -eq 1 ] && [ ${has_remote_origin} -eq 1 ]; then
    if [ ${must_force_pull} -eq 1 ]; then
        git reset --hard "origin/${target_branch}"
        [ ${?} -ne 0 ] && error_message "Can't force pull branch ${target_branch} from origin" && exit 1
    else
        git pull
        [ ${?} -ne 0 ] && error_message "Can't pull branch ${target_branch} from origin" && exit 1
    fi
fi

# Update composer dependencies
if [ ${must_install_deps} -eq 1 ]; then
    composer install --no-plugins --no-scripts
    [ ${?} -ne 0 ] && error_message "Can't update composer dependencies" && exit 1
    git restore .
    [ ${?} -ne 0 ] && error_message "Can't restore no commited changes after dependencies update" && exit 1
fi

# Restore changes from stash
if [ ${use_stash} -eq 1 ] && [ -n "$(git stash list)" ]; then
    git stash pop
    [ ${?} -ne 0 ] && error_message "Can't restore changes from stash" && exit 1
fi

# Unlink cache folders
if [ ${use_fs} -eq 1 ]; then
    rm -rfv var/cache/*
    rm -rfv var/cache
    rm -rfv var/page_cache/*
    rm -rfv var/page_cache
    rm -rfv pub/static/_cache/*
    rm -rfv pub/static/_cache
fi

# Clean folders
rm -rfv var/view_preprocessed/*
rm -rfv pub/static/*/*
rm -rfv generated/*/*

# Upgrade config
if [ ${must_upgrade} -eq 1 ]; then
    bin/magento app:config:import --no-interaction
    [ ${?} -ne 0 ] && echo "ERR~ Can't import app config" && exit 1
    bin/magento setup:upgrade --no-interaction
    [ ${?} -ne 0 ] && error_message "Can't upgrade app config" && exit 1
fi

# Link cache folders
if [ ${use_fs} -eq 1 ]; then
    [ -d var/cache ] && rm -rfv var/cache
    ln -v -s /magento-app/${env_name}/fs/var/cache /magento-app/${env_name}/site/var/
    [ -d var/page_cache ] && rm -rfv var/page_cache
    ln -v -s /magento-app/${env_name}/fs/var/page_cache /magento-app/${env_name}/site/var/
    [ -d pub/static/_cache ] && rm -rfv pub/static/_cache
    ln -v -s /magento-app/${env_name}/fs/pub/static/_cache /magento-app/${env_name}/site/pub/static/
fi

# Reindex and flush cache
if [ ${must_refresh} -eq 1 ]; then
    bin/magento indexer:reset
    [ ${?} -ne 0 ] && echo "ERR~ Can't reset indexers" && exit 1
    bin/magento indexer:reindex
    [ ${?} -ne 0 ] && error_message "Can't execute reindex operation" && exit 1
    bin/magento cache:flush
    [ ${?} -ne 0 ] && error_message "Can't flush cache" && exit 1
fi

# Disable maintenance
if [ ${must_disable_maintenance} -eq 1 ]; then
    bin/magento maintenance:disable
    [ ${?} -ne 0 ] && error_message "Can't disable maintenance mode" && exit 1
fi

# End script
exit 0
