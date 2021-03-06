#!/bin/bash

# Fra
#http://crunchbanglinux.org/forums/topic/15002/wintile-pekwmopenbox-keyboard-window-tilingaerosnapping/
#############################################   CONFIGURATION   #############################################

PANEL_L=$((0))         # If panel is on the LEFT of the screen, set its height here. If there's no panel there, set it to 0.
PANEL_R=$((0))         # If panel is on the RIGHT of the screen, set its height here. If there's no panel there, set it to 0.
PANEL_T=$((18))         # If panel is on the TOP of the screen, set its height here. If there's no panel there, set it to 0.
PANEL_B=$((0))         # If panel is on the BOTTOM of the screen, set its height here. If there's no panel there, set it to 0.
WINDOW_BORDER=$((0))      # Set the window border according to the theme. If there's no window border, set it to 0.
WINDOW_DECORATION=$((0)) # Set the window decoration border according to the theme. If there's no decoration, set it to 0.
#############################################  /CONFIGURATION   #############################################

# Print help:
printUsage ()
{
    echo -e "Invalid command line argument(s)!\nUsage:\n"
    echo -e "`basename "$0"` [options]\n"
    echo -e "Options:\n"
    echo -e "-l  | --left    \tPut the window to the left"
    echo -e "-r  | --right    \tPut the window to the right"
    echo -e "-tl | --top-left\tPut the window to the top-left corner"
    echo -e "-tr | --top-right\tPut the window to the top-right corner"
    echo -e "-bl | --bottom-left\tPut the window to the bottom left corner"
    echo -e "-br | --bottom-right\tPut the window to the bottom right corner"
    echo -e " "
    echo -e "Win_tile 0.2b by Slug.45 2011"
    exit 1
}

# Get Screen resolution:
RES_X=`xdpyinfo | grep 'dimensions:' | cut -f 2 -d ':' | cut -c5-8`
RES_Y=`xdpyinfo | grep 'dimensions:' | cut -f 2 -d ':' | cut -c10-13`

# Functions:
## LEFT
if [ "$#" == "1" ]; then
    case "$1" in
        "-l" | "--left")
        POS_X=$((PANEL_L))
        POS_Y=$((PANEL_T))
        SIZE_X=$((RES_X/2-PANEL_L/2-PANEL_R/2-WINDOW_BORDER))
        echo $RES_Y
        SIZE_Y=$((RES_Y-PANEL_T-PANEL_B-WINDOW_DECORATION))
        wmctrl -r :ACTIVE: -e 0,$POS_X,$POS_Y,$SIZE_X,$SIZE_Y
        exit 0
        ;;
## RIGHT
        "-r" | "--right")
        POS_X=$((RES_X/2))
        POS_Y=$((PANEL_T))
        SIZE_X=$((RES_X/2-PANEL_L/2-PANEL_R/2-WINDOW_BORDER))
        SIZE_Y=$((RES_Y-PANEL_T-PANEL_B-WINDOW_DECORATION))
        wmctrl -r :ACTIVE: -e 0,$POS_X,$POS_Y,$SIZE_X,$SIZE_Y
        exit 0
        ;;
## TOP LEFT
        "-tl" | "--top-left")
        POS_X=$((PANEL_L))
        POS_Y=$((PANEL_T))
        SIZE_X=$((RES_X/2-PANEL_L/2-PANEL_R/2-WINDOW_BORDER))
        SIZE_Y=$((RES_Y/2-PANEL_T/2-PANEL_B/2-WINDOW_DECORATION))
        wmctrl -r :ACTIVE: -e 0,$POS_X,$POS_Y,$SIZE_X,$SIZE_Y
        exit 0
        exit 0
        ;;
## TOP RIGHT
        "-tr" | "--top-right")
        POS_X=$((RES_X/2+PANEL_L/2-PANEL_R/2))
        POS_Y=$((PANEL_T))
        SIZE_X=$((RES_X/2-PANEL_L/2-PANEL_R/2-WINDOW_BORDER))
        SIZE_Y=$((RES_Y/2-PANEL_T/2-PANEL_B/2-WINDOW_DECORATION))
        wmctrl -r :ACTIVE: -e 0,$POS_X,$POS_Y,$SIZE_X,$SIZE_Y
        exit 0
        exit 0
        ;;
## BOTTOM LEFT
        "-bl" | "--bottom-left")
        POS_X=$((PANEL_L))
        POS_Y=$((RES_Y/2+PANEL_T/2-PANEL_B/2))
        SIZE_X=$((RES_X/2-PANEL_L/2-PANEL_R/2-WINDOW_BORDER))
        SIZE_Y=$((RES_Y/2-PANEL_T/2-PANEL_B/2-WINDOW_DECORATION))
        wmctrl -r :ACTIVE: -e 0,$POS_X,$POS_Y,$SIZE_X,$SIZE_Y
        exit 0
        exit 0
        ;;
## BOTOM RIGHT
        "-br" | "--bottom-right")
        POS_X=$((RES_X/2+PANEL_L/2-PANEL_R/2))
        POS_Y=$((RES_Y/2+PANEL_T/2-PANEL_B/2))
        SIZE_X=$((RES_X/2-PANEL_L/2-PANEL_R/2-WINDOW_BORDER))
        SIZE_Y=$((RES_Y/2-PANEL_T/2-PANEL_B/2-WINDOW_DECORATION))
        wmctrl -r :ACTIVE: -e 0,$POS_X,$POS_Y,$SIZE_X,$SIZE_Y
        exit 0
        exit 0
        ;;
        *)
            printUsage
            exit 1
            ;;
    esac
else
    printUsage
    exit 1
fi

