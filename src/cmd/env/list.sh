#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Declare variables
cmd_name="env:list"
available_envs=$(find ${path_env} -maxdepth 4 -type f -name magento)

# Fragment: show-help
source ${path_fragments}/show-help.sh

# Display commands list
info_message "Available envs"
for available_env in ${available_envs[@]}; do
    env_name=$(echo ${available_env} | sed -e "s|/magento-app/||" | sed -e "s|/site/bin/magento||")
    custom_message "    - ${env_name}"
done

# End script
exit 0
