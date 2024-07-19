#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Check help flag
if [ "${1}" == "--help" ]; then
    [ ! -f ~/.magetools/src/docs/env:vars-delete.txt ] && error_message "No help documentation found" && exit 1
    (cat ~/.magetools/src/docs/env:vars-delete.txt | less -c) && exit 0
fi

# Check final args
[ ${#} -ne 1 ] && error_message "Syntax error when executing ${color_yellow}env:vars-delete${color_none} type ${color_yellow}mage env:vars-delete --help${color_none} to see the right syntax" && exit 1

# Check env name
[ -z "${1}" ] && error_message "Env name must be provided" && exit 1

# Check if file exists
[ ! -f ~/.magetools/var/vars-"${1}".sh ] && error_message "Vars file for env with name ${color_yellow}${1}${color_none} does not exists" && exit 1

# Open for edit new vars file
rm -rfv ~/.magetools/var/vars-"${1}".sh

# End process
exit 0
