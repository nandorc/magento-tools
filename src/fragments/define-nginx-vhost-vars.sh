#!/bin/bash

# Define nginx vhost paths
nginx_vhost_file_prefix="00-magento-"
nginx_vhost_file_name="${nginx_vhost_file_prefix}${env_name}"
nginx_vhost_enabled_path="/etc/nginx/sites-enabled"
nginx_vhost_enabled_file="${nginx_vhost_enabled_path}/${nginx_vhost_file_name}"
nginx_vhost_available_path="/etc/nginx/sites-available"
nginx_vhost_available_file="${nginx_vhost_available_path}/${nginx_vhost_file_name}"
