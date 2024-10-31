#!/bin/bash

# Validate command name
[ -z "${cmd_name}" ] && error_message "No command name defined" && exit 1

# Check use_help flag
declare use_help=$(bash ~/.magetools/src/scripts/get-use-help.sh ${@})

# Validate help flag
if [ ${use_help} -eq 1 ]; then
    declare help_file_location=~/.magetools/src/docs/${cmd_name}.txt
    [ ! -f ${help_file_location} ] && error_message "No help documentation found" && exit 1
    (cat ${help_file_location} | less -c) && exit 0
fi
