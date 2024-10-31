#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Declare variables
declare env_name="default"

# Fragment: validate-options
source ~/.magetools/src/fragments/validate-options.sh

# Display env_name
echo ${env_name}

# End script
exit 0
