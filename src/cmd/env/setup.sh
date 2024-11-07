#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Declare global variables
cmd_name="env:setup"
env_name=$(bash ${path_scripts}/get-env-name.sh ${@})

# Fragment: command-init-vars
source ${path_fragments}/command-init-vars.sh

# Set env_user
env_user=${USER}
[ -z "${env_user}" ] && env_user="${system_fallback_user}"
if [ -z "${env_user}" ]; then
    info_message "OS user name: \c" && read env_user
fi
[ -z "${env_user}" ] && error_message "User for env not defined" && exit 1

# Create and move to env folder
if [ ! -d ${path_env}/${env_name} ]; then
    sudo mkdir -v -p ${path_env}/${env_name}
    [ ${?} -ne 0 ] && error_message "Can't create env folder" && exit 1
fi
sudo chown -v ${env_user}:${env_user} ${path_env}/${env_name}
[ ${?} -ne 0 ] && error_message "Can't assign ownership to env folder" && exit 1

# Create site folder
if [ ! -d ${path_env}/${env_name}/site ]; then
    mkdir -v -p ${path_env}/${env_name}/site
    [ ${?} -ne 0 ] && error_message "Can't create site folder for env" && exit 1
fi

# Move to env directory
cd ${path_env}/${env_name}/site

# Set git setup origin
git_setup_origin=""
if [ ! -d .git ]; then
    if [ "${git_setup_origin_protocol}" == "http" ] || [ "${git_setup_origin_protocol}" == "https" ]; then
        git_setup_origin="${git_setup_origin_protocol}://"
        [ -z "${git_setup_origin_user}" ] && error_message "setup-origin-user must be defined" && exit 1
        git_setup_origin="${git_setup_origin}${git_setup_origin_user}:"
        [ -z "${git_setup_origin_key}" ] && error_message "setup-origin-key must be defined" && exit 1
        git_setup_origin="${git_setup_origin}${git_setup_origin_key}@"
    fi
    if [ "${git_setup_origin_protocol}" != "" ]; then
        [ -z "${git_setup_origin_host}" ] && error_message "setup-origin-host must be defined" && exit 1
        git_setup_origin="${git_setup_origin}${git_setup_origin_host}"
    fi
fi

# Create or clone project
if [ ! -f bin/magento ]; then
    if [ -z "${git_setup_origin}" ]; then
        [ -z "${m2_setup_version}" ] && error_message "setup-version must be defined" && exit 1
        composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition="${m2_setup_version}" .
        [ ${?} -ne 0 ] && error_message "Can't create new Magento project" && exit 1
    elif [ -n "${git_setup_origin_branch}" ]; then
        git clone -b ${git_setup_origin_branch} ${git_setup_origin} .
        [ ${?} -ne 0 ] && error_message "Can't clone git repository" && exit 1
    else
        git clone ${git_setup_origin} .
        [ ${?} -ne 0 ] && error_message "Can't clone git repository" && exit 1
    fi
fi

# Install composer dependencies
m2_setup_composer_cmd="composer install --no-plugins --no-scripts"
[ "${m2_setup_mode}" == "prod" ] && m2_setup_composer_cmd="${m2_setup_composer_cmd} --no-dev"
eval "${m2_setup_composer_cmd}"
[ ${?} -ne 0 ] && error_message "Can't install composer dependencies" && exit 1

# Check static and media folders
[ ! -d pub/media ] && mkdir -v -p pub/media
[ ! -d pub/static ] && mkdir -v -p pub/static

