#!/bin/bash

# # Check main folder and file
[ ! -d ~/.magetools ] && echo "ERR~ No ~/.magetools folder found" && exit 1
[ ! -f ~/.magetools/init.sh ] && echo "ERR~ No ~/.magetools/init.sh file found" && exit 1

# Check and create .bash_aliases if needed
[ ! -f ~/.bash_aliases ] && touch ~/.bash_aliases

# Check if source is included at .bash_aliases file
source_exists=$(cat ~/.bash_aliases | grep "source ~/.magetools/init.sh")
if [ -z "${source_exists}" ]; then
    echo "" >>~/.bash_aliases
    echo "# Source for mage tools" >>~/.bash_aliases
    echo "[ -f ~/.magetools/init.sh ] && source ~/.magetools/init.sh" >>~/.bash_aliases
    echo "INF~ Source added to .bash_aliases file"
    echo "INF~ Reload terminal or execute 'source ~/.magetools/init.sh' to enable tools"
fi
