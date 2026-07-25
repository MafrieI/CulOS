# Containerfile
FROM ghcr.io/ublue-os/kinoite-main:44

# Copy package configurations
COPY recipe.yml /tmp/recipe.yml

# Enable RPM Fusion Repositories for legal NVIDIA drivers and multimedia packages
RUN rpm-ostree install https://rpmfusion.org \
                       https://rpmfusion.org

# Enable performance external repositories for Fedora 44
RUN curl -Lo /etc/yum.repos.d/_copr_bieszczaders-kernel-cachyos.repo https://fedorainfracloud.org && \
    curl -Lo /etc/yum.repos.d/_copr_perabyte-webapp-manager.repo https://fedorainfracloud.org && \
    curl -Lo /etc/yum.repos.d/_copr_lilay-topgrade.repo https://fedorainfracloud.org

# Configure Flathub Repository
RUN flatpak remote-add --if-not-exists flathub https://flathub.org

# Override stock kernel with CachyOS kernel, uninstall Discover, and install core utility toolsets
RUN rpm-ostree override remove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra plasma-discover plasma-discover-flatpak plasma-discover-notifier --install kernel-cachyos && \
    rpm-ostree install firefox distrobox podman fastfetch flatpak webapp-manager topgrade papirus-icon-theme akmod-nvidia xorg-x11-drv-nvidia-cuda kdialog && \
    flatpak install --system -y flathub io.github.dvlv.boxbuddyrs io.github.kolunmi.Bazaar com.usebottles.bottles io.missioncenter.MissionCenter && \
    ostree container commit

# Fetch and provision Google Sans Flex variable typography into the system
RUN mkdir -p /usr/share/fonts/google-sans && \
    curl -Lo /usr/share/fonts/google-sans/GoogleSansFlex.ttf "https://github.com" || \
    curl -Lo /usr/share/fonts/google-sans/GoogleSansFlex.ttf "https://gstatic.com" && \
    fc-cache -f -v

# Force Papirus Dark icons and Google Sans typography system-wide
RUN mkdir -p /etc/xdg && \
    echo '[General]' > /etc/xdg/kdeglobals && \
    echo 'font=Google Sans Flex,10,-1,5,50,0,0,0,0,0' >> /etc/xdg/kdeglobals && \
    echo 'fixed=Google Sans Flex,10,-1,5,50,0,0,0,0,0' >> /etc/xdg/kdeglobals && \
    echo 'smallestReadableFont=Google Sans Flex,8,-1,5,50,0,0,0,0,0' >> /etc/xdg/kdeglobals && \
    echo 'toolBarFont=Google Sans Flex,10,-1,5,50,0,0,0,0,0' >> /etc/xdg/kdeglobals && \
    echo 'menuFont=Google Sans Flex,10,-1,5,50,0,0,0,0,0' >> /etc/xdg/kdeglobals && \
    echo '[Icons]' >> /etc/xdg/kdeglobals && \
    echo 'Theme=Papirus-Dark' >> /etc/xdg/kdeglobals

# Force Snap Assist on window tiling by default
RUN echo '[Tiling]' >> /etc/xdg/kwinrc && \
    echo 'TileAssist=true' >> /etc/xdg/kwinrc

# Set default application handlers for Windows EXE execution triggers via Bottles
RUN mkdir -p /usr/share/mime/packages && \
    echo '<?xml version="1.0" encoding="utf-8"?>' > /usr/share/mime/packages/exe.xml && \
    echo '<mime-info xmlns="http://freedesktop.org">' >> /usr/share/mime/packages/exe.xml && \
    echo '  <mime-type type="application/x-msdos-program">' >> /usr/share/mime/packages/exe.xml && \
    echo '    <glob pattern="*.exe"/>' >> /usr/share/mime/packages/exe.xml && \
    echo '  </mime-type>' >> /usr/share/mime/packages/exe.xml && \
    echo '</mime-info>' >> /usr/share/mime/packages/exe.xml && \
    update-mime-database /usr/share/mime && \
    mkdir -p /usr/share/applications && \
    echo '[Default Applications]' > /usr/share/applications/defaults.list && \
    echo 'application/x-msdos-program=com.usebottles.bottles.desktop' >> /usr/share/applications/defaults.list

# Enable stock background update staging triggers
RUN sed -i 's/#AutomaticUpdatePolicy=none/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
    systemctl enable rpm-ostreed-automatic.timer

# Provision the graphical "Update System" terminal automation utility
RUN echo '#!/bin/bash' > /usr/bin/forza-aggiornamento && \
    echo 'konsole -e "echo === SYSTEM UPDATE STARTED === && topgrade && distrobox upgrade --all && echo === UPDATE COMPLETED! YOU CAN CLOSE THIS WINDOW ===" & \
    kdialog --title "System Update" --msgbox "The update process has started in background inside the terminal. You can reboot once it finishes."' >> /usr/bin/forza-aggiornamento && \
    chmod +x /usr/bin/forza-aggiornamento && \
    echo '[Desktop Entry]' > /usr/share/applications/forza-aggiornamento.desktop && \
    echo 'Name=Update System' >> /usr/share/applications/forza-aggiornamento.desktop && \
    echo 'Comment=Force update of System, Flatpaks, Bazaar and Containers' >> /usr/share/applications/forza-aggiornamento.desktop && \
    echo 'Exec=/usr/bin/forza-aggiornamento' >> /usr/share/applications/forza-aggiornamento.desktop && \
    echo 'Icon=system-software-update' >> /usr/share/applications/forza-aggiornamento.desktop && \
    echo 'Terminal=false' >> /usr/share/applications/forza-aggiornamento.desktop && \
    echo 'Type=Application' >> /usr/share/applications/forza-aggiornamento.desktop && \
    echo 'Categories=System;' >> /usr/share/applications/forza-aggiornamento.desktop

