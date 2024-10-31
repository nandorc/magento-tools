#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Declare variables
declare use_help=0

# Fragment: validate-options
source ~/.magetools/src/fragments/validate-options.sh

# Display use_help
echo ${use_help}

# End script
exit 0
