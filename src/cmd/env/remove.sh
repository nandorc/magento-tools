#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Declare variables
declare cmd_name="env:remove"
declare cmd_yn_confirmation
declare cmd_continue
declare env_name=$(bash ~/.magetools/src/scripts/get-env-name.sh ${@})
declare nginx_vhost_enabled_path
declare nginx_vhost_available_path

# Fragment: show-help
source ~/.magetools/src/fragments/show-help.sh

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

# Fragment: define-nginx-vhost-vars
source ~/.magetools/src/fragments/define-nginx-vhost-vars.sh

# Remove env vhost
sudo rm -rfv ${nginx_vhost_enabled_path} ${nginx_vhost_available_path}

# End script
exit 0
