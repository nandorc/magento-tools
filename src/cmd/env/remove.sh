#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Declare variables
cmd_name="env:remove"
env_name=$(bash ${path_scripts}/get-env-name.sh ${@})

# Fragment: show-help
source ${path_fragments}/show-help.sh

# Confirm remove action
info_message "Do you want to remove env named ${color_yellow}${env_name}${color_none}?"
select cmd_yn_confirmation in "Yes" "No"; do
    if [ "${cmd_yn_confirmation}" == "Yes" ]; then
        cmd_continue=1 && break
    elif [ "${cmd_yn_confirmation}" == "No" ]; then
        cmd_continue=0 && break
    fi
done
[ ${cmd_continue} -eq 0 ] && exit 0

# Remove env folder
sudo rm -rfv /magento-app/${env_name}
[ ${?} -ne 0 ] && error_message "Can't remove main env folder" && exit 1

# Fragment: define-nginx-vhost-vars
source ${path_fragments}/define-nginx-vhost-vars.sh

# Remove env vhost
sudo rm -rfv ${nginx_vhost_enabled_path} ${nginx_vhost_available_path}
[ ${?} -ne 0 ] && error_message "Can't remove env vhost file" && exit 1

# End script
exit 0
