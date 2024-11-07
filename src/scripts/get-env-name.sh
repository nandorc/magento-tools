#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Fragment: validate-options
source ${path_fragments}/validate-options.sh

# Set env_name
env_name="${1}"
[ -z "${env_name}" ] && env_name="default"
env_name=$(echo "${env_name}" | sed -e "s| |-|")

# Display env_name
echo ${env_name}

# End script
exit 0
