#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202208171238-git
# @@Author           :  Jason Hempstead
# @@Contact          :  jason@casjaysdev.pro
# @@License          :  WTFPL
# @@ReadME           :  termbin.com --help
# @@Copyright        :  Copyright: (c) 2022 Jason Hempstead, Casjays Developments
# @@Created          :  Wednesday, Aug 17, 2022 12:38 EDT
# @@File             :  termbin.com
# @@Description      :  Post text to termbin.com
# @@Changelog        :  New script
# @@TODO             :  Better documentation
# @@Other            :
# @@Resource         :
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  bash/system
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# shellcheck disable=SC1003,SC2016,SC2031,SC2120,SC2155,SC2199,SC2317
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPNAME="$(basename -- "$0" 2>/dev/null)"
VERSION="202208171238-git"
USER="${SUDO_USER:-$USER}"
RUN_USER="${RUN_USER:-$USER}"
USER_HOME="${USER_HOME:-$HOME}"
SCRIPT_SRC_DIR="${BASH_SOURCE%/*}"
TERMBIN_COM_REQUIRE_SUDO="${TERMBIN_COM_REQUIRE_SUDO:-no}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Reopen in a terminal
if [ ! -t 0 ] && { [ "$1" = --term ] || [ $# = 0 ]; }; then { [ "$1" = --term ] && shift 1 || true; } && TERMINAL_APP="TRUE" myterminal -e "$APPNAME $*" && exit || exit 1; fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set script title
#CASJAYS_DEV_TILE_FORMAT="${USER}@${HOSTNAME}:${PWD//$HOME/\~} - $APPNAME"
#CASJAYSDEV_TITLE_PREV="${CASJAYSDEV_TITLE_PREV:-${CASJAYSDEV_TITLE_SET:-$APPNAME}}"
#[ -z "$CASJAYSDEV_TITLE_SET" ] && printf '\033]2│;%s\033\\' "$CASJAYS_DEV_TILE_FORMAT" && CASJAYSDEV_TITLE_SET="$APPNAME"
export CASJAYSDEV_TITLE_PREV="${CASJAYSDEV_TITLE_PREV:-${CASJAYSDEV_TITLE_SET:-$APPNAME}}" CASJAYSDEV_TITLE_SET
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Initial debugging
[ "$1" = "--debug" ] && set -x && export SCRIPT_OPTS="--debug" && export _DEBUG="on"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Disables colorization
[ "$1" = "--raw" ] && export SHOW_RAW="true"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# pipes fail
set -o pipefail
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Import functions
CASJAYSDEVDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}"
SCRIPTSFUNCTDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}/functions"
SCRIPTSFUNCTFILE="${SCRIPTSAPPFUNCTFILE:-testing.bash}"
SCRIPTSFUNCTURL="${SCRIPTSAPPFUNCTURL:-https://github.com/dfmgr/installer/raw/main/functions}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -f "$PWD/$SCRIPTSFUNCTFILE" ]; then
  . "$PWD/$SCRIPTSFUNCTFILE"
elif [ -f "$SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE" ]; then
  . "$SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE"
