#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Get parameters
declare must_update_deps=1
declare must_bypass=0
while [ "${1}" == "--no-deps" ] || [ "${1}" == "--bypass" ] || [ "${1}" == "--help" ]; do
    if [ "${1}" == "--help" ]; then
        [ ! -f ~/.magetools/src/docs/lint:test.txt ] && error_message "No help documentation found" && exit 1
        (cat ~/.magetools/src/docs/lint:test.txt | less -c) && exit 0
    elif [ "${1}" == "--no-deps" ]; then
        must_update_deps=0
    elif [ "${1}" == "--bypass" ]; then
        must_bypass=1
    fi
    shift
done

# Check bin/magento executor
[ ! -f bin/magento ] && error_message "No bin/magento found to execute commands" && exit 1

# Check if valid paths were received
declare test_paths=($(echo ${@}))
[ ${#test_paths[@]} -eq 0 ] && test_paths=(app/code app/design)
declare is_valid_path
for test_path in ${test_paths[@]}; do
    is_valid_path=0
    [ -f "${test_path}" ] && is_valid_path=1
    [ -d "${test_path}" ] && is_valid_path=1
    [ ${is_valid_path} -eq 0 ] && error_message "No file or folder found at ${test_path}" && exit 1
done

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

# Check and execute phpcs
[ ! -f vendor/bin/phpcs ] && error_message "PHP Code Sniffers is not available" && exit 1
vendor/bin/phpcs -s ${test_paths[@]}
[ ${?} -ne 0 ] && [ ${must_bypass} -eq 0 ] && error_message "PHP Code Sniffer find some mistakes" && exit 1

# Check and execute eslint
[ ! -f node_modules/.bin/eslint ] && error_message "Eslint is not available" && exit 1
npx eslint --quiet --no-error-on-unmatched-pattern ${test_paths[@]}
[ ${?} -ne 0 ] && [ ${must_bypass} -eq 0 ] && error_message "Eslint find some mistakes" && exit 1

# Check and execute stylelint
[ ! -f node_modules/.bin/stylelint ] && error_message "Stylelint is not available" && exit 1
npx stylelint --allow-empty-input ${test_paths[@]}
[ ${?} -ne 0 ] && [ ${must_bypass} -eq 0 ] && error_message "Stylelint find some mistakes" && exit 1

# End script
exit 0
