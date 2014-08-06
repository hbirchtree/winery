#Winery

#Initiating test just to make sure all features are present, like associative arrays
[[ $SHELL != /bin/bash ]] && printf "WINERY: Shell is not supported\n" && exit 1

#Global/fundamental options
export WINEARCH=win32 #64-bit Wine prefixes are not very common as of yet
WINEBUILDS_ROOT=$HOME/.local/share/wineversions #location for Wine versions, compatible with the basic structure of a Wine build, where there is a main directory with the folders bin,lib,(lib64),share. Implies compatibility with PlayOnLinux builds. Works statically, will not adapt to different structures.
export IS_WINE_SCRIPT=1 #for use with scripts that can be used independently from Winery
export WINESCRIPTS_DIR="$HOME/.local/share/winescripts" #persists
WINEFUNCTIONS_DIR="$WINESCRIPTS_DIR/modules"
WINETOOLS_DIR="$WINESCRIPTS_DIR/tools" #miscellaneous tools used for Wine, like x360ce and so on.
export WINEPREFIX_ROOT="$HOME/.local/share/wineprefixes" #persists, used in conjunction with the variable WINEPREFIX_ID to provide an easily modifiable way of moving a Wine prefix without having to modify every script.
DESKTOP_ICONS_CUSTOM="$HOME/.local/junk/Icon dump" #for wine-make-script
SYSTEM_XINPUT_MOUSE_DEVICE="Logitech USB-PS/2 Optical Mouse" #persists, used for xinput setting
SYSTEM_XINPUT_KEYBOARD_DEVICE="Logitech Logitech USB Keyboard" #persists, used for xinput setting
source "$WINEFUNCTIONS_DIR/constants.rc" #initializes: STATUS_DIR, printing-etiquette.rc, desktop-notify.rc, WINESCRIPTS_DIR, WINEFUNCTIONS_DIR, gametime directory

[[ ! -d "$WINEFUNCTIONS_DIR" ]] && mkdir -p "$WINEFUNCTIONS_DIR"
[[ ! -d "$WINEBUILDS_ROOT" ]] && mkdir -p "$WINEBUILDS_ROOT"
[[ ! -d "$WINETOOLS_DIR" ]] && mkdir -p "$WINETOOLS_DIR"
[[ ! -d "$WINESCRIPTS_DIR" ]] && mkdir -p "$WINESCRIPTS_DIR"
[[ ! -d "$WINEFUNCTIONS_DIR" ]] && mkdir -p "$WINEFUNCTIONS_DIR"
[[ ! -d "$WINEPREFIX_ROOT" ]] && mkdir -p "$WINEPREFIX_ROOT"

#Simplified functions
WineInitPrefix(){ infoprint "Initializing prefix\n"; wineboot -i;}
WineUpdatePrefix(){ infoprint "Updating prefix\n";wineboot -u;}

#Define the full WINEPREFIX string from the folder name in specific directory.
if [[ -n $WINEPREFIX_ID ]]; then #Ignore if not set, for good backwards compatibility
	if [[ -e "$WINEPREFIX_ROOT/$WINEPREFIX_ID" ]] || [[ -n $WINE_INIT_PREFIX ]]; then
		export WINEPREFIX="$WINEPREFIX_ROOT/$WINEPREFIX_ID"
	else
		errprint "\$WINEPREFIX_ID is not an existing WINE prefix.\n"
		exit 1
	fi
fi
unset WINEPREFIX_ID

[[ -n $WINE_INIT_PREFIX ]] && WineInitPrefix

#General: Some general options that apply to all scripts and make sure that everything is alright. 
[[ -z "$WINEPREFIX" ]] && errprint "\$WINEPREFIX is not defined; please define it.\n" && exit 1
[[ "$WINEPREFIX" = "$WINEPREFIX_ROOT/" ]] && errprint "Incomplete script. Please define \$WINEPREFIX properly.\n" && exit 1

##Start of user-defined options

[[ -e "$WINESCRIPTS_DIR/winery_user.rc" ]] && source "$WINESCRIPTS_DIR/winery_user.rc"

##End of user-defined options

#If no WINEVER is set, the default version will be used.
if [[ -z $WINEVER ]];then
	warnprint "No Wine version was provided. Will default to version $WINE_GLOBAL_WINEVER.\n"
	export WINEVER=$WINE_GLOBAL_WINEVER
fi
export PATH=$WINEBUILDS_ROOT/$WINEVER/bin:$PATH
export LD_LIBRARY_PATH=$WINEBUILDS_ROOT/$WINEVER/lib:$WINEBUILDS_ROOT/$WINEVER/lib64:$LD_LIBRARY_PATH
unset WINEVER WINE_GLOBAL_WINEVER WINE_GAME_HALO_WINEVER WINE_APP_STEAM_WINEVER WINEBUILDS_ROOT

