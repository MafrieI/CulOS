#!/bin/bash
# system_skel_configs.sh - Internal Build Validation Hook
set -xeuo pipefail

echo "Executing CulOS System Engineering Build Layer Configuration Modifications..."

# Configure defaults for newly generated users (/etc/skel mirroring)
mkdir -p /etc/skel/.config/kwinrc.d
mkdir -p /etc/skel/.config/flatpak

# Forcibly configure KWin Window Snap Assist functionality 
cat <<EOF > /etc/skel/.config/kwinrc
[Plugins]
tileassistEnabled=true
EOF

# Map structural application configurations over to ensure look-and-feel immutability
cat <<EOF > /etc/skel/.config/kdeglobals
[Icons]
Theme=Papirus-Dark

[General]
font=Google Sans Flex,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
EOF

echo "System Skel and Architecture parameters successfully established."
