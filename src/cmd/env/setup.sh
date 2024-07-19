#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Get env identity
declare env_name=default
declare env_user=${USER}
declare env_mode=dev
declare env_fs=0
declare env_cron=0
declare env_install=1
declare env_use_repo=1
declare env_must_clean_db=1
while [ -n "${1}" ]; do
    if [ "${1}" == "--help" ]; then
        [ ! -f ~/.magetools/src/docs/env:setup.txt ] && error_message "No help documentation found" && exit 1
        (cat ~/.magetools/src/docs/env:setup.txt | less -c) && exit 0
    elif [ "${1}" == "--name" ]; then
        ([ -z "${2}" ] || [ -n "$(echo ${2} | grep "^-")" ]) && error_message "Name can not be empty" && exit 1
        env_name=${2} && shift
    elif [ "${1}" == "--mode" ]; then
        ([ -z "${2}" ] || [ -n "$(echo ${2} | grep "^-")" ]) && error_message "Mode can not be empty" && exit 1
        [ "${2}" != "dev" ] && [ "${2}" != "prod" ] && error_message "Mode must be dev or prod" && exit 1
        env_mode=${2} && shift
    elif [ "${1}" == "--with-fs" ]; then
        env_fs=1
    elif [ "${1}" == "--with-cron" ]; then
        env_cron=1
    elif [ "${1}" == "--no-install" ]; then
        env_install=0
    elif [ "${1}" == "--no-repo" ]; then
        env_use_repo=0
    elif [ "${1}" == "--no-clean-db" ]; then
        env_must_clean_db=0
    fi
    shift
done

# Set default values
env_name=$(echo "${env_name}" | sed -e "s| |-|")
if [ -z "${env_user}" ]; then
    echo -e "OS user name: \c" && read env_user
fi
[ -z "${env_user}" ] && error_message "User for env not defined" && exit 1

# Declare and load env app variables
declare git_protocol=
declare git_user=
declare git_key=
declare git_route=
declare git_branch=
declare repo_user=
declare repo_email=
declare db_host=
declare db_name=
declare db_user=
declare db_pwd=
declare search_engine=
declare search_host=
declare search_port=
declare search_auth=
declare search_user=
declare search_pwd=
declare base_url=
declare admin_path=
declare magento_version=2.4.7
declare php_version=8.3
declare excluded_on_install=
[ ! -f ~/.magetools/var/vars-"${env_name}".sh ] && error_message "Can't find vars file for env with name ${color_yellow}${env_name}${color_none}" && exit 1
source ~/.magetools/var/vars-"${env_name}".sh

# Create and move to env folder
if [ ! -d /magento-app/${env_name} ]; then
    sudo mkdir -v -p /magento-app/${env_name}
    [ ${?} -ne 0 ] && error_message "Can't create env folder" && exit 1
fi
sudo chown -v ${env_user}:${env_user} /magento-app/${env_name}
[ ${?} -ne 0 ] && error_message "Can't assign ownership to env folder" && exit 1

# Create app folders
if [ ! -d /magento-app/${env_name}/site ]; then
    mkdir -v -p /magento-app/${env_name}/site
    [ ${?} -ne 0 ] && error_message "Can't create site folder for env" && exit 1
fi
if [ ${env_fs} -eq 1 ] && [ ! -d /magento-app/${env_name}/fs ]; then
    mkdir -v -p /magento-app/${env_name}/fs
    [ ${?} -ne 0 ] && error_message "Can't create fs folder for env" && exit 1
fi

# Build git repo
declare git_repository=
if [ ${env_use_repo} -eq 1 ] && [ ! -d /magento-app/${env_name}/site/.git ]; then
    [ "${git_protocol}" != "http" ] && [ "${git_protocol}" != "https" ] && [ "${git_protocol}" != "ssh" ] && error_message "git_protocol must be http, https or ssh" && exit 1
    [ -z "${git_route}" ] && error_message "git_route must be defined" && exit 1
    if [ "${git_protocol}" == "ssh" ]; then
        git_repository=${git_route}
    else
        [ -z "${git_user}" ] && error_message "git_user must be defined for http/https protocol" && exit 1
        [ -z "${git_key}" ] && error_message "git_key must be defined for http/https protocol" && exit 1
        git_repository="${git_protocol}://${git_user}:${git_key}@${git_route}"
    fi
    [ -z "${git_branch}" ] && git_branch=develop