# Set m2_setup_install_cmd
m2_setup_install_cmd=""
[ -f app/etc/env.php ] && m2_setup_install=0
if [ ${m2_setup_install} -eq 1 ]; then
    m2_setup_install_cmd="bin/magento setup:install"
    [ -n "${m2_setup_install_admin_path}" ] && m2_setup_install_cmd="${m2_setup_install_cmd} --backend-frontname='${m2_setup_install_admin_path}'"
    [ -z "${m2_setup_install_db_host}" ] && error_message "setup-install-db-host is required" && exit 1
    m2_setup_install_cmd="${m2_setup_install_cmd} --db-host='${m2_setup_install_db_host}'"
    [ -z "${m2_setup_install_db_name}" ] && error_message "setup-install-db-name is required" && exit 1
    m2_setup_install_cmd="${m2_setup_install_cmd} --db-name='${m2_setup_install_db_name}'"
    [ -z "${m2_setup_install_db_user}" ] && error_message "setup-install-db-user is required" && exit 1
    m2_setup_install_cmd="${m2_setup_install_cmd} --db-user='${m2_setup_install_db_user}'"
    [ -z "${m2_setup_install_db_pwd}" ] && error_message "setup-install-db-pwd is required" && exit 1
    m2_setup_install_cmd="${m2_setup_install_cmd} --db-password='${m2_setup_install_db_pwd}'"
    [ -z "${m2_setup_install_base_url}" ] && error_message "setup-install-base-url is required" && exit 1
    m2_setup_install_cmd="${m2_setup_install_cmd} --base-url='${m2_setup_install_base_url}'"
    m2_setup_install_cmd="${m2_setup_install_cmd} --use-rewrites=1"
    if [ -n "${m2_setup_install_admin_user}" ] || [ -n "${m2_setup_install_admin_pwd}" ] || [ -n "${m2_setup_install_admin_email}" ] || [ -n "${m2_setup_install_admin_firstname}" ] || [ -n "${m2_setup_install_admin_lastname}" ]; then
        [ -z "${m2_setup_install_admin_user}" ] && error_message "setup-install-admin-user is required" && exit 1
        m2_setup_install_cmd="${m2_setup_install_cmd} --admin-user='${m2_setup_install_admin_user}'"
        [ -z "${m2_setup_install_admin_pwd}" ] && error_message "setup-install-admin-pwd is required" && exit 1
        m2_setup_install_cmd="${m2_setup_install_cmd} --admin-password='${m2_setup_install_admin_pwd}'"
        [ -z "${m2_setup_install_admin_email}" ] && error_message "setup-install-admin-email is required" && exit 1
        m2_setup_install_cmd="${m2_setup_install_cmd} --admin-email='${m2_setup_install_admin_email}'"
        [ -z "${m2_setup_install_admin_firstname}" ] && error_message "setup-install-admin-firstname is required" && exit 1
        m2_setup_install_cmd="${m2_setup_install_cmd} --admin-firstname='${m2_setup_install_admin_firstname}'"
        [ -z "${m2_setup_install_admin_lastname}" ] && error_message "setup-install-admin-lastname is required" && exit 1
        m2_setup_install_cmd="${m2_setup_install_cmd} --admin-lastname='${m2_setup_install_admin_lastname}'"
    fi
    [ -z "${m2_setup_install_search_engine}" ] && error_message "setup-install-search-engine is required" && exit 1
    m2_setup_install_cmd="${m2_setup_install_cmd} --search-engine='${m2_setup_install_search_engine}'"
    m2_setup_install_search_prefix="elasticsearch"
    [ "${m2_setup_install_search_engine}" == "opensearch" ] && m2_setup_install_search_prefix="opensearch"
    [ -z "${m2_setup_install_search_host}" ] && error_message "setup-install-search-host is required" && exit 1
    m2_setup_install_cmd="${m2_setup_install_cmd} --${m2_setup_install_search_prefix}-host='${m2_setup_install_search_host}'"
    [ -z "${m2_setup_install_search_port}" ] && error_message "setup-install-search-port is required" && exit 1
    m2_setup_install_cmd="${m2_setup_install_cmd} --${m2_setup_install_search_prefix}-port='${m2_setup_install_search_port}'"
    if [ ${m2_setup_install_search_auth} -eq 1 ]; then
        m2_setup_install_cmd="${m2_setup_install_cmd} --${m2_setup_install_search_prefix}-enable-auth=1"
        [ -z "${m2_setup_install_search_user}" ] && error_message "setup-install-search-user is required" && exit 1
        m2_setup_install_cmd="${m2_setup_install_cmd} --${m2_setup_install_search_prefix}-username='${m2_setup_install_search_user}'"
        [ -z "${m2_setup_install_search_pwd}" ] && error_message "setup-install-search-pwd is required" && exit 1
        m2_setup_install_cmd="${m2_setup_install_cmd} --${m2_setup_install_search_prefix}-password='${m2_setup_install_search_pwd}'"
    fi
    [ ${m2_setup_install_db_clean} -eq 1 ] && m2_setup_install_cmd="${m2_setup_install_cmd} --cleanup-database"
    m2_setup_install_cmd="${m2_setup_install_cmd} --no-interaction"
