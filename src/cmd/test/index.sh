#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Get parameters
declare theme=""
declare must_build_files=1
declare must_update_deps=1
declare must_bypass=0
declare must_test_front=1
declare must_test_back=1
declare must_run=1
while [ -n "${1}" ]; do
    if [ "${1}" == "--help" ]; then
        [ ! -f ~/.magetools/src/docs/test.txt ] && error_message "No help documentation found" && exit 1
        (cat ~/.magetools/src/docs/test.txt | less -c) && exit 0
    elif [ "${1}" == "--theme" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && error_message "theme must be defined" && exit 1
        theme="${2}" && shift
    elif [ "${1}" == "--no-build" ]; then
        must_build_files=0
    elif [ "${1}" == "--no-deps" ]; then
        must_update_deps=0
    elif [ "${1}" == "--bypass" ]; then
        must_bypass=1
    elif [ "${1}" == "--no-front" ]; then
        must_test_front=0
    elif [ "${1}" == "--no-back" ]; then
        must_test_back=0
    elif [ "${1}" == "--no-run" ]; then
        must_run=0
    fi
    shift
done

# Check bin/magento executor
[ ! -f bin/magento ] && error_message "No bin/magento found to execute commands" && exit 1

# Update deps
if [ ${must_update_deps} -eq 1 ]; then
    # Stash current changes
    git status -s
    [ ${?} -ne 0 ] && error_message "Can't get current git status" && exit 1
    [ -n "$(git stash list)" ] && error_message "Can't create a new stash if there is an existent one" && exit 1
    git stash push -u
    [ ${?} -ne 0 ] && error_message "Can't stash current changes" && exit 1

    # Update composer dependencies
    composer install
    [ ${?} -ne 0 ] && error_message "Can't update composer dependencies" && exit 1

    # Update node dependencies
    npm install
    [ ${?} -ne 0 ] && error_message "Can't update node dependencies" && exit 1

    # Restore git files
    git restore .
    [ ${?} -ne 0 ] && error_message "Can't restore no commited changes after dependencies update" && exit 1

    # Restore changes from stash
    if [ -n "$(git stash list)" ]; then
        git stash pop
        [ ${?} -ne 0 ] && error_message "Can't restore changes from stash" && exit 1
    fi
fi

# Build files
if [ ${must_build_files} -eq 1 ]; then
    # Clean folders
    rm -rfv var/view_preprocessed/*
    rm -rfv pub/static/*/*
    rm -rfv generated/*/*

    # Build files for back test
    if [ ${must_test_back} -eq 1 ]; then
        bin/magento setup:di:compile
        [ ${?} -ne 0 ] && error_message "Can't generate dynamic classes" && exit 1
    fi

    # Build files for front test
    if [ ${must_test_front} -eq 1 ]; then
        bin/magento setup:static-content:deploy --jobs=3 --exclude-theme=Magento/luma -f es_US
        [ ${?} -ne 0 ] && error_message "Can't generate static content" && exit 1
    fi
fi

# Run tests
if [ ${must_run} -eq 1 ]; then
    # Run js unit tests
    if [ ${must_test_front} -eq 1 ]; then
        [ -z "${theme}" ] && error_message "A theme must be specified using --theme flag" && exit 1
        [ ! -f node_modules/.bin/grunt ] && error_message "Grunt is not available" && exit 1
        npx grunt spec:"${theme}"
        [ ${?} -ne 0 ] && [ ${must_bypass} -eq 0 ] && error_message "Something failed running unit test with Grunt-Jasmine" && exit 1
    fi

    # Run phpunit test
    if [ ${must_test_back} -eq 1 ]; then
        [ ! -f vendor/bin/phpunit ] && error_message "PHP Unit is not available" && exit 1
        rm -rfv .tools/reports/phpunit
        mkdir -v -p .tools/reports/phpunit
        vendor/bin/phpunit
        [ ${?} -ne 0 ] && [ ${must_bypass} -eq 0 ] && error_message "Something failed running unit test with PHPUnit" && exit 1
    fi
fi

# End script
exit 0
