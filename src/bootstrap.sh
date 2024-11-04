#!/bin/bash

# Declare super global variables
path_root=~/.magetools
path_env=/magento-app
path_src=${path_root}/src
path_var=${path_root}/var
path_cmd=${path_src}/cmd
path_docs=${path_src}/docs
path_fragments=${path_src}/fragments
path_scripts=${path_src}/scripts
path_templates=${path_src}/templates
path_utils=${path_src}/utils

# Load messages wrapper
source ${path_utils}/messages.sh
[ ${?} -ne 0 ] && echo "ERR~ Messages dependency not found" && exit 1

# Validate integrity of global options
function test_options_integrity {
    # Fragment: validate-options
    source ${path_fragments}/validate-options.sh
}
test_options_integrity ${@}
