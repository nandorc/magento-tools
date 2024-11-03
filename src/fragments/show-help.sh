#!/bin/bash

# Validate command name
[ -z "${cmd_name}" ] && error_message "No command name defined" && exit 1

# Check use_help flag
cmd_use_help=$(bash ~/.magetools/src/scripts/get-use-help.sh ${@})

# Validate help flag
if [ ${cmd_use_help} -eq 1 ]; then
    cmd_help_file_location=~/.magetools/src/docs/${cmd_name}.txt
    [ ! -f ${cmd_help_file_location} ] && error_message "No help documentation found for ${color_yellow}${cmd_name}${color_none} command" && exit 1
    (cat ${cmd_help_file_location} | less -c) && exit 0
fi
