#!/bin/bash

# Load messages wrapper
source ~/.magetools/src/utils/messages.sh
[ ${?} -ne 0 ] && echo "ERR~ Messages dependency not found" && exit 1

# Validate integrity of global options
function test_options_integrity {
    # Fragment: validate-options
    source ~/.magetools/src/fragments/validate-options.sh
}
test_options_integrity ${@}
