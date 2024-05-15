#!/bin/bash

# Define colors
# https://dev.to/ifenna__/adding-colors-to-bash-scripts-48g4
declare color_none="\e[0m"
declare color_black="\e[30m"
declare color_red="\e[31m"
declare color_green="\e[32m"
declare color_yellow="\e[33m"
declare color_blue="\e[34m"
declare color_magenta="\e[35m"
declare color_cyan="\e[36m"
declare color_ligth_gray="\e[37m"
declare color_gray="\e[90m"
declare color_light_red="\e[91m"
declare color_light_green="\e[92m"
declare color_light_yellow="\e[93m"
declare color_light_blue="\e[94m"
declare color_light_magenta="\e[95m"
declare color_light_cyan="\e[96m"
declare color_white="\e[97m"

# $1 message
function custom_message() {
    echo -e "${1}"
}

# $1 message
function success_message() {
    custom_message "${color_green}HIT~${color_none} ${1}"
}

# $1 message
function info_message() {
    custom_message "${color_blue}INF~${color_none} ${1}"
}

# $1 message
function error_message() {
    custom_message "${color_red}ERR~${color_none} ${1}"
}

# $1 message
function warning_message() {
    custom_message "${color_yellow}WRN~${color_none} ${1}"
}