fi

# Clone or install
declare must_set_repo_user=0
declare must_create_init_commit=0
if [ -n "${git_repository}" ]; then
    git clone -b ${git_branch} ${git_repository} /magento-app/${env_name}/site
    [ ${?} -ne 0 ] && error_message "Can't clone git repository" && exit 1
    cd /magento-app/${env_name}/site
    composer install
    [ ${?} -ne 0 ] && error_message "Can't install composer dependencies" && exit 1
    must_set_repo_user=1
elif [ ! -d /magento-app/${env_name}/site/.git ]; then
    cd /magento-app/${env_name}/site
    composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition="${magento_version}" .
    [ ${?} -ne 0 ] && error_message "Can't create new Magento project" && exit 1
    if [ ! -f .gitignore ]; then
        cp -v ~/.magetools/src/templates/.gitignore.sample ./.gitignore
        [ ${?} -ne 0 ] && error_message "Can't copy template for .gitignore" && exit 1
    fi
    git init
    [ ${?} -ne 0 ] && error_message "Can't init Magento project repo" && exit 1
    must_set_repo_user=1
    must_create_init_commit=1
fi

# Set repo user
if [ ${must_set_repo_user} -eq 1 ]; then
    [ -z "${repo_user}" ] && repo_user=${env_user}
    [ -z "${repo_email}" ] && repo_email=${env_user}@sample.com
    git config --local user.name "${repo_user}"
    [ ${?} -ne 0 ] && error_message "Can't set repo user.name" && exit 1
    git config --local user.email "${repo_email}"
    [ ${?} -ne 0 ] && error_message "Can't set repo user.email" && exit 1
fi

# Create first commit
if [ ${must_create_init_commit} -eq 1 ]; then
    git add . && git commit -m "Init Magento project at $(date)"
    [ ${?} -ne 0 ] && error_message "Can't create init commit for Magento project" && exit 1
fi

# Assign permissions and ownership to app
cd /magento-app/${env_name}/site
[ ! -f ~/.magetools/bin/mage ] && error_message "Can't find mage task executor" && exit 1
mage perms
[ ${?} -ne 0 ] && error_message "Can't assign permissions and ownership to site folder content" && exit 1
git restore .

