#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Declare global variables
cmd_name="vars:create"

# Fragment: show-help
source ${path_fragments}/show-help.sh

# Fragment: validate-options
source ${path_fragments}/validate-options.sh

# Check final args
[ ${#} -ne 1 ] && [ ${#} -ne 0 ] && error_message "Syntax error when executing ${color_yellow}${cmd_name}${color_none} type ${color_yellow}mage ${cmd_name} --help${color_none} to see the right syntax" && exit 1

# Set env_name
env_name="${1}"
[ -z "${env_name}" ] && env_name="default"
env_name=$(echo "${env_name}" | sed -e "s| |-|")

# Check var directory
[ ! -d ${path_var} ] && mkdir -vp ${path_var}

# Check if file exists
if [ ${cmd_use_force} -eq 0 ]; then
    [ -f ${path_var}/vars-"${env_name}".sh ] && error_message "Vars file for env with name ${color_yellow}${env_name}${color_none} already exists" && exit 1
else
    rm -rfv ${path_var}/vars-"${env_name}".sh
fi

# Copy new file
cp -v ${path_templates}/vars.sh.sample ${path_var}/vars-"${env_name}".sh

# Open for edit new vars file
nano ${path_var}/vars-"${env_name}".sh

# End process
exit 0
