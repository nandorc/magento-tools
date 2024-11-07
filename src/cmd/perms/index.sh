#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Declare variables
cmd_name="perms"

# Fragment: show-help
source ${path_fragments}/show-help.sh

# Check paths
if [ -z "${*}" ]; then
    selected_paths=(".")
else
    selected_paths=(${*})
fi
for selected_path in "${selected_paths[@]}"; do
    [ ! -d "${selected_path}" ] && error_message "Path ${color_yellow}${selected_path}${color_none} is not a directory" && exit 1
    [ ! -f "${selected_path}/bin/magento" ] && error_message "Path ${color_yellow}${selected_path}${color_none} is not a Magento project" && exit 1
done

# Apply permissions
for selected_path in "${selected_paths[@]}"; do
    sudo chown -R -v :www-data "${selected_path}"
    sudo find "${selected_path}" -type f ! -perm 0664 -exec chmod -v 0664 {} +
    sudo find "${selected_path}" -type d ! -perm 2775 -exec chmod -v 2775 {} +
    bin_folders=("bin" "vendor/bin" "node_modules/.bin")
    for bin_folder in ${bin_folders[@]}; do
        [ -d "${selected_path}/${bin_folder}" ] && sudo chmod -v +x ${selected_path}/${bin_folder}/*
    done
done

# End script
exit 0
