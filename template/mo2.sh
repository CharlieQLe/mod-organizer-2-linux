#!/bin/bash

# CHANGE IF NECESSARY
MO2_DIR="%MO2_DIR%"
PROTON="%PROTON%"

# DO NOT CHANGE
MO2_PREFIX="$MO2_DIR/proton"
MO2_EXE="$MO2_DIR/mo2/ModOrganizer.exe"
NXM_HANDLER="$MO2_DIR/mo2/nxmhandler.exe"
STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam"

# Checks if mo2 is running by looking for the file 'instance_data'
function mo2_is_running () {
    [ -f "$MO2_DIR/instance_data" ]
}

# Launch MO2
function launch_mo2 () {
    # If MO2 is already running, then do not try to run MO2 and exit the script
    if mo2_is_running; then
        echo "Mod Organizer 2 is already running!"
        return 1
    fi

    # If STEAM_COMPAT_DATA_PATH is not defined, then set it to MO2_PREFIX, which is defined above
    # Otherwise, symlink the ModOrganizer folder from the MO2 Prefix to the current prefix
    if [ -z ${STEAM_COMPAT_DATA_PATH+x} ]; then
        export STEAM_COMPAT_DATA_PATH="$MO2_PREFIX"
        echo "Running outside of Steam! Setting prefix path..."
    else
        # If STEAM_COMPAT_DATA_PATH is defined, then this is running via Steam,
        # which means symlink the MO2 instances over automatically if needed
        if [ -L "$STEAM_COMPAT_DATA_PATH/pfx/drive_c/users/steamuser/AppData/Local/ModOrganizer" ]; then
            echo "Mod Organizer 2 already linked!"
        else
            mkdir -p "$STEAM_COMPAT_DATA_PATH/pfx/drive_c/users/steamuser/AppData/Local"
            if [ -d "$MO2_PREFIX/pfx/drive_c/users/steamuser/AppData/Local/ModOrganizer" ]; then
                ln -s "$MO2_PREFIX/pfx/drive_c/users/steamuser/AppData/Local/ModOrganizer" "$STEAM_COMPAT_DATA_PATH/pfx/drive_c/users/steamuser/AppData/Local"
                echo "Linking Mod Organizer 2..."
            else
                echo "ModOrganizer AppData folder not found!"
                exit 1
            fi
        fi
    fi

    # Create 'instance_data', with contents of STEAM_COMPAT_DATA_PATH
    echo "$STEAM_COMPAT_DATA_PATH" > "$MO2_DIR/instance_data"

    # Run MO2
    "$PROTON" run "$MO2_EXE"

    # Delete 'instance_data'
    rm "$MO2_DIR/instance_data"
}

# Launch the NXM handler. Its only argument is the NXM link
function launch_nxm_handler () {
    if mo2_is_running; then
        echo "Found Mod Organizer 2 instance data!"
    else
        echo "Mod Organizer 2 is not running!"
        return 1
    fi
    export STEAM_COMPAT_DATA_PATH=$(cat "$MO2_DIR/instance_data")
    "$PROTON" run "$NXM_HANDLER" "$1"
}

# Exit if the required directories and files do not exist
if ! [ -d "$MO2_DIR" ]; then
    echo "The Mod Organizer 2 directory does not exist!"
    exit 1
fi
if ! [ -f "$MO2_EXE" ]; then
    echo "The Mod Organizer 2 executable does not exist!"
    exit 1
fi
if ! [ -d "$STEAM_COMPAT_CLIENT_INSTALL_PATH" ]; then
    echo "The Steam directory does not exist!"
    exit 1
fi
if ! [ -f "$PROTON" ]; then
    echo "The Proton binary does not exist!"
    exit 1
fi

# Ensure the prefix is created
mkdir -p "$MO2_PREFIX"

# Handle arguments
if [ $# -gt 1 ]; then
    echo "There can only be zero or one argument!"
    exit 1
elif [ $# -eq 1 ]; then
    if [[ "$1" == nxm://* ]]; then
        launch_nxm_handler "$1"
        exit $?
    else
        echo "Invalid NXM link!"
        exit 1
    fi
fi

# Run MO2
launch_mo2
exit $?
