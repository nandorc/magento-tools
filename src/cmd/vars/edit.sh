#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Declare global variables
cmd_name="vars:edit"

# Fragment: show-help
source ${path_fragments}/show-help.sh

# Check final args
[ ${#} -ne 1 ] && [ ${#} -ne 0 ] && error_message "Syntax error when executing ${color_yellow}${cmd_name}${color_none} type ${color_yellow}mage ${cmd_name} --help${color_none} to see the right syntax" && exit 1

# Set env_name
env_name="${1}"
[ -z "${env_name}" ] && env_name="default"
env_name=$(echo "${env_name}" | sed -e "s| |-|")

# Check if file exists
[ ! -f ${path_var}/vars-"${env_name}".sh ] && error_message "Vars file for env with name ${color_yellow}${env_name}${color_none} does not exists" && exit 1

# Open for edit new vars file
nano ${path_var}/vars-"${env_name}".sh

# End process
exit 0
