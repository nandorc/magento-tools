#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Get docs list
declare docs=$(ls ~/.magetools/src/docs)

# Display commands list
declare doc=
declare cmd=
echo -e "\nAvailable commands"
for doc in ${docs[@]}; do
    cmd=$(echo ${doc} | sed -e "s|\.txt||")
    echo -e "    - ${cmd}"
done
echo -e "\nType .tools/bin/mage <command> --help to get more info about the command\n"

# End script
exit 0
