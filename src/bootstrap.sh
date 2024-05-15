#!/bin/bash

# Load messages wrapper
source ~/.magetools/src/utils/messages.sh
[ ${?} -ne 0 ] && echo "ERR~ Messages dependency not found" && exit 1
