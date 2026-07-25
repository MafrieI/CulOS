# ==========================================
# STAGE 1: Preleva l'immagine originale satura di layer
# ==========================================
FROM ghcr.io/ublue-os/kinoite-main:44 AS upstream-source

# ==========================================
# STAGE 2: Ambiente temporaneo Fedora per pulizia e tweak
# ==========================================
FROM registry.fedoraproject.org/fedora:44 AS builder

# Crea una cartella per isolare il file system finale
RUN mkdir -p /rootfs

# Estrai l'intero file system di Kinoite appiattendolo in un unico blocco
COPY --from=upstream-source / /rootfs/
COPY recipe.yml system_skel_configs.sh /rootfs/tmp/

# Applica le configurazioni di CulOS scrivendole direttamente sul file system piatto
RUN chmod +x /rootfs/tmp/system_skel_configs.sh && \
    /rootfs/tmp/system_skel_configs.sh && \
    mkdir -p /rootfs/etc/modules-load.d /rootfs/etc/modprobe.d /rootfs/usr/bin /rootfs/etc/xdg /rootfs/usr/lib/systemd/system && \
    echo 'id-dependent-activation' > /rootfs/etc/modules-load.d/nvidia.conf && \
    printf "blacklist nouveau\noptions nouveau modeset=0\n" > /rootfs/etc/modprobe.d/blacklist-nouveau.conf && \
    printf '#!/bin/bash\nif ! lspci | grep -qi "nvidia"; then\n  echo "No NVIDIA GPU detected. Masking NVIDIA services."\n  systemctl mask nvidia-fallback.service\nfi\n' > /rootfs/usr/bin/culos-hardware-detect && \
    chmod +x /rootfs/usr/bin/culos-hardware-detect && \
    printf '[Unit]\nDescription=CulOS Hardware Detection Hook\nBefore=display-manager.service\n\n[Service]\nType=oneshot\nExecStart=/usr/bin/culos-hardware-detect\nRemainAfterExit=yes\n\n[Install]\nWantedBy=multi-user.target\n' > /rootfs/usr/lib/systemd/system/culos-hardware.service && \
    ln -sf /usr/lib/systemd/system/culos-hardware.service /rootfs/etc/systemd/system/multi-user.target.wants/culos-hardware.service && \
    printf "[Icons]\nTheme=Papirus-Dark\n\n[General]\nfont=Google Sans Flex,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1\n" > /rootfs/etc/xdg/kdeglobals && \
    printf "[Plugins]\ntileassistEnabled=true\n" > /rootfs/etc/xdg/kwinrc && \
    rm -f /rootfs/tmp/recipe.yml /rootfs/tmp/system_skel_configs.sh

# ==========================================
# STAGE 3: Immagine finale CulOS (Profondità Layer: 1)
# ==========================================
FROM scratch
COPY --from=builder /rootfs /

# Variabili d'ambiente necessarie all'architettura ostree/atomic
ENV IMAGE_NAME="culos"
ENV FEDORA_VERSION="44"
CMD ["/usr/lib/systemd/systemd"]
