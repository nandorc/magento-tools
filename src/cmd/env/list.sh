#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Declare variables
declare cmd_name="env:list"
declare docs=$(find /magento-app -maxdepth 4 -type f -name magento)
declare doc
declare cmd

# Fragment: show-help
source ~/.magetools/src/fragments/show-help.sh

# Display commands list
info_message "Available envs"
for doc in ${docs[@]}; do
    cmd=$(echo ${doc} | sed -e "s|/magento-app/||" | sed -e "s|/site/bin/magento||")
    custom_message "    - ${cmd}"
done

# End script
exit 0