fi

# Disable excluded modules before install
if [ ${m2_setup_install} -eq 1 ] && [ -n "${m2_setup_install_excluded_modules}" ]; then
    bin/magento module:disable -c ${m2_setup_install_excluded_modules}
    [ ${?} -ne 0 ] && error_message "Can't disable excluded modules before install" && exit 1
fi

# Install app if necessary
if [ ${m2_setup_install} -eq 1 ]; then
    eval "${m2_setup_install_cmd}"
    [ ${?} -ne 0 ] && error_message "Can't install magento app" && exit 1
fi

# Enable excluded modules after install
if [ ${m2_setup_install} -eq 1 ] && [ -n "${m2_setup_install_excluded_modules}" ]; then
    bin/magento module:enable -c ${m2_setup_install_excluded_modules}
    [ ${?} -ne 0 ] && error_message "Can't enable excluded modules after install" && exit 1
fi

# Set deploy mode
if [ -f app/etc/env.php ]; then
    m2_setup_deploy_mode="developer"
    [ "${m2_setup_mode}" == "prod" ] && m2_setup_deploy_mode="production"
    bin/magento deploy:mode:set ${m2_setup_deploy_mode} --skip-compilation --no-interaction
    [ ${?} -ne 0 ] && error_message "Can't set deploy mode" && exit 1
fi

# Assign permissions and ownership to app
mage perms
[ ${?} -ne 0 ] && error_message "Can't assign permissions and ownership to site folder content" && exit 1

# Initialize repository
git_setup_create_first_commit=0
if [ ! -d .git ]; then
    if [ ! -f .gitignore ]; then
        cp -v ${path_templates}/.gitignore.sample ./.gitignore
        [ ${?} -ne 0 ] && error_message "Can't copy template for .gitignore" && exit 1
    fi
    git init
    [ ${?} -ne 0 ] && error_message "Can't init Magento project repo" && exit 1
    git_setup_create_first_commit=1
fi

# Set repo user data
if [ -z "${git_setup_user_name}" ]; then
    info_message "Local repo user name (${env_user}): \c"
    read git_setup_user_name
    [ -z "${git_setup_user_name}" ] && git_setup_user_name="${env_user}"
fi
git config --local user.name "${git_setup_user_name}"
if [ -z "${git_setup_user_email}" ]; then
    info_message "Local repo user email (${env_user}@example.com): \c"
    read git_setup_user_email
    [ -z "${git_setup_user_email}" ] && git_setup_user_email="${env_user}@example.com"
fi
git config --local user.email "${git_setup_user_email}"
[ ${?} -ne 0 ] && error_message "Can't set repo user.email" && exit 1

# Create first commit
if [ ${git_setup_create_first_commit} -eq 1 ]; then
    git add . && git commit -m "Setup Magento project at $(date)"
    [ ${?} -ne 0 ] && error_message "Can't create init commit for Magento project" && exit 1
fi

# End script
exit 0