# Compile the standalone "Distro Central" administrative dashboard tool for CulOS
RUN echo '#!/bin/bash' > /usr/bin/distro-central && \
    echo 'ACTION=$(kdialog --menu "CulOS Distro Central - Manage System" \' >> /usr/bin/distro-central && \
    echo '  "1" "Install Steam Only (Native)" \' >> /usr/bin/distro-central && \
    echo '  "2" "Install Steam + Gamescope Session" \' >> /usr/bin/distro-central && \
    echo '  "3" "Remove Gamescope (Keep Steam)" \' >> /usr/bin/distro-central && \
    echo '  "4" "Uninstall Steam + Gamescope (Complete Wipe)" \' >> /usr/bin/distro-central && \
    echo '  "5" "Manage Gaming Tools & Launchers (ProtonPlus, Heroic...)" \' >> /usr/bin/distro-central && \
    echo '  "6" "Enable Windows Snap Assist (Auto-tile windows)" \' >> /usr/bin/distro-central && \
    echo '  "7" "Disable Windows Snap Assist (Restore default)" --title "CulOS Central Hub")' >> /usr/bin/distro-central && \
    echo 'if [ "$ACTION" == "1" ]; then' >> /usr/bin/distro-central && \
    echo '  pkexec rpm-ostree install -y steam && kdialog --msgbox "Steam installed! Reboot to apply."' >> /usr/bin/distro-central && \
    echo 'elif [ "$ACTION" == "2" ]; then' >> /usr/bin/distro-central && \
    echo '  pkexec rpm-ostree install -y steam gamescope gamescope-session-plus && kdialog --msgbox "Steam and Gamescope installed! Reboot to apply."' >> /usr/bin/distro-central && \
    echo 'elif [ "$ACTION" == "3" ]; then' >> /usr/bin/distro-central && \
    echo '  pkexec rpm-ostree override remove gamescope gamescope-session-plus && kdialog --msgbox "Gamescope removed. Steam kept. Reboot to apply."' >> /usr/bin/distro-central && \
    echo 'elif [ "$ACTION" == "4" ]; then' >> /usr/bin/distro-central && \
    echo '  pkexec bootc update --override-remove steam --override-remove gamescope --override-remove gamescope-session-plus && kdialog --msgbox "Gaming environment wiped out. Reboot to apply."' >> /usr/bin/distro-central && \
    echo 'elif [ "$ACTION" == "6" ]; then' >> /usr/bin/distro-central && \
    echo '  mkdir -p ~/.config && kwriteconfig6 --file ~/.config/kwinrc --group Tiling --key TileAssist true && qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure && kdialog --msgbox "Windows Snap Assist Enabled!"' >> /usr/bin/distro-central && \
    echo 'elif [ "$ACTION" == "7" ]; then' >> /usr/bin/distro-central && \
    echo '  mkdir -p ~/.config && kwriteconfig6 --file ~/.config/kwinrc --group Tiling --key TileAssist false && qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure && kdialog --msgbox "Windows Snap Assist Disabled!"' >> /usr/bin/distro-central && \
    echo 'elif [ "$ACTION" == "5" ]; then' >> /usr/bin/distro-central && \
    echo '  TOOLS=$(kdialog --checklist "Select tools to install/update (Flatpaks):" \' >> /usr/bin/distro-central && \
    echo '    "it.miamola.ProtonPlus" "ProtonPlus (Manage Proton Versions)" off \' >> /usr/bin/distro-central && \
    echo '    "com.heroicgameslauncher.hgl" "Heroic Games Launcher" off \' >> /usr/bin/distro-central && \
    echo '    "net.lutris.Lutris" "Lutris" off \' >> /usr/bin/distro-central && \
    echo '    "io.github.prismlauncher.PrismLauncher" "Prism Launcher (Minecraft)" off --title "Gaming Tools")' >> /usr/bin/distro-central && \
    echo '  if [ ! -z "$TOOLS" ]; then' >> /usr/bin/distro-central && \
    echo '    CLEAN_TOOLS=$(echo $TOOLS | tr -d \'"\')' >> /usr/bin/distro-central && \
    echo '    flatpak install --system -y flathub $CLEAN_TOOLS && kdialog --msgbox "Selected tools installed successfully!"' >> /usr/bin/distro-central && \
    echo '  fi' >> /usr/bin/distro-central && \
    fi >> /usr/bin/distro-central && \
    chmod +x /usr/bin/distro-central

# Bind Distro Central into the main KDE Plasma Application Menu layout
RUN echo '[Desktop Entry]' > /usr/share/applications/distro-central.desktop && \
    echo 'Name=CulOS Distro Central' >> /usr/share/applications/distro-central.desktop && \
    echo 'Comment=Manage Steam, Gamescope, Layouts, Launchers and Settings' >> /usr/share/applications/distro-central.desktop && \
    echo 'Exec=/usr/bin/distro-central' >> /usr/share/applications/distro-central.desktop && \
    echo 'Icon=preferences-system' >> /usr/share/applications/distro-central.desktop && \
    echo 'Terminal=false' >> /usr/share/applications/distro-central.desktop && \
    echo 'Type=Application' >> /usr/share/applications/distro-central.desk
