#!/bin/bash

if ! type "7z" > /dev/null; then
    echo "7z not found. Install p7zip from your distro's repositories!"
    exit 1
fi

if [ $# -ne 1 ]; then
    echo "Proton binary not found! Please specify the path to the version of proton you want to use!"
    exit 1
fi

PROTON="$1/proton"
if ! [ -f "$PROTON" ]; then
    echo "Proton binary not found! Please specify the path to the version of proton you want to use!"
    exit 1
fi

DEFAULT_MO2_DIR="$HOME/.local/share/mod-organizer-2"

if [ -z ${MO2_DIR+x} ]; then
    export MO2_DIR="$DEFAULT_MO2_DIR"
fi

# Create folders
mkdir -p "$HOME/.local/bin"
mkdir -p "$MO2_DIR"
mkdir -p "$MO2_DIR/mo2"
mkdir -p "$MO2_DIR/proton"

# Copy icon
cp icon.png "$MO2_DIR/icon.png"

# Download Mod Organizer 2
wget -O "/tmp/ModOrganizer2.7z" "https://github.com/ModOrganizer2/modorganizer/releases/download/v2.4.4/Mod.Organizer-2.4.4.7z"

# Extract files
7z x "/tmp/ModOrganizer2.7z" -o"$MO2_DIR/mo2" -aoa

# Install template file
cp template/mo2.sh /tmp/mo2.sh
sed -i -e "s|%MO2_DIR%|$MO2_DIR|g" "/tmp/mo2.sh"
sed -i -e "s|%PROTON%|$PROTON|g" "/tmp/mo2.sh"
install -D -m755 /tmp/mo2.sh "$HOME/.local/bin/mod-organizer-2"

# Install desktop file
cp template/mod-organizer-2.desktop /tmp/mod-organizer-2.desktop
sed -i -e "s|%MO2_RUN%|$HOME/.local/bin/mod-organizer-2|g" "/tmp/mod-organizer-2.desktop"
sed -i -e "s|%MO2_DIR%|$MO2_DIR|g" "/tmp/mod-organizer-2.desktop"
sed -i -e "s|%MO2_ICON%|$MO2_DIR/icon.png|g" "/tmp/mod-organizer-2.desktop"
desktop-file-install --dir="$HOME/.local/share/applications" --rebuild-mime-info-cache /tmp/mod-organizer-2.desktop