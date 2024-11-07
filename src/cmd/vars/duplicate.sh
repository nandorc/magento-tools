#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Declare global variables
cmd_name="vars:duplicate"

# Fragment: show-help
source ${path_fragments}/show-help.sh

# Fragment: validate-options
source ${path_fragments}/validate-options.sh

# Check final args
[ ${#} -ne 2 ] && error_message "Syntax error when executing ${color_yellow}${cmd_name}${color_none} type ${color_yellow}mage ${cmd_name} --help${color_none} to see the right syntax" && exit 1
env_name_origin="${1}"
env_name_target="${2}"

# Check env names
[ -z "${env_name_origin}" ] && error_message "Env origin name must be provided" && exit 1
env_name_origin=$(echo "${env_name_origin}" | sed -e "s| |-|")
[ -z "${env_name_target}" ] && error_message "Env target name must be provided" && exit 1
env_name_target=$(echo "${env_name_target}" | sed -e "s| |-|")

# Check if file exists
[ ! -f ${path_var}/vars-"${env_name_origin}".sh ] && error_message "Vars file for origin env with name ${color_yellow}${env_name_origin}${color_none} does not exists" && exit 1
if [ ${cmd_use_force} -eq 0 ]; then
    [ -f ${path_var}/vars-"${env_name_target}".sh ] && error_message "Vars file for target env with name ${color_yellow}${env_name_target}${color_none} already exists" && exit 1
fi

# Copy content of origin to target vars file
rm -rfv ${path_var}/vars-"${env_name_target}".sh
cp -v ${path_var}/vars-"${env_name_origin}".sh ${path_var}/vars-"${env_name_target}".sh

# End process
exit 0
