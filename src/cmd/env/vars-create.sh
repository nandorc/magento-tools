#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Check params
declare must_force=0
while [ "${1}" == "--help" ] || [ "${1}" == "--force" ]; do
    if [ "${1}" == "--help" ]; then
        [ ! -f ~/.magetools/src/docs/env:vars-create.txt ] && error_message "No help documentation found" && exit 1
        (cat ~/.magetools/src/docs/env:vars-create.txt | less -c) && exit 0
    elif [ "${1}" == "--force" ]; then
        must_force=1
        shift
    fi
done

# Check final args
[ ${#} -ne 1 ] && error_message "Syntax error when executing ${color_yellow}env:vars-create${color_none} type ${color_yellow}mage env:vars-create --help${color_none} to see the right syntax" && exit 1

# Check env name
[ -z "${1}" ] && error_message "Env name must be provided" && exit 1

# Check var directory
[ ! -d ~/.magetools/var ] && mkdir -vp ~/.magetools/var

# Check if file exists
if [ ${must_force} -eq 0 ]; then
    [ -f ~/.magetools/var/vars-"${1}".sh ] && error_message "Vars file for env with name ${color_yellow}${1}${color_none} already exists" && exit 1
else
    rm -rfv ~/.magetools/var/vars-"${1}".sh
fi

# Copy new file
cp -v ~/.magetools/src/templates/vars.sh.sample ~/.magetools/var/vars-"${1}".sh

# Open for edit new vars file
nano ~/.magetools/var/vars-"${1}".sh

# End process
exit 0
