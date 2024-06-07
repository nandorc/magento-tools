#!/bin/bash

# Add bin folder to PATH
export PATH="~/.magetools/bin:$PATH"

# magento env move
env-move() {
    declare must_switch=0
    declare env_name="${1}"
    if [ "${1}" == "-s" ]; then
        must_switch=1
        env_name="${2}"
    fi
    [ -z "${env_name}" ] && echo "ERR~ No env-name provided" && return 1
    env_name=$(echo "${env_name}" | sed -e "s| |-|")
    if [ ${must_switch} -eq 1 ]; then
        mage env:switch "${env_name}"
        [ ${?} -ne 0 ] && return 1
    fi
    [ ! -d /magento-app/"${env_name}" ] && echo "ERR~ No env found for '${env_name}'" && return 1
    cd /magento-app/"${env_name}"/site && return 0
}