else
  echo "Can not load the functions file: $SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE" 1>&2
  exit 1
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Options are: *_install
# system user desktopmgr devenvmgr dfmgr dockermgr fontmgr iconmgr pkmgr systemmgr thememgr wallpapermgr
user_install && __options "$@"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Send all output to /dev/null
__devnull() {
  tee &>/dev/null && exitCode=0 || exitCode=1
  return ${exitCode:-0}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -'
# Send errors to /dev/null
__devnull2() {
  [ -n "$1" ] && local cmd="$1" && shift 1 || return 1
  eval $cmd "$*" 2>/dev/null && exitCode=0 || exitCode=1
  return ${exitCode:-0}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -'
# See if the executable exists
__cmd_exists() {
  exitCode=0
  [ -n "$1" ] && local exitCode="" || return 0
  for cmd in "$@"; do
    builtin command -v "$cmd" &>/dev/null && exitCode+=$(($exitCode + 0)) || exitCode+=$(($exitCode + 1))
  done
  [ $exitCode -eq 0 ] || exitCode=3
  return ${exitCode:-0}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Check for a valid internet connection
__am_i_online() {
  local exitCode=0
  curl -q -LSsfI --max-time 2 --retry 1 "${1:-https://1.1.1.1}" 2>&1 | grep -qi 'server:.*cloudflare' || exitCode=4
  return ${exitCode:-0}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# colorization
if [ "$SHOW_RAW" = "true" ]; then
  NC=""
  RESET=""
  BLACK=""
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  PURPLE=""
  CYAN=""
  WHITE=""
  ORANGE=""
  LIGHTRED=""
  BG_GREEN=""
  BG_RED=""
  ICON_INFO="[ info ]"
  ICON_GOOD="[ ok ]"
  ICON_WARN="[ warn ]"
  ICON_ERROR="[ error ]"
  ICON_QUESTION="[ ? ]"
  printf_column() { tee | grep '^'; }
  printf_color() { printf '%b' "$1" | tr -d '\t' | sed '/^%b$/d;s,\x1B\[ 0-9;]*[a-zA-Z],,g'; }
else
  printf_color() { printf "%b" "$(tput setaf "${2:-7}" 2>/dev/null)" "$1" "$(tput sgr0 2>/dev/null)"; }
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Additional printf_ colors
__printf_head() { printf_blue "$1"; }
__printf_opts() { printf_purple "$1"; }
__printf_line() { printf_cyan "$1"; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# output version
__version() { printf_cyan "$VERSION"; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# list options
__list_options() {
  printf_color "$1: " "$5"
  echo -ne "$2" | sed 's|:||g;s/'$3'/ '$4'/g' | tr '\n' ' '
  printf_newline
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# create the config file
__gen_config() {
  local NOTIFY_CLIENT_NAME="$APPNAME"
  if [ "$INIT_CONFIG" != "TRUE" ]; then
    printf_blue "Generating the config file in"
    printf_cyan "$TERMBIN_COM_CONFIG_DIR/$TERMBIN_COM_CONFIG_FILE"
  fi
  [ -d "$TERMBIN_COM_CONFIG_DIR" ] || mkdir -p "$TERMBIN_COM_CONFIG_DIR"
  [ -d "$TERMBIN_COM_CONFIG_BACKUP_DIR" ] || mkdir -p "$TERMBIN_COM_CONFIG_BACKUP_DIR"
  [ -f "$TERMBIN_COM_CONFIG_DIR/$TERMBIN_COM_CONFIG_FILE" ] &&
    cp -Rf "$TERMBIN_COM_CONFIG_DIR/$TERMBIN_COM_CONFIG_FILE" "$TERMBIN_COM_CONFIG_BACKUP_DIR/$TERMBIN_COM_CONFIG_FILE.$$"
  cat <<EOF >"$TERMBIN_COM_CONFIG_DIR/$TERMBIN_COM_CONFIG_FILE"
# Settings for termbin.com
TERMBIN_COM_SAVED_FILE="${TERMBIN_COM_SAVED_FILE:-}"
TERMBIN_COM_URL_HOST="${TERMBIN_COM_URL_HOST:-}"
TERMBIN_COM_URL_HOST_PORT="${TERMBIN_COM_URL_HOST_PORT:-}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Color Settings
TERMBIN_COM_OUTPUT_COLOR_1="${TERMBIN_COM_OUTPUT_COLOR_1:-}"
TERMBIN_COM_OUTPUT_COLOR_2="${TERMBIN_COM_OUTPUT_COLOR_2:-}"
TERMBIN_COM_OUTPUT_COLOR_GOOD="${TERMBIN_COM_OUTPUT_COLOR_GOOD:-}"
TERMBIN_COM_OUTPUT_COLOR_ERROR="${TERMBIN_COM_OUTPUT_COLOR_ERROR:-}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Notification Settings
TERMBIN_COM_NOTIFY_ENABLED="${TERMBIN_COM_NOTIFY_ENABLED:-}"
TERMBIN_COM_GOOD_NAME="${TERMBIN_COM_GOOD_NAME:-}"
TERMBIN_COM_ERROR_NAME="${TERMBIN_COM_ERROR_NAME:-}"
TERMBIN_COM_GOOD_MESSAGE="${TERMBIN_COM_GOOD_MESSAGE:-}"
TERMBIN_COM_ERROR_MESSAGE="${TERMBIN_COM_ERROR_MESSAGE:-}"
TERMBIN_COM_NOTIFY_CLIENT_NAME="${TERMBIN_COM_NOTIFY_CLIENT_NAME:-}"
TERMBIN_COM_NOTIFY_CLIENT_ICON="${TERMBIN_COM_NOTIFY_CLIENT_ICON:-}"
TERMBIN_COM_NOTIFY_CLIENT_URGENCY="${TERMBIN_COM_NOTIFY_CLIENT_URGENCY:-}"

EOF
  if builtin type -t __gen_config_local | grep -q 'function'; then __gen_config_local; fi
  if [ -f "$TERMBIN_COM_CONFIG_DIR/$TERMBIN_COM_CONFIG_FILE" ]; then
    [ "$INIT_CONFIG" = "TRUE" ] || printf_green "Your config file for $APPNAME has been created"
    . "$TERMBIN_COM_CONFIG_DIR/$TERMBIN_COM_CONFIG_FILE"
    exitCode=0
  else
    printf_red "Failed to create the config file"
    exitCode=1
  fi
  return ${exitCode:-0}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Help function - Align to 50
__help() {
  __printf_head "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  __printf_opts "termbin.com:  Post text to termbin.com - $VERSION"
  __printf_head "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  __printf_line "Usage: termbin.com [options] [commands]"
  __printf_line " - "
  __printf_line " - "
  __printf_line "--dir                           - Sets the working directory"
  __printf_head "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  __printf_opts "Other Options"
  __printf_head "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  __printf_line "--help                          - Shows this message"
  __printf_line "--config                        - Generate user config file"
  __printf_line "--version                       - Show script version"
  __printf_line "--options                       - Shows all available options"
  __printf_line "--debug                         - Enables script debugging"
  __printf_line "--raw                           - Removes all formatting on output"
  __printf_head "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check if arg is a builtin option
__is_an_option() { if echo "$ARRAY" | grep -q "${1:-^}"; then return 1; else return 0; fi; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Is current user root
__user_is_root() {
  { [ $(id -u) -eq 0 ] || [ $EUID -eq 0 ] || [ "$WHOAMI" = "root" ]; } && return 0 || return 1
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Is current user not root
__user_is_not_root() {
  { [ $(id -u) -eq 0 ] || [ $EUID -eq 0 ] || [ "$WHOAMI" = "root" ]; } && return 1 || return 0
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Check if user is a member of sudo
__sudo_group() {
  grep -sh "${1:-$USER}" "/etc/group" | grep -Eq 'wheel|adm|sudo' || return 1
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# # Get sudo password
__sudoask() {
  ask_for_password sudo true && return 0 || return 1
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Run sudo
__sudorun() {
  __sudoif && __cmd_exists sudo && sudo -HE "$@" || { __sudoif && eval "$@"; }
  return $?
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Test if user has access to sudo
__can_i_sudo() {
  (sudo -vn && sudo -ln) 2>&1 | grep -vq 'may not' >/dev/null && return 0
  __sudo_group "${1:-$USER}" || __sudoif || __sudo true &>/dev/null || return 1
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# User can run sudo
__sudoif() {
  __user_is_root && return 0
  __can_i_sudo "${RUN_USER:-$USER}" && return 0
  __user_is_not_root && __sudoask && return 0 || return 1
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Run command as root
requiresudo() {
  if [ "$TERMBIN_COM_REQUIRE_SUDO" = "yes" ] && [ -z "$TERMBIN_COM_REQUIRE_SUDO_RUN" ]; then
    export TERMBIN_COM_REQUIRE_SUDO="no"
    export TERMBIN_COM_REQUIRE_SUDO_RUN="true"
    __sudo "$@"
    exit $?
  else
    return 0
  fi
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Execute sudo
__sudo() {
  CMD="${1:-echo}" && shift 1
  CMD_ARGS="${*:--e "${RUN_USER:-$USER}"}"
  SUDO="$(builtin command -v sudo 2>/dev/null || echo 'eval')"
  [ "$(basename -- "$SUDO" 2>/dev/null)" = "sudo" ] && OPTS="--preserve-env=PATH -HE"
  if __sudoif; then
    export PATH="$PATH"
    $SUDO ${OPTS:-} $CMD $CMD_ARGS && true || false
    exitCode=$?
  else
    printf '%s\n' "This requires root to run"
    exitCode=1
  fi
  return ${exitCode:-1}
}
# End of sudo functions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__trap_exit() {
  exitCode=${exitCode:-0}
  [ -f "$TERMBIN_COM_TEMP_FILE" ] && rm -Rf "$TERMBIN_COM_TEMP_FILE" &>/dev/null
  #unset CASJAYSDEV_TITLE_SET && printf '\033]2│;%s\033\\' "${USER}@${HOSTNAME}:${PWD//$HOME/\~} - ${CASJAYSDEV_TITLE_PREV:-$SHELL}"
  if builtin type -t __trap_exit_local | grep -q 'function'; then __trap_exit_local; fi
  return $exitCode
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# User defined functions
__trap_exit_local() {
  [ -f "${TERMBIN_COM_TEMP_FILE}.err" ] && rm -Rf "${TERMBIN_COM_TEMP_FILE}.err"
  [ -f "${TERMBIN_COM_TEMP_FILE}.send" ] && rm -Rf "${TERMBIN_COM_TEMP_FILE}.send"
  true
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__execute_termbin() {
  local message="${1:-$message}"
  [ -n "$message" ] || printf_exit "Sorry but you seemed to have sent no data"
  printf '%s\n' "$message" >"${TERMBIN_COM_TEMP_FILE}.send"
  cat "${TERMBIN_COM_TEMP_FILE}.send" | $TERMBIN_COM_NETCAT_CMD -w 10 $TERMBIN_COM_URL_HOST $TERMBIN_COM_URL_HOST_PORT 2>"${TERMBIN_COM_TEMP_FILE}.err" >"$TERMBIN_COM_TEMP_FILE"
  if [ -s "$TERMBIN_COM_TEMP_FILE" ]; then
    results="$(cat "$TERMBIN_COM_TEMP_FILE" | tr -d '\0' | grep '^' || cat "$TERMBIN_COM_TEMP_FILE")"
    [ -n "$results" ] || printf_exit "Unfortunately something went wrong"
    __notifications "$APPNAME" "$results"
    printf '%s\n' "$results" | printf_readline $TERMBIN_COM_OUTPUT_COLOR_2
    printf '%s\n' "$results" | clipboard --silent
    printf '%s - %s\n' "$(date)" "$results" >>"$TERMBIN_COM_SAVED_FILE"
    exitCode=0
  else
    printf_red "Well, Something seems to have gone wrong"
    [ -f "${TERMBIN_COM_TEMP_FILE}.err" ] && cat "${TERMBIN_COM_TEMP_FILE}.err" | printf_readline $TERMBIN_COM_OUTPUT_COLOR_ERROR
    exitCode=1
  fi
  return ${exitCode:-0}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# User defined variables/import external variables

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Application Folders
TERMBIN_COM_CONFIG_FILE="${TERMBIN_COM_CONFIG_FILE:-settings.conf}"
TERMBIN_COM_CONFIG_DIR="${TERMBIN_COM_CONFIG_DIR:-$HOME/.config/myscripts/termbin.com}"
TERMBIN_COM_CONFIG_BACKUP_DIR="${TERMBIN_COM_CONFIG_BACKUP_DIR:-$HOME/.local/share/myscripts/termbin.com/backups}"
TERMBIN_COM_LOG_DIR="${TERMBIN_COM_LOG_DIR:-$HOME/.local/log/termbin.com}"
TERMBIN_COM_TEMP_DIR="${TERMBIN_COM_TEMP_DIR:-$HOME/.local/tmp/system_scripts/termbin.com}"
TERMBIN_COM_CACHE_DIR="${TERMBIN_COM_CACHE_DIR:-$HOME/.cache/termbin.com}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Color Settings
TERMBIN_COM_OUTPUT_COLOR_1="${TERMBIN_COM_OUTPUT_COLOR_1:-33}"
TERMBIN_COM_OUTPUT_COLOR_2="${TERMBIN_COM_OUTPUT_COLOR_2:-5}"
TERMBIN_COM_OUTPUT_COLOR_GOOD="${TERMBIN_COM_OUTPUT_COLOR_GOOD:-2}"
TERMBIN_COM_OUTPUT_COLOR_ERROR="${TERMBIN_COM_OUTPUT_COLOR_ERROR:-1}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Notification Settings
TERMBIN_COM_NOTIFY_ENABLED="${TERMBIN_COM_NOTIFY_ENABLED:-yes}"
TERMBIN_COM_GOOD_NAME="${TERMBIN_COM_GOOD_NAME:-Great:}"
TERMBIN_COM_ERROR_NAME="${TERMBIN_COM_ERROR_NAME:-Error:}"
TERMBIN_COM_GOOD_MESSAGE="${TERMBIN_COM_GOOD_MESSAGE:-No errors reported}"
TERMBIN_COM_ERROR_MESSAGE="${TERMBIN_COM_ERROR_MESSAGE:-Errors were reported}"
TERMBIN_COM_NOTIFY_CLIENT_NAME="${TERMBIN_COM_NOTIFY_CLIENT_NAME:-$APPNAME}"
TERMBIN_COM_NOTIFY_CLIENT_ICON="${TERMBIN_COM_NOTIFY_CLIENT_ICON:-notification-new}"
TERMBIN_COM_NOTIFY_CLIENT_URGENCY="${TERMBIN_COM_NOTIFY_CLIENT_URGENCY:-normal}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Additional Variables
TERMBIN_COM_SAVED_FILE="${TERMBIN_COM_SAVED_FILE:-$HOME/Documents/myscripts/${APPNAME}_saved.txt}"
TERMBIN_COM_URL_HOST="${TERMBIN_COM_URL_HOST:-termbin.com}"
TERMBIN_COM_URL_HOST_PORT="${TERMBIN_COM_URL_HOST_PORT:-9999}"
TERMBIN_COM_NETCAT_CMD="${TERMBIN_COM_NETCAT_CMD:-$(builtin type -P netcat 2>/dev/null || builtin type -P nc 2>/dev/null || false)}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Generate config files
[ -f "$TERMBIN_COM_CONFIG_DIR/$TERMBIN_COM_CONFIG_FILE" ] || [ "$*" = "--config" ] || INIT_CONFIG="${INIT_CONFIG:-TRUE}" __gen_config ${SETARGS:-$@}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Import config
[ -f "$TERMBIN_COM_CONFIG_DIR/$TERMBIN_COM_CONFIG_FILE" ] && . "$TERMBIN_COM_CONFIG_DIR/$TERMBIN_COM_CONFIG_FILE"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Ensure Directories exist
[ -d "$TERMBIN_COM_LOG_DIR" ] || mkdir -p "$TERMBIN_COM_LOG_DIR" |& __devnull
[ -d "$TERMBIN_COM_TEMP_DIR" ] || mkdir -p "$TERMBIN_COM_TEMP_DIR" |& __devnull
[ -d "$TERMBIN_COM_CACHE_DIR" ] || mkdir -p "$TERMBIN_COM_CACHE_DIR" |& __devnull
[ -d "$(dirname "$TERMBIN_COM_SAVED_FILE")" ] || mkdir -p "$(dirname "$TERMBIN_COM_SAVED_FILE")" |& __devnull
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
TERMBIN_COM_TEMP_FILE="${TERMBIN_COM_TEMP_FILE:-$(mktemp $TERMBIN_COM_TEMP_DIR/XXXXXX 2>/dev/null)}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup trap to remove temp file
trap '__trap_exit' EXIT
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup notification function
__notifications() {
  __cmd_exists notifications || return
  [ "$TERMBIN_COM_NOTIFY_ENABLED" = "yes" ] || return
  [ "$SEND_NOTIFICATION" = "no" ] && return
  (
    export SCRIPT_OPTS="" _DEBUG=""
    export NOTIFY_GOOD_MESSAGE="${NOTIFY_GOOD_MESSAGE:-$TERMBIN_COM_GOOD_MESSAGE}"
    export NOTIFY_ERROR_MESSAGE="${NOTIFY_ERROR_MESSAGE:-$TERMBIN_COM_ERROR_MESSAGE}"
    export NOTIFY_CLIENT_ICON="${NOTIFY_CLIENT_ICON:-$TERMBIN_COM_NOTIFY_CLIENT_ICON}"
    export NOTIFY_CLIENT_NAME="${NOTIFY_CLIENT_NAME:-$TERMBIN_COM_NOTIFY_CLIENT_NAME}"
    export NOTIFY_CLIENT_URGENCY="${NOTIFY_CLIENT_URGENCY:-$TERMBIN_COM_NOTIFY_CLIENT_URGENCY}"
    notifications "$@"
  ) |& __devnull &
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set custom actions

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Argument/Option settings
SETARGS=("$@")
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SHORTOPTS=""
SHORTOPTS+=""
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
LONGOPTS="completions:,config,debug,dir:,help,options,raw,version,silent"
LONGOPTS+=""
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ARRAY=""
ARRAY+=""
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
LIST=""
LIST+=""
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup application options
setopts=$(getopt -o "$SHORTOPTS" --long "$LONGOPTS" -n "$APPNAME" -- "$@" 2>/dev/null)
eval set -- "${setopts[@]}" 2>/dev/null
while :; do
  case "$1" in
  --raw)
    shift 1
    export SHOW_RAW="true"
    NC=""
    RESET=""
    BLACK=""
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    PURPLE=""
    CYAN=""
    WHITE=""
    ORANGE=""
    LIGHTRED=""
    BG_GREEN=""
    BG_RED=""
    ICON_INFO="[ info ]"
    ICON_GOOD="[ ok ]"
    ICON_WARN="[ warn ]"
    ICON_ERROR="[ error ]"
    ICON_QUESTION="[ ? ]"
    printf_column() { tee | grep '^'; }
    printf_color() { printf '%b' "$1" | tr -d '\t' | sed '/^%b$/d;s,\x1B\[ 0-9;]*[a-zA-Z],,g'; }
    ;;
  --debug)
    shift 1
    set -xo pipefail
    export SCRIPT_OPTS="--debug"
    export _DEBUG="on"
    __devnull() { tee || return 1; }
    __devnull2() { eval "$@" |& tee -p || return 1; }
    ;;
  --completions)
    if [ "$2" = "short" ]; then
      printf '%s\n' "-$SHORTOPTS" | sed 's|"||g;s|:||g;s|,|,-|g' | tr ',' '\n'
    elif [ "$2" = "long" ]; then
      printf '%s\n' "--$LONGOPTS" | sed 's|"||g;s|:||g;s|,|,--|g' | tr ',' '\n'
    elif [ "$2" = "array" ]; then
      printf '%s\n' "$ARRAY" | sed 's|"||g;s|:||g' | tr ',' '\n'
    elif [ "$2" = "list" ]; then
      printf '%s\n' "$LIST" | sed 's|"||g;s|:||g' | tr ',' '\n'
    else
      exit 1
    fi
    shift 2
    exit $?
    ;;
  --options)
    shift 1
    printf_blue "Current options for ${PROG:-$APPNAME}"
    [ -z "$SHORTOPTS" ] || __list_options "Short Options" "-${SHORTOPTS}" ',' '-' 4
    [ -z "$LONGOPTS" ] || __list_options "Long Options" "--${LONGOPTS}" ',' '--' 4
    [ -z "$ARRAY" ] || __list_options "Base Options" "${ARRAY}" ',' '' 4
    [ -z "$LIST" ] || __list_options "LIST Options" "${LIST}" ',' '' 4
    exit $?
    ;;
  --version)
    shift 1
    __version
    exit $?
    ;;
  --help)
    shift 1
    __help
    exit $?
    ;;
  --config)
    shift 1
    __gen_config
    exit $?
    ;;
  --silent)
    shift 1
    TERMBIN_COM_SILENT="true"
    ;;
  --dir)
    CWD_IS_SET="TRUE"
    TERMBIN_COM_CWD="$2"
    [ -d "$TERMBIN_COM_CWD" ] || mkdir -p "$TERMBIN_COM_CWD" |& __devnull
    shift 2
    ;;
  --)
    shift 1
    break
    ;;
  esac
done
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Get directory from args
# set -- "$@"
# for arg in "$@"; do
# if [ -d "$arg" ]; then
# TERMBIN_COM_CWD="$arg" && shift 1 && SET_NEW_ARGS=("$@") && break
# elif [ -f "$arg" ]; then
# TERMBIN_COM_CWD="$(dirname "$arg" 2>/dev/null)" && shift 1 && SET_NEW_ARGS=("$@") && break
# else
# SET_NEW_ARGS+=("$arg")
# fi
# done
# set -- "${SET_NEW_ARGS[@]}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set directory to first argument
# [ -d "$1" ] && __is_an_option "$1" && TERMBIN_COM_CWD="$1" && shift 1 || TERMBIN_COM_CWD="${TERMBIN_COM_CWD:-$PWD}"
TERMBIN_COM_CWD="$(realpath "${TERMBIN_COM_CWD:-$PWD}" 2>/dev/null)"
# if [ -d "$TERMBIN_COM_CWD" ] && cd "$TERMBIN_COM_CWD"; then
# if [ "$TERMBIN_COM_SILENT" != "true" ] && [ "$CWD_SILENCE" != "true" ]; then
# printf_cyan "Setting working dir to $TERMBIN_COM_CWD"
# fi
# else
# printf_exit "💔 $TERMBIN_COM_CWD does not exist 💔"
# fi
export TERMBIN_COM_CWD
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set actions based on variables

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Check for required applications/Network check
#requiresudo "$0" "$@" || exit 2     # exit 2 if errors
#cmd_exists --error --ask bash || exit 3 # exit 3 if not found
#am_i_online --error || exit 4           # exit 4 if no internet
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# APP Variables overrides

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Actions based on env

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Execute functions

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Execute commands

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# begin main app
if [ ${#} -eq 0 ]; then
  if [ $# -eq 0 ] && [ -p "/dev/stdin" ]; then
    message="$(</dev/stdin)"
  else
    printf_cyan "Type or paste in your message, hit control-d when done\n\n"
    message="$(</dev/stdin)"
  fi
elif [ -f "$1" ]; then
  message="$(<"$1")"
else
  message="$(printf '%b\n' "$*")"
fi
__execute_termbin "$message"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set exit code
exitCode="${exitCode:-0}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# End application
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# lets exit with code
exit ${exitCode:-0}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ex: ts=2 sw=2 et filetype=sh
