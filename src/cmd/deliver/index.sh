#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Declare global variables
cmd_name="deliver"
env_name=$(bash ${path_scripts}/get-env-name.sh ${@})

# Fragment: command-init
source ${path_fragments}/command-init.sh

# Check bin/magento executor
[ ! -f bin/magento ] && error_message "No bin/magento found to execute commands" && exit 1

# Fragment: validate-git
source ${path_fragments}/validate-git.sh

# Enable maintenance
if [ ${m2_enable_maintenance} -eq 1 ]; then
    bin/magento maintenance:enable
    [ ${?} -ne 0 ] && error_message "Can't enable maintenance mode" && exit 1
fi

# Initial cache flush
if [ ${m2_flush_cache} -eq 1 ]; then
    bin/magento cache:flush
    [ ${?} -ne 0 ] && error_message "Can't flush cache" && exit 1
fi

# Fragment: update-git
source ${path_fragments}/update-git.sh

# Clean folders
if [ ${m2_clean_folders} -eq 1 ]; then
    rm -rfv var/view_preprocessed/*
    rm -rfv pub/static/*/*
    rm -rfv generated/*/*
fi

# Update composer dependencies
if [ ${m2_install_deps} -eq 1 ]; then
    composer install --no-plugins --no-scripts
    [ ${?} -ne 0 ] && error_message "Can't update composer dependencies" && exit 1
fi

# Upgrade config
if [ ${m2_upgrade} -eq 1 ]; then
    bin/magento app:config:import --no-interaction
    [ ${?} -ne 0 ] && echo "ERR~ Can't import app config" && exit 1
    bin/magento setup:upgrade --no-interaction --keep-generated
    [ ${?} -ne 0 ] && error_message "Can't upgrade app config" && exit 1
fi

# Reindex data
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

# Disable maintenance
if [ ${m2_disable_maintenance} -eq 1 ]; then
    bin/magento maintenance:disable
    [ ${?} -ne 0 ] && error_message "Can't disable maintenance mode" && exit 1
fi

# End script
exit 0
