#!/bin/bash

# Bootstrap
[ ! -f ~/.magetools/src/bootstrap.sh ] && error_message "Can not bootstrap magetools" && exit 1
source ~/.magetools/src/bootstrap.sh

# Check bin/magento executor
[ ! -f bin/magento ] && error_message "No bin/magento found to execute commands" && exit 1

# Get parameters
declare must_update_deps=1
while [ -n "${1}" ]; do
    if [ "${1}" == "--help" ]; then
        [ ! -f ~/.magetools/src/docs/lint:report.txt ] && error_message "No help documentation found" && exit 1
        (cat ~/.magetools/src/docs/lint:report.txt | less -c) && exit 0
    elif [ "${1}" == "--no-deps" ]; then
        must_update_deps=0
    fi
    shift
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

# Generate PHP Code Sniffer reports
rm -rfv .tools/reports/phpcs
mkdir -v -p .tools/reports/phpcs
[ ! -f vendor/bin/phpcs ] && error_message "PHP Code Sniffers is not available" && exit 1
vendor/bin/phpcs --report-junit=.tools/reports/phpcs/junit.xml app/code app/design

# Generate Eslint reports
rm -rfv .tools/reports/eslint
mkdir -v -p .tools/reports/eslint
[ ! -f node_modules/.bin/eslint ] && error_message "Eslint is not available" && exit 1
printf "[           ] (0/1)\r"
npx eslint --quiet --no-error-on-unmatched-pattern --output-file=.tools/reports/eslint/junit.xml --format=junit app/code app/design
printf "[===========] (1/1)\n"

# End script
exit 0
