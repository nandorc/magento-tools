#!/bin/bash

# Fragment: show-help
source ${path_fragments}/show-help.sh

# Validate env vars file and env folder
[ ! -f ${path_var}/vars-${env_name}.sh ] && error_message "Vars file not found for env named ${color_yellow}${env_name}${color_none}" && exit 1
[ ! -d ${path_env}/${env_name} ] && error_message "Main folder not found for env named ${color_yellow}${env_name}${color_none}" && exit 1

# Load env variables
source ${path_var}/vars-${env_name}.sh

# Fragment: validate-options
source ${path_fragments}/validate-options.sh

# Move to site directory
[ ! -d ${path_env}/${env_name}/site ] && error_message "Site folder not found for env named ${color_yellow}${env_name}${color_none}" && exit 1
cd ${path_env}/${env_name}/site
