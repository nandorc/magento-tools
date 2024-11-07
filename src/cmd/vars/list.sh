#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Declare global variables
cmd_name="vars:list"
available_vars=$(ls ${path_var})

# Fragment: show-help
source ${path_fragments}/show-help.sh

# Display commands list
info_message "Available env vars"
for available_var in ${available_vars[@]}; do
    cmd=$(echo ${available_var} | sed -e "s|\.sh||" | sed -e "s|vars-||")
    custom_message "    - ${cmd}"
done
custom_message "\n$(info_message "Type ${color_yellow}mage vars:edit <env_name>${color_none} to edit env vars")"

# End script
exit 0
