#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  GEN_SCRIPT_REPLACE_VERSION
# @@Author           :  GEN_SCRIPT_REPLACE_AUTHOR
# @@Contact          :  GEN_SCRIPT_REPLACE_EMAIL
# @@License          :  GEN_SCRIPT_REPLACE_LICENSE
# @@ReadME           :  GEN_SCRIPT_REPLACE_FILENAME --help
# @@Copyright        :  GEN_SCRIPT_REPLACE_COPYRIGHT
# @@Created          :  GEN_SCRIPT_REPLACE_DATE
# @@File             :  GEN_SCRIPT_REPLACE_FILENAME
# @@Description      :  GEN_SCRIPT_REPLACE_DESC
# @@Changelog        :  GEN_SCRIPT_REPLACE_CHANGELOG
# @@TODO             :  GEN_SCRIPT_REPLACE_TODO
# @@Other            :  GEN_SCRIPT_REPLACE_OTHER
# @@Resource         :  GEN_SCRIPT_REPLACE_RES
# @@Terminal App     :  GEN_SCRIPT_REPLACE_TERMINAL
# @@sudo/root        :  GEN_SCRIPT_REPLACE_SUDO
# @@Template         :  os/macos
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# shellcheck disable=SC1003,SC2016,SC2031,SC2120,SC2155,SC2199,SC2317
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPNAME="GEN_SCRIPT_REPLACE_FILENAME"
VERSION="GEN_SCRIPT_REPLACE_VERSION"
USER="${SUDO_USER:-$USER}"
RUN_USER="${RUN_USER:-$USER}"
USER_HOME="${USER_HOME:-$HOME}"
SCRIPT_SRC_DIR="${BASH_SOURCE%/*}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
[ "$1" == "--debug" ] && set -xo pipefail && export SCRIPT_OPTS="--debug" && export _DEBUG="on"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Import functions
CASJAYSDEVDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}"
SCRIPTSFUNCTDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}/functions"
SCRIPTSFUNCTFILE="${SCRIPTSAPPFUNCTFILE:-app-installer.bash}"
SCRIPTSFUNCTURL="${SCRIPTSAPPFUNCTURL:-https://github.com/dfmgr/installer/raw/GEN_SCRIPT_REPLACE_DEFAULT_BRANCH/functions}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -f "$PWD/$SCRIPTSFUNCTFILE" ]; then
  . "$PWD/$SCRIPTSFUNCTFILE"
elif [ -f "$SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE" ]; then
  . "$SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE"
else
  echo "Can not load the functions file: $SCRIPTSFUNCTDIR/$SCRIPTSFUNCTFILE" 1>&2
  exit 90
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
run_post() {
  local e="$1"
  local m="${e//devnull /}"
  execute "$e" "executing: $m"
  setexitstatus
  set --
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
grab_remote_file() { urlverify "$1" && curl -sSLq "$@" || exit 1; }
run_external() { printf_green "Executing $*" && "$@" >/dev/null 2>&1; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
retrieve_version_file() {
  grab_remote_file https://github.com/casjay-base/centos/raw/GEN_SCRIPT_REPLACE_DEFAULT_BRANCH/version.txt | head -n1 || echo "GEN_SCRIPT_REPLACE_VERSION"
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#### OS Specific
test_pkg() {
  devnull brew list $1 && printf_success "$1 is installed" && return 1 || return 0
  setexitstatus
  set --
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
remove_pkg() {
  if ! test_pkg "$1"; then execute "brew remove -f $1" "Removing: $1"; fi
  setexitstatus
  set --
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
install_pkg() {
  if test_pkg "$1"; then execute "brew install -f $1" "Installing: $1"; fi
  setexitstatus
  set --
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -n "$1" ] || printf_exit 'To many options provided'
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##################################################################################################################
__printf_head "Initializing the setup script"
##################################################################################################################
execute "sudo PKMGR"
##################################################################################################################
__printf_head "Configuring cores for compiling"
##################################################################################################################
numberofcores=$(grep -c ^processor /proc/cpuinfo)
printf_info "Total cores available: $numberofcores"
if [ -f /etc/makepkg.conf ]; then
  if [ $numberofcores -gt 1 ]; then
    sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j'$(($numberofcores + 1))'"/g' /etc/makepkg.conf
    sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T '"$numberofcores"' -z -)/g' /etc/makepkg.conf
  fi
fi
##################################################################################################################
__printf_head "Installing the packages for GEN_SCRIPT_REPLACE_APPNAME"
##################################################################################################################
install_pkg listofpkgs
##################################################################################################################
__printf_head "Fixing packages"
##################################################################################################################

##################################################################################################################
__printf_head "setting up config files"
##################################################################################################################
run_post "cp -rT /etc/skel $HOME"
run_post "dotfilesreq bash"
run_post "dotfilesreq misc"
##################################################################################################################
__printf_head "Cleaning up"
##################################################################################################################
remove_pkg
##################################################################################################################
__printf_head "Finished "
printf_newline
##################################################################################################################
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set --
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# End application
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# lets exit with code
exit ${exitCode:-0}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ex: ts=2 sw=2 et filetype=sh
