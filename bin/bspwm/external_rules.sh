#!/bin/sh

# set
# bspc config external_rules_command /etc/nixos/bin/bspwm/external_rules.sh

## here's generel info about external_rules
# https://www.reddit.com/r/bspwm/comments/jvsjsl/comment/gcmmoty/
## here's how to get the class_name of a new window
# https://www.reddit.com/r/bspwm/comments/ef2but/comment/fbyn691

# either parse the four inputs to determine what to echo about the node's state
# or use an external tool like xprop and parse e.g. WM_NAME
wid=$1
class=$2
instance=$3
consequences=$4
wname="$(xprop -id "$1" WM_NAME | cut -d\" -f2)"

# print some info
# dunstify "\$1=$(printf '0x%08X' "$1") \$2=$2 \$3=$3" "$4"
# dunstify "$(xprop -id "$1" WM_NAME | cut -d\" -f2)"

# Open some Emacs windows as floating
if [ "${class}" = "Emacs" ]; then
    case "$wname" in
        org*|scratch)
            echo "state=floating"
        ;;
        emacs-everywhere)
            echo "state=floating sticky=on"
        ;;
    esac
fi
