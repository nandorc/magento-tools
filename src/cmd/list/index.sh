#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Get docs list
available_commands=$(ls ~/.magetools/src/docs)

# Display commands list
info_message "Available commands"
for available_command in ${available_commands[@]}; do
    cmd=$(echo ${available_command} | sed -e "s|\.txt||")
    custom_message "    - ${cmd}"
done
custom_message "\n$(info_message "Type ${color_yellow}mage <command> --help${color_none} to get more info about the command")"

# End script
exit 0
