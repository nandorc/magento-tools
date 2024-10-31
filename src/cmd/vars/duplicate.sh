#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Check help flag
if [ "${1}" == "--help" ]; then
    [ ! -f ~/.magetools/src/docs/vars:duplicate.txt ] && error_message "No help documentation found" && exit 1
    (cat ~/.magetools/src/docs/vars:duplicate.txt | less -c) && exit 0
fi

# Check final args
[ ${#} -ne 2 ] && error_message "Syntax error when executing ${color_yellow}vars:duplicate${color_none} type ${color_yellow}mage vars:duplicate --help${color_none} to see the right syntax" && exit 1

# Check env names
[ -z "${1}" ] && error_message "Env origin name must be provided" && exit 1
[ -z "${2}" ] && error_message "Env target name must be provided" && exit 1

# Check if file exists
[ ! -f ~/.magetools/var/vars-"${1}".sh ] && error_message "Vars file for origin env with name ${color_yellow}${1}${color_none} does not exists" && exit 1

# Copy content of origin to target vars file
cp -v ~/.magetools/var/vars-"${1}".sh ~/.magetools/var/vars-"${2}".sh

# End process
exit 0
