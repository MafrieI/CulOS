# Containerfile - CulOS OCI Image Customization Layer
FROM ghcr.io/ublue-os/kinoite-main:44 AS base

# Copy over custom repository keys and script tasks
COPY recipe.yml /tmp/recipe.yml
COPY system_skel_configs.sh /tmp/system_skel_configs.sh

# Run the system build execution steps via BlueBuild architecture tooling
RUN chmod +x /tmp/system_skel_configs.sh && /tmp/system_skel_configs.sh

# NVIDIA Dynamic Activation Architecture configuration
# Modprobe configs to prevent NVIDIA modules from loading if no NVIDIA hardware signature is present
RUN echo 'id-dependent-activation' > /etc/modules-load.d/nvidia.conf && \
    printf "blacklist nouveau\noptions nouveau modeset=0\n" > /etc/modprobe.d/blacklist-nouveau.conf

# Setup systemd initialization script to detect GPU signature on early boot
RUN printf '#!/bin/bash\nif ! lspci | grep -qi "nvidia"; then\n  echo "No NVIDIA GPU detected. Masking NVIDIA services."\n  systemctl mask nvidia-fallback.service\nfi\n' > /usr/bin/culos-hardware-detect && \
    chmod +x /usr/bin/culos-hardware-detect

# Generate custom systemd startup hook for hardware validation
RUN printf '[Unit]\nDescription=CulOS Hardware Detection Hook\nBefore=display-manager.service\n\n[Service]\nType=oneshot\nExecStart=/usr/bin/culos-hardware-detect\nRemainAfterExit=yes\n\n[Install]\nWantedBy=multi-user.target\n' > /usr/lib/systemd/system/culos-hardware.service && \
    ln -s /usr/lib/systemd/system/culos-hardware.service /etc/systemd/system/multi-user.target.wants/culos-hardware.service

# Global Declarative Declarations for KDE Plasma (Typography, Icons, TileAssist)
RUN mkdir -p /etc/xdg && \
    printf "[Icons]\nTheme=Papirus-Dark\n\n[General]\nfont=Google Sans Flex,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1\n" > /etc/xdg/kdeglobals && \
    printf "[Plugins]\ntileassistEnabled=true\n" > /etc/xdg/kwinrc

# Ensure /etc changes persist across transactional operations
RUN ostree container commit
