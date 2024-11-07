#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Declare global variables
cmd_name="vars:delete"

# Fragment: show-help
source ${path_fragments}/show-help.sh

# Check final args
[ ${#} -ne 1 ] && [ ${#} -ne 0 ] && error_message "Syntax error when executing ${color_yellow}${cmd_name}${color_none} type ${color_yellow}mage ${cmd_name} --help${color_none} to see the right syntax" && exit 1

# Set env_name
env_name="${1}"
[ -z "${env_name}" ] && env_name="default"
env_name=$(echo "${env_name}" | sed -e "s| |-|")

# Confirm remove action
info_message "Do you want to remove vars for env named ${color_yellow}${env_name}${color_none}?"
select cmd_yn_confirmation in "Yes" "No"; do
    if [ "${cmd_yn_confirmation}" == "Yes" ]; then
        cmd_continue=1 && break
    elif [ "${cmd_yn_confirmation}" == "No" ]; then
        cmd_continue=0 && break
    fi
done
[ ${cmd_continue} -eq 0 ] && exit 0

# Check if file exists
[ ! -f ${path_var}/vars-"${1}".sh ] && error_message "Vars file for env with name ${color_yellow}${env_name}${color_none} does not exists" && exit 1

# Delete vars file
rm -rfv ${path_var}/vars-"${env_name}".sh

# End process
exit 0
