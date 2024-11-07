#!/bin/bash

# Map options to variables
while [ -n "$(echo "${1}" | grep "^-")" ]; do
    if [ "${1}" == "--help" ]; then
        cmd_use_help=1
    elif [ "${1}" == "--force" ]; then
        cmd_use_force=1
    elif [ "${1}" == "--fallback-user" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "fallback-user not defined" && exit 1
        system_fallback_user="${2}" && shift
    elif [ "${1}" == "--php-version" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "php-version not defined" && exit 1
        system_php_version="${2}" && shift
    elif [ "${1}" == "--webserver-https" ]; then
        system_webserver_https=1
    elif [ "${1}" == "--branch" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "branch not defined" && exit 1
        git_deploy_branch="${2}" && shift
    elif [ "${1}" == "--pull-mode" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "pull-mode not defined" && exit 1
        git_pull_mode="${2}" && shift
    elif [ "${1}" == "--use-stash" ]; then
        git_use_stash=1
    elif [ "${1}" == "--setup-user-name" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-user-name not defined" && exit 1
        git_setup_user_name="${2}" && shift
    elif [ "${1}" == "--setup-user-email" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-user-email not defined" && exit 1
        git_setup_user_email="${2}" && shift
    elif [ "${1}" == "--setup-origin-protocol" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-origin-protocol not defined" && exit 1
        git_setup_origin_protocol="${2}" && shift
    elif [ "${1}" == "--setup-origin-user" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-origin-user not defined" && exit 1
        git_setup_origin_user="${2}" && shift
    elif [ "${1}" == "--setup-origin-key" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-origin-key not defined" && exit 1
        git_setup_origin_key="${2}" && shift
    elif [ "${1}" == "--setup-origin-host" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-origin-key not defined" && exit 1
        git_setup_origin_host="${2}" && shift
    elif [ "${1}" == "--setup-origin-branch" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-origin-branch not defined" && exit 1
        git_setup_origin_branch="${2}" && shift
    elif [ "${1}" == "--no-build" ]; then
        m2_build_files=0
    elif [ "${1}" == "--languages" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "languages not defined" && exit 1
        m2_build_languages="${2}" && shift
    elif [ "${1}" == "--no-clean-folders" ]; then
        m2_clean_folders=0
    elif [ "${1}" == "--no-disable-maintenance" ]; then
        m2_disable_maintenance=0
    elif [ "${1}" == "--no-enable-maintenance" ]; then
        m2_enable_maintenance=0
    elif [ "${1}" == "--no-cache-flush" ]; then
        m2_flush_cache=0
    elif [ "${1}" == "--no-deps" ]; then
        m2_install_deps=0
    elif [ "${1}" == "--no-reindex" ]; then
        m2_reindex=0
    elif [ "${1}" == "--no-upgrade" ]; then
        m2_upgrade=0
    elif [ "${1}" == "--no-cron" ]; then
        m2_use_cron=0
    elif [ "${1}" == "--setup-version" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-version not defined" && exit 1
        m2_setup_version="${2}" && shift
    elif [ "${1}" == "--setup-mode" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-version not defined" && exit 1
        m2_setup_mode="${2}" && shift
    elif [ "${1}" == "--setup-no-install" ]; then
        m2_setup_install=0
    elif [ "${1}" == "--setup-install-base-url" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-install-base-url not defined" && exit 1
        m2_setup_install_base_url="${2}" && shift
    elif [ "${1}" == "--setup-install-admin-path" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-install-admin-path not defined" && exit 1
        m2_setup_install_admin_path="${2}" && shift
    elif [ "${1}" == "--setup-install-admin-user" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-install-admin-user not defined" && exit 1
        m2_setup_install_admin_user="${2}" && shift
    elif [ "${1}" == "--setup-install-admin-pwd" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-install-admin-pwd not defined" && exit 1
        m2_setup_install_admin_pwd="${2}" && shift
    elif [ "${1}" == "--setup-install-admin-email" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-install-admin-email not defined" && exit 1
        m2_setup_install_admin_email="${2}" && shift
    elif [ "${1}" == "--setup-install-admin-firstname" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-install-admin-firstname not defined" && exit 1
        m2_setup_install_admin_firstname="${2}" && shift
    elif [ "${1}" == "--setup-install-admin-lastname" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-install-admin-lastname not defined" && exit 1
        m2_setup_install_admin_lastname="${2}" && shift
    elif [ "${1}" == "--setup-install-db-host" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-install-db-host not defined" && exit 1
        m2_setup_install_db_host="${2}" && shift
    elif [ "${1}" == "--setup-install-db-name" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-install-db-name not defined" && exit 1
        m2_setup_install_db_name="${2}" && shift
    elif [ "${1}" == "--setup-install-db-user" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-install-db-user not defined" && exit 1
        m2_setup_install_db_user="${2}" && shift
    elif [ "${1}" == "--setup-install-db-pwd" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-install-db-pwd not defined" && exit 1
        m2_setup_install_db_pwd="${2}" && shift
    elif [ "${1}" == "--setup-install-db-no-clean" ]; then
        m2_setup_install_db_clean=0
    elif [ "${1}" == "--setup-install-search-engine" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-install-search-engine not defined" && exit 1
        m2_setup_install_search_engine="${2}" && shift
    elif [ "${1}" == "--setup-install-search-host" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-install-search-host not defined" && exit 1
        m2_setup_install_search_host="${2}" && shift
    elif [ "${1}" == "--setup-install-search-port" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-install-search-port not defined" && exit 1
        m2_setup_install_search_port="${2}" && shift
    elif [ "${1}" == "--setup-install-search-auth" ]; then
        m2_setup_install_search_auth=1
    elif [ "${1}" == "--setup-install-search-user" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-install-search-user not defined" && exit 1
        m2_setup_install_search_user="${2}" && shift
    elif [ "${1}" == "--setup-install-search-pwd" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-install-search-pwd not defined" && exit 1
        m2_setup_install_search_pwd="${2}" && shift
    elif [ "${1}" == "--setup-install-excluded-modules" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "setup-install-excluded-modules not defined" && exit 1
        m2_setup_install_excluded_modules="${2}" && shift
    fi
    shift
done

##########################################
# Set default values and check integrity #
##########################################

# cmd_use_help
[ -z "${cmd_use_help}" ] && cmd_use_help=0
[ ${#cmd_use_help} -ne 1 ] && error_message "Invalid value for ${color_yellow}cmd_use_help${color_none}" && exit 1
[ ${cmd_use_help} -ne 1 ] && [ ${cmd_use_help} -ne 0 ] && error_message "Invalid value for ${color_yellow}cmd_use_help${color_none}" && exit 1

# cmd_use_force
[ -z "${cmd_use_force}" ] && cmd_use_force=0
[ ${#cmd_use_force} -ne 1 ] && error_message "Invalid value for ${color_yellow}cmd_use_force${color_none}" && exit 1
[ ${cmd_use_force} -ne 1 ] && [ ${cmd_use_force} -ne 0 ] && error_message "Invalid value for ${color_yellow}cmd_use_force${color_none}" && exit 1

# system_fallback_user
[ -z "${system_fallback_user}" ] && system_fallback_user=""

# system_php_version
[ -z "${system_php_version}" ] && system_php_version=""

# system_webserver_https
[ -z "${system_webserver_https}" ] && system_webserver_https=0
[ ${#system_webserver_https} -ne 1 ] && error_message "Invalid value for ${color_yellow}system_webserver_https${color_none}" && exit 1
[ ${system_webserver_https} -ne 1 ] && [ ${system_webserver_https} -ne 0 ] && error_message "Invalid value for ${color_yellow}system_webserver_https${color_none}" && exit 1

# git_deploy_branch
[ -z "${git_deploy_branch}" ] && git_deploy_branch=""

# git_pull_mode
[ -z "${git_pull_mode}" ] && git_pull_mode="hard"
[ "${git_pull_mode}" != "none" ] && [ "${git_pull_mode}" != "soft" ] && [ "${git_pull_mode}" != "hard" ] && error_message "Invalid value for ${color_yellow}git_pull_mode${color_none}" && exit 1

# git_use_stash
[ -z "${git_use_stash}" ] && git_use_stash=0
[ ${#git_use_stash} -ne 1 ] && error_message "Invalid value for ${color_yellow}git_use_stash${color_none}" && exit 1
[ ${git_use_stash} -ne 1 ] && [ ${git_use_stash} -ne 0 ] && error_message "Invalid value for ${color_yellow}git_use_stash${color_none}" && exit 1

# git_setup_user_name
[ -z "${git_setup_user_name}" ] && git_setup_user_name=""

# git_setup_user_email
[ -z "${git_setup_user_email}" ] && git_setup_user_email=""

# git_setup_origin_protocol
[ -z "${git_setup_origin_protocol}" ] && git_setup_origin_protocol=""
[ "${git_setup_origin_protocol}" != "" ] && [ "${git_setup_origin_protocol}" != "http" ] && [ "${git_setup_origin_protocol}" != "https" ] && [ "${git_setup_origin_protocol}" != "ssh" ] && error_message "Invalid value for ${color_yellow}git_setup_origin_protocol${color_none}" && exit 1

# git_setup_origin_user
[ -z "${git_setup_origin_user}" ] && git_setup_origin_user=""

# git_setup_origin_key
[ -z "${git_setup_origin_key}" ] && git_setup_origin_key=""

# git_setup_origin_host
[ -z "${git_setup_origin_host}" ] && git_setup_origin_host=""

# m2_build_files
[ -z "${m2_build_files}" ] && m2_build_files=1
[ ${#m2_build_files} -ne 1 ] && error_message "Invalid value for ${color_yellow}m2_build_files${color_none}" && exit 1
[ ${m2_build_files} -ne 1 ] && [ ${m2_build_files} -ne 0 ] && error_message "Invalid value for ${color_yellow}m2_build_files${color_none}" && exit 1

# m2_build_languages
[ -z "${m2_build_languages}" ] && m2_build_languages=""

# m2_clean_folders
[ -z "${m2_clean_folders}" ] && m2_clean_folders=1
[ ${#m2_clean_folders} -ne 1 ] && error_message "Invalid value for ${color_yellow}m2_clean_folders${color_none}" && exit 1
[ ${m2_clean_folders} -ne 1 ] && [ ${m2_clean_folders} -ne 0 ] && error_message "Invalid value for ${color_yellow}m2_clean_folders${color_none}" && exit 1

# m2_disable_maintenance
[ -z "${m2_disable_maintenance}" ] && m2_disable_maintenance=1
[ ${#m2_disable_maintenance} -ne 1 ] && error_message "Invalid value for ${color_yellow}m2_disable_maintenance${color_none}" && exit 1
[ ${m2_disable_maintenance} -ne 1 ] && [ ${m2_disable_maintenance} -ne 0 ] && error_message "Invalid value for ${color_yellow}m2_disable_maintenance${color_none}" && exit 1

# m2_enable_maintenance
[ -z "${m2_enable_maintenance}" ] && m2_enable_maintenance=1
[ ${#m2_enable_maintenance} -ne 1 ] && error_message "Invalid value for ${color_yellow}m2_enable_maintenance${color_none}" && exit 1
[ ${m2_enable_maintenance} -ne 1 ] && [ ${m2_enable_maintenance} -ne 0 ] && error_message "Invalid value for ${color_yellow}m2_enable_maintenance${color_none}" && exit 1

# m2_flush_cache
[ -z "${m2_flush_cache}" ] && m2_flush_cache=1
[ ${#m2_flush_cache} -ne 1 ] && error_message "Invalid value for ${color_yellow}m2_flush_cache${color_none}" && exit 1
[ ${m2_flush_cache} -ne 1 ] && [ ${m2_flush_cache} -ne 0 ] && error_message "Invalid value for ${color_yellow}m2_flush_cache${color_none}" && exit 1

# m2_install_deps
[ -z "${m2_install_deps}" ] && m2_install_deps=1
[ ${#m2_install_deps} -ne 1 ] && error_message "Invalid value for ${color_yellow}m2_install_deps${color_none}" && exit 1
[ ${m2_install_deps} -ne 1 ] && [ ${m2_install_deps} -ne 0 ] && error_message "Invalid value for ${color_yellow}m2_install_deps${color_none}" && exit 1

# m2_reindex
[ -z "${m2_reindex}" ] && m2_reindex=1
[ ${#m2_reindex} -ne 1 ] && error_message "Invalid value for ${color_yellow}m2_reindex${color_none}" && exit 1
[ ${m2_reindex} -ne 1 ] && [ ${m2_reindex} -ne 0 ] && error_message "Invalid value for ${color_yellow}m2_reindex${color_none}" && exit 1

# m2_upgrade
[ -z "${m2_upgrade}" ] && m2_upgrade=1
[ ${#m2_upgrade} -ne 1 ] && error_message "Invalid value for ${color_yellow}m2_upgrade${color_none}" && exit 1
[ ${m2_upgrade} -ne 1 ] && [ ${m2_upgrade} -ne 0 ] && error_message "Invalid value for ${color_yellow}m2_upgrade${color_none}" && exit 1

# m2_use_cron
[ -z "${m2_use_cron}" ] && m2_use_cron=1
[ ${#m2_use_cron} -ne 1 ] && error_message "Invalid value for ${color_yellow}m2_use_cron${color_none}" && exit 1
[ ${m2_use_cron} -ne 1 ] && [ ${m2_use_cron} -ne 0 ] && error_message "Invalid value for ${color_yellow}m2_use_cron${color_none}" && exit 1

# m2_setup_version
[ -z "${m2_setup_version}" ] && m2_setup_version=""

# m2_setup_mode
[ -z "${m2_setup_mode}" ] && m2_setup_mode="dev"
[ "${m2_setup_mode}" != "dev" ] && [ "${m2_setup_mode}" != "prod" ] && error_message "Invalid value for ${color_yellow}m2_setup_mode${color_none}" && exit 1

# m2_setup_install
[ -z "${m2_setup_install}" ] && m2_setup_install=1
[ ${#m2_setup_install} -ne 1 ] && error_message "Invalid value for ${color_yellow}m2_setup_install${color_none}" && exit 1
[ ${m2_setup_install} -ne 1 ] && [ ${m2_setup_install} -ne 0 ] && error_message "Invalid value for ${color_yellow}m2_setup_install${color_none}" && exit 1

# m2_setup_install_base_url
[ -z "${m2_setup_install_base_url}" ] && m2_setup_install_base_url=""

# m2_setup_install_admin_path
[ -z "${m2_setup_install_admin_path}" ] && m2_setup_install_admin_path=""

# m2_setup_install_admin_user
[ -z "${m2_setup_install_admin_user}" ] && m2_setup_install_admin_user=""

# m2_setup_install_admin_pwd
[ -z "${m2_setup_install_admin_pwd}" ] && m2_setup_install_admin_pwd=""

# m2_setup_install_admin_email
[ -z "${m2_setup_install_admin_email}" ] && m2_setup_install_admin_email=""

# m2_setup_install_admin_firstname
[ -z "${m2_setup_install_admin_firstname}" ] && m2_setup_install_admin_firstname=""

# m2_setup_install_admin_lastname
[ -z "${m2_setup_install_admin_lastname}" ] && m2_setup_install_admin_lastname=""

# m2_setup_install_db_host
[ -z "${m2_setup_install_db_host}" ] && m2_setup_install_db_host=""

# m2_setup_install_db_name
[ -z "${m2_setup_install_db_name}" ] && m2_setup_install_db_name=""

# m2_setup_install_db_user
[ -z "${m2_setup_install_db_user}" ] && m2_setup_install_db_user=""

# m2_setup_install_db_pwd
[ -z "${m2_setup_install_db_pwd}" ] && m2_setup_install_db_pwd=""

# m2_setup_install_db_clean
[ -z "${m2_setup_install_db_clean}" ] && m2_setup_install_db_clean=1
[ ${#m2_setup_install_db_clean} -ne 1 ] && error_message "Invalid value for ${color_yellow}m2_setup_install_db_clean${color_none}" && exit 1
[ ${m2_setup_install_db_clean} -ne 1 ] && [ ${m2_setup_install_db_clean} -ne 0 ] && error_message "Invalid value for ${color_yellow}m2_setup_install_db_clean${color_none}" && exit 1

# m2_setup_install_search_engine
[ -z "${m2_setup_install_search_engine}" ] && m2_setup_install_search_engine=""
[ "${m2_setup_install_search_engine}" != "" ] && [ "${m2_setup_install_search_engine}" != "opensearch" ] && [ "${m2_setup_install_search_engine}" != "elasticsearch7" ] && [ "${m2_setup_install_search_engine}" != "elasticsearch8" ] && error_message "Invalid value for ${color_yellow}m2_setup_install_search_engine${color_none}" && exit 1

# m2_setup_install_search_host
[ -z "${m2_setup_install_search_host}" ] && m2_setup_install_search_host=""

# m2_setup_install_search_port
[ -z "${m2_setup_install_search_port}" ] && m2_setup_install_search_port=""

# m2_setup_install_search_auth
[ -z "${m2_setup_install_search_auth}" ] && m2_setup_install_search_auth=0
[ ${#m2_setup_install_search_auth} -ne 1 ] && error_message "Invalid value for ${color_yellow}m2_setup_install_search_auth${color_none}" && exit 1
[ ${m2_setup_install_search_auth} -ne 1 ] && [ ${m2_setup_install_search_auth} -ne 0 ] && error_message "Invalid value for ${color_yellow}m2_setup_install_search_auth${color_none}" && exit 1

# m2_setup_install_search_user
[ -z "${m2_setup_install_search_user}" ] && m2_setup_install_search_user=""

# m2_setup_install_search_pwd
[ -z "${m2_setup_install_search_pwd}" ] && m2_setup_install_search_pwd=""

# m2_setup_install_excluded_modules
[ -z "${m2_setup_install_excluded_modules}" ] && m2_setup_install_excluded_modules=""