# Install app
declare mage_install_cmd=
declare search_engine_prefix=
if [ ${env_install} -eq 1 ] && [ ! -f /magento-app/${env_name}/fs/app/etc/env.php ]; then
    mage_install_cmd="bin/magento setup:install"
    if [ -n "${admin_path}" ]; then
        mage_install_cmd="${mage_install_cmd} --backend-frontname='${admin_path}'"
    fi
    [ -z "${db_host}" ] && error_message "db_host must be defined" && exit 1
    mage_install_cmd="${mage_install_cmd} --db-host='${db_host}'"
    [ -z "${db_name}" ] && error_message "db_pwd name be defined" && exit 1
    mage_install_cmd="${mage_install_cmd} --db-name='${db_name}'"
    [ -z "${db_user}" ] && error_message "db_user must be defined" && exit 1
    mage_install_cmd="${mage_install_cmd} --db-user='${db_user}'"
    [ -z "${db_pwd}" ] && error_message "db_pwd must be defined" && exit 1
    mage_install_cmd="${mage_install_cmd} --db-password='${db_pwd}'"
    [ -z "${base_url}" ] && error_message "base_url must be defined" && exit 1
    mage_install_cmd="${mage_install_cmd} --base-url='${base_url}' --use-rewrites=1"
    [ "${search_engine}" != "elasticsearch7" ] && [ "${search_engine}" != "opensearch" ] && error_message "No valid search engine defined. Only valid elasticsearch7 or opensearch" && exit 1
    mage_install_cmd="${mage_install_cmd} --search-engine='${search_engine}'"
    if [ "${search_engine}" == "elasticsearch7" ]; then
        search_engine_prefix=elasticsearch
    else
        search_engine_prefix=opensearch
    fi
    [ -z "${search_host}" ] && error_message "search_host must be defined" && exit 1
    mage_install_cmd="${mage_install_cmd} --${search_engine_prefix}-host='${search_host}'"
    [ -z "${search_port}" ] && error_message "search_port must be defined" && exit 1
    mage_install_cmd="${mage_install_cmd} --${search_engine_prefix}-port=${search_port}"
    if [ "${search_auth}" == "1" ]; then
        mage_install_cmd="${mage_install_cmd} --${search_engine_prefix}-enable-auth=1"
        [ -z "${search_user}" ] && error_message "search_user must be defined if search_auth is 1" && exit 1
        mage_install_cmd="${mage_install_cmd} --${search_engine_prefix}-username='${search_user}'"
        [ -z "${search_pwd}" ] && error_message "search_pwd must be defined if search_auth is 1" && exit 1
        mage_install_cmd="${mage_install_cmd} --${search_engine_prefix}-password='${search_pwd}'"
    fi
    if [ ${env_must_clean_db} -eq 1 ]; then
        mage_install_cmd="${mage_install_cmd} --cleanup-database"
    fi
    mage_install_cmd="${mage_install_cmd} --no-interaction"
    if [ -n "${excluded_on_install}" ]; then
        bin/magento module:disable -c ${excluded_on_install}
        [ ${?} -ne 0 ] && error_message "Can't disable on install excluded modules" && exit 1
    fi
    eval "${mage_install_cmd}"
    [ ${?} -ne 0 ] && error_message "Can't install magento app" && exit 1
    if [ -n "${excluded_on_install}" ]; then
        bin/magento module:enable -c ${excluded_on_install}
        [ ${?} -ne 0 ] && error_message "Can't re-enable on install excluded modules" && exit 1
    fi
    if [ "${env_mode}" == "prod" ]; then
        bin/magento deploy:mode:set production
        [ ${?} -ne 0 ] && error_message "Can't apply production mode" && exit 1
    fi
fi

# Replicate and clean nginx conf file
declare nginx_file_name=
if [ -f /magento-app/${env_name}/site/nginx.conf ]; then
    nginx_file_name=nginx.conf
elif [ -f /magento-app/${env_name}/site/nginx.conf.sample ]; then
    nginx_file_name=nginx.conf.sample
else
    error_message "Can't find nginx conf at ${color_yellow}/magento-app/${env_name}/site${color_none}" && exit 1
fi
cp -v /magento-app/${env_name}/site/${nginx_file_name} /magento-app/${env_name}/nginx.conf
sed -i -e "/HTTPS \"on\"/d" /magento-app/${env_name}/nginx.conf
sed -i -e "/HTTP_X_FORWARDED_PROTO \"https\"/d" /magento-app/${env_name}/nginx.conf

# Create nginx host file
declare hostfile_name=00-magento-${env_name}
declare enabled_host_path=/etc/nginx/sites-enabled/${hostfile_name}
declare available_host_path=/etc/nginx/sites-available/${hostfile_name}
sudo rm -rfv ${enabled_host_path} ${available_host_path}
sudo touch ${available_host_path}
sudo chown -v ${env_user}:${env_user} ${available_host_path}

# Fill host file content
echo "upstream fastcgi_backend {" >${available_host_path}
echo "    server unix:/run/php/php${php_version}-fpm.sock;" >>${available_host_path}
echo "}" >>${available_host_path}
echo "" >>${available_host_path}
echo "server {" >>${available_host_path}
echo "    listen 80;" >>${available_host_path}
echo "    server_name _;" >>${available_host_path}
echo "    set \$MAGE_ROOT /magento-app/${env_name}/site;" >>${available_host_path}
echo "    include /magento-app/${env_name}/nginx.conf;" >>${available_host_path}
echo "}" >>${available_host_path}
sudo chown -v root:root ${available_host_path}

