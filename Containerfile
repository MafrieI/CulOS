# Containerfile - CulOS Ottimizzato per prevenire il limite dei Layer
FROM ghcr.io/ublue-os/kinoite-main:44 AS base

# Copia gli script necessari in un'unica operazione
COPY recipe.yml system_skel_configs.sh /tmp/

# Concatenazione delle operazioni in un unico livello strutturale (evita il max depth)
RUN chmod +x /tmp/system_skel_configs.sh && \
    /tmp/system_skel_configs.sh && \
    echo 'id-dependent-activation' > /etc/modules-load.d/nvidia.conf && \
    printf "blacklist nouveau\noptions nouveau modeset=0\n" > /etc/modprobe.d/blacklist-nouveau.conf && \
    printf '#!/bin/bash\nif ! lspci | grep -qi "nvidia"; then\n  echo "No NVIDIA GPU detected. Masking NVIDIA services."\n  systemctl mask nvidia-fallback.service\nfi\n' > /usr/bin/culos-hardware-detect && \
    chmod +x /usr/bin/culos-hardware-detect && \
    printf '[Unit]\nDescription=CulOS Hardware Detection Hook\nBefore=display-manager.service\n\n[Service]\nType=oneshot\nExecStart=/usr/bin/culos-hardware-detect\nRemainAfterExit=yes\n\n[Install]\nWantedBy=multi-user.target\n' > /usr/lib/systemd/system/culos-hardware.service && \
    ln -s /usr/lib/systemd/system/culos-hardware.service /etc/systemd/system/multi-user.target.wants/culos-hardware.service && \
    mkdir -p /etc/xdg && \
    printf "[Icons]\nTheme=Papirus-Dark\n\n[General]\nfont=Google Sans Flex,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1\n" > /etc/xdg/kdeglobals && \
    printf "[Plugins]\ntileassistEnabled=true\n" > /etc/xdg/kwinrc && \
    ostree container commit
