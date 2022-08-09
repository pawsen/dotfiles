# -*- mode: shell-script -*-

dirwatch() {
    inotifywait -m $1 -e create -e move -e delete |
        while read thepath action file; do
            echo "$action $file"
        done
}

# copy to old dir by using $od
# trap runs the command when it traps the bash exit signal
tmp () (
    export od=$PWD
    export tmpd=$(mktemp -d)
    trap "\rm -rf $tmpd" 0
    cd $tmpd
    echo 'Exported variables $od & $tmpd'
    $SHELL -l
)

# A shortcut function that simplifies usage of xclip.
# - Accepts input from either stdin (pipe), or params.
# ------------------------------------------------
cb() {
  local _scs_col="\e[0;32m"; local _wrn_col='\e[1;31m'; local _trn_col='\e[0;33m'
  # Check that xclip is installed.
  if ! type xclip > /dev/null 2>&1; then
    echo -e "$_wrn_col""You must have the 'xclip' program installed.\e[0m"
  # Check user is not root (root doesn't have access to user xorg server)
  elif [[ "$USER" == "root" ]]; then
    echo -e "$_wrn_col""Must be regular user (not root) to copy a file to the clipboard.\e[0m"
  else
    # If no tty, data should be available on stdin
    if ! [[ "$( tty )" == /dev/* ]]; then
      input="$(< /dev/stdin)"
    # Else, fetch input from params
    else
      input="$*"
    fi
    if [ -z "$input" ]; then  # If no input, print usage message.
      echo "Copies a string to the clipboard."
      echo "Usage: cb <string>"
      echo "       echo <string> | cb"
    else
      # Copy input to clipboard
      echo -n "$input" | xclip -selection c
      # Truncate text for status
      if [ ${#input} -gt 80 ]; then input="$(echo $input | cut -c1-80)$_trn_col...\e[0m"; fi
      # Print status.
      echo -e "$_scs_col""Copied to clipboard:\e[0m $input"
    fi
  fi
}
# Aliases / functions leveraging the cb() function
# ------------------------------------------------
# Copy contents of a file
function cbf() { cat "$1" | cb; }
# Copy current working directory
alias cbwd="pwd | cb"
# Copy most recent command in bash history
alias cbhs="cat $HISTFILE | tail -n 1 | cb"

# opens up a man-page directly to a given flag, i.e. manf ls -l opens the
# man-page for less directly to the point that describes the -l switch.
function manf() {
    man -P "less -p \"^ +$2\"" $1
}

# https://bbs.archlinux.org/viewtopic.php?pid=697235#p697235
function cpf() {
   cp "$@" && goto "$_";
}

function mvf() {
   mv "$@" && goto "$_";
}
function mkf() {
   mkdir -vp "$@" && cd "$_";
}

function extract() {
   if [ -f "$1" ] ; then
      case "$1" in
         *.tar.bz2)   tar xvjf "$1"    ;;
         *.tar.xz)    tar xf "$1"    ;;
         *.tar.gz)    tar xvzf "$1"    ;;
         *.bz2)       bunzip2 "$1"     ;;
         *.rar)       unrar x "$1"     ;;
         *.gz)        gunzip "$1"      ;;
         *.tar)       tar xvf "$1"     ;;
         *.tbz2)      tar xvjf "$1"    ;;
         *.tgz)       tar xvzf "$1"    ;;
         *.zip)       unzip "$1"       ;;
         *.Z)         uncompress "$1"  ;;
         *.7z)        7z x "$1"        ;;
         *)           echo "don't know how to extract '$1'..." ;;
      esac
   else
      echo "'$1' is not a valid file"
   fi
}
function mktar() {
   tar cvf  "${1%%/}.tar"     "${1%%/}/";
}
function mktgz() {
   tar cvzf "${1%%/}.tar.gz"  "${1%%/}/";
}
function mktbz() {
   tar cvjf "${1%%/}.tar.bz2" "${1%%/}/";
}

####################################
## Getting undefined references?  ##
## Grep your libs for symbols     ##
####################################
function greplib(){
    if [ ! "$1" ]; then
        echo "Usage : greplib [symbol] (lookup path)"
        return
    fi

    if [ ! "$2" ]; then
        nm -a -o /usr/lib/*.so 2> /dev/null | grep $1
        nm -a -o /usr/lib/*.a  2> /dev/null | grep $1
    else
        nm -a -o $2/*.so 2> /dev/null | grep $1
        nm -a -o $2/*.a  2> /dev/null | grep $1
    fi
}
