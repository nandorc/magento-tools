#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Declare global variables
cmd_name="env:switch"
env_name=$(bash ${path_scripts}/get-env-name.sh ${@})

# Fragment: command-init-vars
source ${path_fragments}/command-init-vars.sh

# Fragment: define-nginx-vhost-vars
source ${path_fragments}/define-nginx-vhost-vars.sh

# Check host file
if [ -L ${nginx_vhost_enabled_file} ]; then
    info_message "${env_name} is the current active host" 
    [ ${cmd_use_force} -eq 0 ] && exit 0
elif [ ! -f ${nginx_vhost_available_file} ]; then
    error_message "${env_name} host does not exists" && exit 1
fi

# Replicate and clean nginx conf file
rm -rfv ${path_env}/${env_name}/nginx.conf
if [ -f ${path_env}/${env_name}/site/nginx.conf ]; then
    cp -v ${path_env}/${env_name}/site/nginx.conf ${path_env}/${env_name}/nginx.conf
else
    cp -v ${path_templates}/nginx.conf.sample ${path_env}/${env_name}/nginx.conf
fi
if [ ${system_webserver_https} -eq 0 ]; then
    sed -i -e "/HTTPS \"on\"/d" ${path_env}/${env_name}/nginx.conf
    sed -i -e "/HTTP_X_FORWARDED_PROTO \"https\"/d" ${path_env}/${env_name}/nginx.conf
fi

# Create nginx vhost file
[ -z "${system_php_version}" ] && error_message "PHP version must be defined" && exit 1
sudo rm -rfv ${nginx_vhost_enabled_file} ${nginx_vhost_available_file}
sudo cp -v ${path_templates}/magento-vhost.sample ${nginx_vhost_available_file}
sudo chown -v root:root ${nginx_vhost_available_file}
sudo sed -i -e "s|%PHP_VERSION%|${system_php_version}|" ${nginx_vhost_available_file}
sudo sed -i -e "s|%M2_SITE_ROOT%|${path_env}/${env_name}/site|" ${nginx_vhost_available_file}
sudo sed -i -e "s|%M2_NGINX_FILE%|${path_env}/${env_name}/nginx.conf|" ${nginx_vhost_available_file}

# Enable host
sudo rm -rfv ${nginx_vhost_enabled_path}/${nginx_vhost_file_prefix}*
sudo ln -v -s ${nginx_vhost_available_file} ${nginx_vhost_enabled_path}/
sudo service nginx restart
sudo service "php${system_php_version}-fpm" restart

# End script
exit 0
