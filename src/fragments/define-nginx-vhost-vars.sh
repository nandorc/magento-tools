#!/bin/bash

# Define nginx vhost paths
nginx_vhost_file_name=00-magento-${env_name}
nginx_vhost_enabled_path=/etc/nginx/sites-enabled/${nginx_vhost_file_name}
nginx_vhost_available_path=/etc/nginx/sites-available/${nginx_vhost_file_name}
