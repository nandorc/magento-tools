#!/bin/bash

# Fragment: command-init-vars
source ${path_fragments}/command-init-vars.sh

# Move to site directory
[ ! -d ${path_env}/${env_name}/site ] && error_message "Site folder not found for env named ${color_yellow}${env_name}${color_none}" && exit 1
cd ${path_env}/${env_name}/site
