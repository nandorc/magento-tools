#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Check help flag
if [ "${1}" == "--help" ]; then
    [ ! -f ~/.magetools/src/docs/env:create-vars.txt ] && error_message "No help documentation found" && exit 1
    (cat ~/.magetools/src/docs/env:create-vars.txt | less -c) && exit 0
fi

# Check if file exists
[ -f ./vars-"${1}".sh ] && error_message "Vars file with name ${color_yellow}vars-${1}.sh${color_none} already exists in current directory" && exit 1

# Copy new file
cp -v ~/.magetools/src/templates/vars.sh.sample ./vars-"${1}".sh

# End process
exit 0
