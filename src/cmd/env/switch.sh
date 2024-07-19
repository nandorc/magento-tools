#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Check help flag
if [ "${1}" == "--help" ]; then
    [ ! -f ~/.magetools/src/docs/env:switch.txt ] && error_message "No help documentation found" && exit 1
    (cat ~/.magetools/src/docs/env:switch.txt | less -c) && exit 0
fi

# Get env name
declare env_name=${1}
[ -z "${env_name}" ] && error_message "env_name must be provided" && exit 1
env_name=$(echo "${env_name}" | sed -e "s| |-|")

# Declare and load env app variables
declare php_version=8.3
[ ! -f ~/.magetools/var/vars-"${env_name}".sh ] && error_message "Can't find vars file for env with name ${color_yellow}${env_name}${color_none}" && exit 1
source ~/.magetools/var/vars-"${env_name}".sh

# Check host file
declare must_change_host=0
declare hostfile_name=00-magento-${env_name}
declare enabled_host_path=/etc/nginx/sites-enabled
declare available_host_path=/etc/nginx/sites-available
if [ -L "${enabled_host_path}/${hostfile_name}" ]; then
    info_message "${env_name} is the current active host"
elif [ ! -f "${available_host_path}/${hostfile_name}" ]; then
    error_message "${env_name} host does not exists" && exit 1
else
    must_change_host=1
fi

if [ ${must_change_host} -eq 1 ]; then
    # Replicate and clean nginx conf file
    declare nginx_file_name=
    if [ -f /magento-app/${env_name}/site/nginx.conf ]; then
        nginx_file_name=nginx.conf
    elif [ -f /magento-app/${env_name}/site/nginx.conf.sample ]; then
        nginx_file_name=nginx.conf.sample
    else
        error_message "Can't find nginx conf at ${color_yellow}/magento-app/${env_name}/site${color_none}" && exit 1
    fi
    rm -rfv /magento-app/${env_name}/nginx.conf
    cp -v /magento-app/${env_name}/site/${nginx_file_name} /magento-app/${env_name}/nginx.conf
    sed -i -e "/HTTPS \"on\"/d" /magento-app/${env_name}/nginx.conf
    sed -i -e "/HTTP_X_FORWARDED_PROTO \"https\"/d" /magento-app/${env_name}/nginx.conf

    # Enable host
    sudo rm -rfv ${enabled_host_path}/00-magento*
    sudo ln -v -s ${available_host_path}/${hostfile_name} ${enabled_host_path}/
    sudo service nginx restart
    sudo service "php${php_version}-fpm" restart
fi

# End script
exit 0
