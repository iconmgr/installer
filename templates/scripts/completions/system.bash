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
# @@Template         :  completions/system
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# shellcheck disable=SC1003,SC2016,SC2031,SC2120,SC2155,SC2199,SC2317
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
_GEN_SCRIPT_REPLACE_FILENAME_completion() {
  #####################################################################
  local cur prev words cword opts split CONFDIR="" CONFFILE="" SEARCHDIR=""
  local SHOW_COMP_OPTS="" NOOPTS="" SHORTOPTS="" LONGOPTS="" ARRAY="" LIST="" SHOW_COMP_OPTS_SEP=""
  #####################################################################
  _init_completion || return
  #####################################################################
  ___jq() { jq -rc "$@" 2>/dev/null; }
  ___sed_env() { sed 's|"||g;s|.*=||g' 2>/dev/null || false; }
  ___ls() { ls -A "$1" 2>/dev/null | grep -v '^$' | grep '^' || false; }
  ___curl() { curl -q -LSsf --max-time 1 --retry 0 "$@" 2>/dev/null || return 1; }
  ___grep_file() { grep --no-filename -vsR '#' "$@" 2>/dev/null | grep '^' || return 1; }
  ___find_cmd() { find -L "${1:-$CONFDIR/}" -maxdepth ${3:-3} -type ${2:-f} 2>/dev/null | grep '^' || return 1; }
  ___find_rel() { find -L "${1:-$CONFDIR/}" -maxdepth ${3:-3} -type ${2:-f} -printf "%P\n" 2>/dev/null | grep '^' || return 1; }
  ___grep_env() { GREP_COLORS="" grep -shE '^.*=*..*$' "$1" 2>/dev/null | grep -v '^#' | grep "${2:-^}" | sed 's|"||g' 2>/dev/null | grep '^' || false; }
  #####################################################################
  cur="${COMP_WORDS[$COMP_CWORD]}"
  prev="${COMP_WORDS[$COMP_CWORD - 1]}"
  #####################################################################
  CASJAYSDEVDIR="${CASJAYSDEVDIR:-/usr/local/share/CasjaysDev/scripts}"
  #####################################################################
  CONFFILE="settings.conf"
  CONFDIR="$HOME/.config/myscripts/GEN_SCRIPT_REPLACE_FILENAME"
  SEARCHDIR="${CONFDIR:-$HOME/.config/myscripts/GEN_SCRIPT_REPLACE_FILENAME}"
  #####################################################################
  SHOW_COMP_OPTS=""
  #####################################################################
  SHORTOPTS=""
  SHORTOPTS+=""
  #####################################################################
  LONGOPTS="--completions --config --reset-config --debug --dir --help --options --raw --version --silent --force --no- --yes-"
  LONGOPTS+=""
  #####################################################################
  ARRAY=""
  ARRAY+=""
  #####################################################################
  LIST=""
  LIST+=""
  #####################################################################
  OPTS_NO="--no-* "
  OPTS_YES="--yes-* "
  #####################################################################
  if [ "$SHOW_COMP_OPTS" != "" ]; then
    SHOW_COMP_OPTS_SEP="${SHOW_COMP_OPTS//,/ }"
    compopt -o $SHOW_COMP_OPTS_SEP
  fi
  #####################################################################
  if [[ ${cur} == --no* ]]; then
    COMPREPLY=($(compgen -W '${OPTS_NO}' -- ${cur}))
  elif [[ ${cur} == --yes* ]]; then
    COMPREPLY=($(compgen -W '${OPTS_YES}' -- ${cur}))
  elif [[ ${cur} == --* ]]; then
    COMPREPLY=($(compgen -W '${LONGOPTS}' -- ${cur}))
  elif [[ ${cur} == -* ]]; then
    if [ -n "$SHORTOPTS" ]; then
      COMPREPLY=($(compgen -W '${SHORTOPTS}' -- ${cur}))
    else
      COMPREPLY=($(compgen -W '${LONGOPTS}' -- ${cur}))
    fi
  else
    case "${prev:-${COMP_WORDS[1]}}" in
    --completions)
      prev=""
      COMPREPLY=($(compgen -W 'long short list array' -- "$cur"))
      ;;
    --config | --debug | --help | --options | --raw | --version)
      COMPREPLY=($(compgen -W '${ARRAY} ${LONGOPTS} ${SHORTOPTS}' -- ${cur}))
      return 0
      ;;
    --no-*)
      COMPREPLY=($(compgen -W '${NOOPTS}' -- "$cur"))
      return 0
      ;;
    --dir)
      prev="dir"
      [ "$cword" -le 2 ] && _filedir -d || COMPREPLY=($(compgen -W '${ARRAY}' -- "$cur"))
      ;;
    *)
      COMPREPLY=($(compgen -W '${ARRAY}' -- "$cur"))
      return 0
      ;;
    esac
  fi
  #
  # [ "${ARRAY}" = "show__filedir" ] && _filedir
  # [ ${cword} = 2 ] && _filedir && compopt -o nospace
  # [ "${ARRAY}" != "" ] && COMPREPLY=($(compgen -W '${ARRAY}' -- "${cur}"))
  # [ "${ARRAY}" = "show__none" ] && COMPREPLY=($(compgen -W '' -- "${cur}"))
  # [ "${ARRAY}" = "show__commands" ] && COMPREPLY=($(compgen -c -- "${cur}"))
  # [ $COMP_CWORD -eq 2 ] && COMPREPLY=($(compgen -W '{a..z} {A..Z} {0..9}' -o nospace -- "${cur}"))
  # [ $COMP_CWORD -eq 3 ] && COMPREPLY=($(compgen -W '$(_filedir)' -o filenames -o dirnames -- "${cur}"))
  # [ $COMP_CWORD -gt 3 ] && COMPREPLY=($(compgen -W '' -- "${cur}"))
  # compopt -o nospace
} &&
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # enable completions
  complete -F _GEN_SCRIPT_REPLACE_FILENAME_completion -o default GEN_SCRIPT_REPLACE_FILENAME

# ex: ts=2 sw=2 et filetype=sh
