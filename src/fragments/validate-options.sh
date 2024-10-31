#!/bin/bash

# Map options to variables
while [ -n "$(echo "${1}" | grep "^-")" ]; do
    if [ "${1}" == "--help" ]; then
        use_help=1
    elif [ "${1}" == "--name" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "name must be defined" && exit 1
        env_name=$(echo "${2}" | sed -e "s| |-|") && shift
    elif [ "${1}" == "--branch" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "branch must be defined" && exit 1
        git_deploy_branch="${2}" && shift
    elif [ "${1}" == "--use-stash" ]; then
        git_use_stash=1
    elif [ "${1}" == "--pull-mode" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "pull-mode must be defined" && exit 1
        [ "${2}" != "none" ] && [ "${2}" != "soft" ] && [ "${2}" != "hard" ] && error_message "pull-mode must be \"none\", \"soft\" or \"hard\"" && exit 1
        git_pull_mode="${2}" && shift
    elif [ "${1}" == "--no-cron" ]; then
        m2_use_cron=0
    elif [ "${1}" == "--no-deps" ]; then
        m2_install_deps=0
    elif [ "${1}" == "--no-build" ]; then
        m2_build_files=0
    elif [ "${1}" == "--languages" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "languages must be defined like this\"es_ES en_US\"" && exit 1
        m2_build_languages="${2}" && shift
    elif [ "${1}" == "--no-upgrade" ]; then
        m2_upgrade=0
    elif [ "${1}" == "--no-reindex" ]; then
        m2_reindex=0
    elif [ "${1}" == "--no-clean-folders" ]; then
        m2_clean_folders=0
    elif [ "${1}" == "--no-cache-flush" ]; then
        m2_flush_cache=0
    elif [ "${1}" == "--no-enable-maintenance" ]; then
        m2_enable_maintenance=0
    elif [ "${1}" == "--no-disable-maintenance" ]; then
        m2_disable_maintenance=0
    fi
    shift
done
