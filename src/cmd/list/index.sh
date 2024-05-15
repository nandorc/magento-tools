#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Get docs list
declare docs=$(ls ~/.magetools/src/docs)

# Display commands list
declare doc=
declare cmd=
info_message "Available commands"
for doc in ${docs[@]}; do
    cmd=$(echo ${doc} | sed -e "s|\.txt||")
    custom_message "    - ${cmd}"
done
custom_message "\n$(info_message "Type ${color_yellow}mage <command> --help${color_none} to get more info about the command")"

# End script
exit 0
