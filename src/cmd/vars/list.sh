#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Check help flag
if [ "${1}" == "--help" ]; then
    [ ! -f ~/.magetools/src/docs/vars:list.txt ] && error_message "No help documentation found" && exit 1
    (cat ~/.magetools/src/docs/vars:list.txt | less -c) && exit 0
fi

# Get envs list
declare docs=$(ls ~/.magetools/var)

# Display commands list
declare doc=
declare cmd=
info_message "Available envs"
for doc in ${docs[@]}; do
    cmd=$(echo ${doc} | sed -e "s|\.sh||" | sed -e "s|vars-||")
    custom_message "    - ${cmd}"
done
custom_message "\n$(info_message "Type ${color_yellow}mage vars:edit <env_name>${color_none} to edit env vars")"

# End script
exit 0
