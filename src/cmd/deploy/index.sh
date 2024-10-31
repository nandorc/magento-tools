#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Declare global variables
declare cmd_name="deploy"
declare env_name=$(bash ~/.magetools/src/scripts/get-env-name.sh ${@})
declare has_git=1
declare git_has_remote=0
declare git_use_stash
declare git_pull_mode
declare git_deploy_branch
declare m2_use_cron
declare m2_install_deps
declare m2_build_files
declare m2_build_languages
declare m2_upgrade
declare m2_reindex
declare m2_clean_folders
declare m2_flush_cache
declare m2_enable_maintenance
declare m2_disable_maintenance

# Fragment: show-help
source ~/.magetools/src/fragments/show-help.sh

# Validate env vars file and env folder
[ ! -f ~/.magetools/var/vars-${env_name}.sh ] && error_message "Vars file not found for env named ${color_yellow}${env_name}${color_none}" && exit 1
[ ! -d /magento-app/${env_name} ] && error_message "Main folder not found for env named ${color_yellow}${env_name}${color_none}" && exit 1

# Load env variables
source ~/.magetools/var/vars-${env_name}.sh

# Fragment: validate-options
source ~/.magetools/src/fragments/validate-options.sh

# Set fallback values
[ -z "${git_use_stash}" ] && git_use_stash=0
[ -z "${git_pull_mode}" ] && git_pull_mode="hard"
[ -z "${git_deploy_branch}" ] && git_deploy_branch=""
[ -z "${m2_use_cron}" ] && m2_use_cron=1
[ -z "${m2_install_deps}" ] && m2_install_deps=1
[ -z "${m2_build_files}" ] && m2_build_files=1
[ -z "${m2_build_languages}" ] && m2_build_languages=""
[ -z "${m2_upgrade}" ] && m2_upgrade=1
[ -z "${m2_reindex}" ] && m2_reindex=1
[ -z "${m2_clean_folders}" ] && m2_clean_folders=1
[ -z "${m2_flush_cache}" ] && m2_flush_cache=1
[ -z "${m2_enable_maintenance}" ] && m2_enable_maintenance=1
[ -z "${m2_disable_maintenance}" ] && m2_disable_maintenance=1

# Move to site directory
[ ! -d /magento-app/${env_name}/site ] && error_message "Site folder not found for env named ${color_yellow}${env_name}${color_none}" && exit 1
cd /magento-app/${env_name}/site

# Check bin/magento executor
[ ! -f bin/magento ] && error_message "No bin/magento found to execute commands" && exit 1

# Check if git repo
[ ! -d .git ] && has_git=0

# Upgrade git info
if [ ${has_git} -eq 1 ]; then
    git fetch
    [ -n "$(git remote 2>/dev/null | grep origin)" ] && git_has_remote=1
    [ ${git_has_remote} -eq 1 ] && git remote prune origin
fi

# Enable maintenance
if [ ${m2_enable_maintenance} -eq 1 ]; then
    bin/magento maintenance:enable
    [ ${?} -ne 0 ] && error_message "Can't enable maintenance mode" && exit 1
fi

# Remove crontab
if [ ${m2_use_cron} -eq 1 ]; then
    bin/magento cron:remove
    [ ${?} -ne 0 ] && error_message "Can't remove crontab" && exit 1
fi

# Initial cache flush
if [ ${m2_flush_cache} -eq 1 ]; then
    bin/magento cache:flush
    [ ${?} -ne 0 ] && error_message "Can't flush cache" && exit 1
fi

# Switch to target branch
if [ ${has_git} -eq 1 ] && [ -n "${git_deploy_branch}" ]; then
    git switch "${git_deploy_branch}"
    [ ${?} -ne 0 ] && error_message "Can't switch to branch with name ${git_deploy_branch}" && exit 1
fi

# Show current git status
if [ ${has_git} -eq 1 ]; then
    git status
    [ ${?} -ne 0 ] && error_message "Can't get current git status" && exit 1