#Variable-based switches
declare -A WINE_LAUNCH_PREFIX_BASH
declare -a WINE_LAUNCH_ARGUMENTS
declare -a WINE_LAUNCH_SUFFIX_RUN

if [[ $GLXOSD = 1 ]];then
	#Not included in Winery, you should compile this yourself.
	infoprint "GLXOSD is enabled\n"
	WINE_LAUNCH_PREFIX_BASH[glxosd]="$WINETOOLS_DIR/glxosd/glxosd" 
#	WINE_LAUNCH_PREFIX_BASH="$WINE_LAUNCH_PREFIX_BASH $WINETOOLS_DIR/glxosd/glxosd" #without associative array
fi

#"Modules", contain several functions, may be reused in other scripts by sourcing them
#source "$WINEFUNCTIONS_DIR/nvidia-opts.rc" #Nvidia-specific options such as GL threading, anisotropic, anti-aliasing and sync to vblank. Exports to environment variables.
source "$WINEFUNCTIONS_DIR/gametimer.rc" #Gametimer, records the amount of time spent in a game. Alternative to Steam's for use with games that are not on Steam. exports to WINE_LAUNCH_PREFIX_BASH[gametimer] given LOG_TIME=1 and LOG_FILE_NAME
source "$WINEFUNCTIONS_DIR/xinput-mouse.rc" #Profiling using xinput, disables mouse acceleration among other things. Functions: xinput_apply_mouse_profile, xinput_reset_mouse_profile, xinput_set_property
#source "$WINEFUNCTIONS_DIR/xboxdrvcontrol.rc" #xboxdrv control, different profiles for different games in an automatic fashion. Functions: loadXboxCfg (var XBOX_CONTROL_LAYOUT), xbxdrv_kill, xbxdrv_detectrun, xbxdrv_reserve, xbxdrv_rmreserve
source "$WINEFUNCTIONS_DIR/regedit-simple.rc" #Registry editing, for quick setting of keys related to WINE and other things. Ugly and big.
source "$WINEFUNCTIONS_DIR/wine-make-script.rc" #Makes scripts for executables. Functions: wine-make-script. Uses the template file and swaps placeholders with values supplied when run. Structure of template file has little importance. Does replace segments of paths with variables for simplified management.
source "$WINEFUNCTIONS_DIR/wine-lba-patch.rc" #Used for allowing programs to use more than 4GB of address space. Useful for games that use big textures or simply use a lot of RAM.
source "$WINEFUNCTIONS_DIR/pulse-opts.rc" #Options for PulseAudio
source "$WINEFUNCTIONS_DIR/wine-x360ce-tools.rc" #For installing x360ce to games

test_environment(){
#Used for quickly getting an overview of the Wine environment.
printf "$(tput bold)$(tput setaf 4)\n$(export)\nDebug parameters: $WINEDEBUG\nPrefix: $WINEPREFIX\nWine binary: $(which wine)\nCurrent directory: $PWD\nWine version: $WINEVER\n$(tput sgr0)"
}
explorer(){ wine explorer;}
regedit(){ wine regedit;}
control(){ wine control;}

#Runtime functions, important for script to work, some ugly methods used. (See: WINE_SCRIPT_INPUT)
wine_prerun_commands(){
#Prepare to run, set up the environment for the Wine program. Allow running other programs in the same environment before and after launch.
WINE_PREWD="$PWD"
cd "$WINE_SCRIPT_DIR"
#loadXboxCfg #used for loading Xboxdrv layout or to insert xpad into kernel
}
wine_quicklaunch(){
if [ "$(echo "$WINE_SCRIPT_INPUT"|wc -c)" -ge 2 ];then
eval $WINE_SCRIPT_INPUT
else
[[ -z $WINE_SCRIPT_EXE ]] && infoprint "No executable was specified in \$WINE_SCRIPT_EXE\n" && return 0
if [[ -f "$WINE_SCRIPT_EXE" ]]; then
${WINE_LAUNCH_PREFIX_BASH[*]} wine $WINE_ARGUMENTS "$WINE_SCRIPT_EXE" $WINE_LAUNCH_SUFFIX_RUN
else
errprint "Executable \"$WINE_SCRIPT_EXE\" not found in directory \"$PWD\"\n"
fi
fi
}
wine_postrun_commands(){
#Reset the environment and clean up. Should reverse what is done in prerun
#[[ xbxdrv_detectrun ]] && [[ $WINEPREFIX != "$WINEPREFIX_ROOT/Steam" ]] && [[ $WINE_DETACHED_START != 1 ]] && xbxdrv_kill
[[ -n $WINE_PREWD ]] && [[ $WINE_PREWD != $PWD ]] && cd "$WINE_PREWD"
xgamma -gamma 1.0 2>/dev/null #Handy for games that mess with gamma while not resetting it.
}

export WINE_LAUNCH_PREFIX_BASH WINE_LAUNCH_ARGUMENTS WINE_LAUNCH_SUFFIX_RUN
unset WINEFUNCTIONS_DIR
