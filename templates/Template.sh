#! /bin/bash
#Variables prefixed with WINE_SCRIPT have to do with the script itself and its launch and are required for the script to work.
#Variables prefixed with WINE_DESKTOP are optional, but when used in conjunction with "Make launcher", a Nautilus script, will generate a fully functional desktop file. "Make launcher" needs to be placed in .local/share/nautilus/scripts/ in order to work. This format is used for being able to generate desktop files that are informative and simple to make, not having to write them manually.
export WINEPREFIX_ID=
WINEVER=
source "$HOME/.local/share/winescripts/winery.sh"
WINE_SCRIPT_INPUT="$@"
WINE_DETACHED_START=
WINE_SCRIPT_DIR="%{GAMEPATH}"
WINE_SCRIPT_EXE="%{GAMEBIN}"
WINE_DESKTOP_ICON="$DESKTOP_ICONS_CUSTOM/"
WINE_DESKTOP_DISPLAYNAME=""
WINE_DESKTOP_DESCRIPTION=""
WINE_DESKTOP_WMCLASS=""
wine_prerun_commands
wine_quicklaunch
wine_postrun_commands

#explorer /desktop=TITLE,1920x1200 EXE

#Used for making quicklists. Confirmed to work with Ubuntu Unity, not tested with any other environment. Your mileage may vary.
#quicklist_item:launcher:Title with spaces
launcher(){
WINE_SCRIPT_DIR=
WINE_SCRIPT_EXE=
wine_quicklaunch
}