# Setup env.php
if [ ${env_fs} -eq 1 ] && [ -d /magento-app/${env_name}/fs ]; then
    [ ! -d /magento-app/${env_name}/fs/app/etc ] && mkdir -p /magento-app/${env_name}/fs/app/etc
    if [ ! -f /magento-app/${env_name}/fs/app/etc/env.php ]; then
        mv -v /magento-app/${env_name}/site/app/etc/env.php /magento-app/${env_name}/fs/app/etc/
    else
        rm -rfv /magento-app/${env_name}/site/app/etc/env.php
    fi
    [ ! -L /magento-app/${env_name}/site/app/etc/env.php ] && ln -v -s /magento-app/${env_name}/fs/app/etc/env.php /magento-app/${env_name}/site/app/etc/
fi

# Install crontab
if [ ${env_cron} -eq 1 ]; then
    bin/magento cron:install -f
    bin/magento cron:run
fi

# Setup media folder
if [ ${env_fs} -eq 1 ] && [ -d /magento-app/${env_name}/fs ]; then
    [ ! -d /magento-app/${env_name}/fs/pub ] && mkdir -p /magento-app/${env_name}/fs/pub
    if [ ! -d /magento-app/${env_name}/fs/pub/media ]; then
        mv -v /magento-app/${env_name}/site/pub/media /magento-app/${env_name}/fs/pub/media
    else
        rm -rfv /magento-app/${env_name}/site/pub/media
    fi
    [ ! -L /magento-app/${env_name}/site/pub/media ] && ln -v -s /magento-app/${env_name}/fs/pub/media /magento-app/${env_name}/site/pub/
fi

# Setup static/_cache folder
if [ ${env_fs} -eq 1 ] && [ -d /magento-app/${env_name}/fs ]; then
    [ ! -d /magento-app/${env_name}/fs/pub/static ] && mkdir -p /magento-app/${env_name}/fs/pub/static
    if [ ! -d /magento-app/${env_name}/fs/pub/static/_cache ]; then
        mv -v /magento-app/${env_name}/site/pub/static/_cache /magento-app/${env_name}/fs/pub/static/_cache
    else
        rm -rfv /magento-app/${env_name}/site/pub/static/_cache
    fi
    [ ! -L /magento-app/${env_name}/site/pub/static/_cache ] && ln -v -s /magento-app/${env_name}/fs/pub/static/_cache /magento-app/${env_name}/site/pub/static/
fi

# Setup var/cache folder
if [ ${env_fs} -eq 1 ] && [ -d /magento-app/${env_name}/fs ]; then
    [ ! -d /magento-app/${env_name}/fs/var ] && mkdir -p /magento-app/${env_name}/fs/var
    if [ ! -d /magento-app/${env_name}/fs/var/cache ]; then
        mv -v /magento-app/${env_name}/site/var/cache /magento-app/${env_name}/fs/var/cache
    else
        rm -rfv /magento-app/${env_name}/site/var/cache
    fi
    [ ! -L /magento-app/${env_name}/site/var/cache ] && ln -v -s /magento-app/${env_name}/fs/var/cache /magento-app/${env_name}/site/var/
fi

# Setup var/page_cache folder
if [ ${env_fs} -eq 1 ] && [ -d /magento-app/${env_name}/fs ]; then
    [ ! -d /magento-app/${env_name}/fs/var ] && mkdir -p /magento-app/${env_name}/fs/var
    if [ ! -d /magento-app/${env_name}/fs/var/page_cache ]; then
        mv -v /magento-app/${env_name}/site/var/page_cache /magento-app/${env_name}/fs/var/page_cache
    else
        rm -rfv /magento-app/${env_name}/site/var/page_cache
    fi
    [ ! -L /magento-app/${env_name}/site/var/page_cache ] && ln -v -s /magento-app/${env_name}/fs/var/page_cache /magento-app/${env_name}/site/var/
fi

# End script
exit 0