fi

# Pull changes from origin
if [ ${has_git} -eq 1 ] && [ ${git_has_remote} -eq 1 ] && [ -n "${git_deploy_branch}" ]; then
    if [ -n "$(git status -s)" ]; then
        [ ${git_use_stash} -eq 0 ] && error_message "Can't pull data. Pending data to commit found in repo. Review env files or set git_use_stash param to 1 or use --use-stash flag to try to save and re-apply pending changes." && exit 1
        [ -n "$(git stash list)" ] && error_message "Can't create a new stash if there is an existent one" && exit 1
        git stash push -u
        [ ${?} -ne 0 ] && error_message "Can't stash current changes" && exit 1
    fi
    if [ "${git_pull_mode}" == "hard" ]; then
        git reset --hard "origin/${git_deploy_branch}"
        [ ${?} -ne 0 ] && error_message "Can't force pull branch ${git_deploy_branch} from origin" && exit 1
    elif [ "${git_pull_mode}" == "soft" ]; then
        git pull
        [ ${?} -ne 0 ] && error_message "Can't pull branch ${git_deploy_branch} from origin" && exit 1
    fi
    if [ ${git_use_stash} -eq 1 ] && [ -n "$(git stash list)" ]; then
        git stash pop
        [ ${?} -ne 0 ] && error_message "Can't restore changes from stash" && exit 1
    fi
fi

# Clean folders
if [ ${m2_clean_folders} -eq 1 ]; then
    rm -rfv var/view_preprocessed/*
    rm -rfv pub/static/*/*
    rm -rfv generated/*/*
fi

# Update composer dependencies
if [ ${m2_install_deps} -eq 1 ]; then
    composer install --no-plugins --no-scripts --no-dev
    [ ${?} -ne 0 ] && error_message "Can't update composer dependencies" && exit 1
fi

# Build files
if [ ${m2_build_files} -eq 1 ]; then
    bin/magento setup:di:compile
    [ ${?} -ne 0 ] && error_message "Can't generate dynamic classes" && exit 1
    bin/magento setup:static-content:deploy --jobs=3 -f ${m2_build_languages}
    [ ${?} -ne 0 ] && error_message "Can't generate static content" && exit 1
fi

# Optimize composer dependencies
if [ ${m2_install_deps} -eq 1 ]; then
    composer install --no-plugins --no-scripts --no-dev --apcu-autoloader --optimize-autoloader
    [ ${?} -ne 0 ] && error_message "Can't update composer dependencies" && exit 1
fi

# Upgrade config
if [ ${m2_upgrade} -eq 1 ]; then
    bin/magento app:config:import --no-interaction
    [ ${?} -ne 0 ] && echo "ERR~ Can't import app config" && exit 1
    bin/magento setup:upgrade --no-interaction --keep-generated
    [ ${?} -ne 0 ] && error_message "Can't upgrade app config" && exit 1
fi

# Reindex and flush cache
if [ ${m2_reindex} -eq 1 ]; then
    bin/magento indexer:reset
    [ ${?} -ne 0 ] && echo "ERR~ Can't reset indexers" && exit 1
    bin/magento indexer:reindex
    [ ${?} -ne 0 ] && error_message "Can't execute reindex operation" && exit 1
fi

# Final cache flush
if [ ${m2_flush_cache} -eq 1 ]; then
    bin/magento cache:flush
    [ ${?} -ne 0 ] && error_message "Can't flush cache" && exit 1
fi

# Reinstall crontab
if [ ${m2_use_cron} -eq 1 ]; then
    bin/magento cron:install -f
    [ ${?} -ne 0 ] && error_message "Can't re-install crontab" && exit 1
fi

# Disable maintenance
if [ ${m2_disable_maintenance} -eq 1 ]; then
    bin/magento maintenance:disable
    [ ${?} -ne 0 ] && error_message "Can't disable maintenance mode" && exit 1
fi

# End script
exit 0
