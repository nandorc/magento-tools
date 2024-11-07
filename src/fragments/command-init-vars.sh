#!/bin/bash

# Fragment: show-help
source ${path_fragments}/show-help.sh

# Load env variables
[ ! -f ${path_var}/vars-${env_name}.sh ] && error_message "Vars file not found for env named ${color_yellow}${env_name}${color_none}" && exit 1
source ${path_var}/vars-${env_name}.sh

# Fragment: validate-options
source ${path_fragments}/validate-options.sh
