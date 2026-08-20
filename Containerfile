# Containerfile - CulOS base image (Fedora Kinoite 44 + config + first-boot setup)

FROM ghcr.io/ublue-os/kinoite-main:44

LABEL org.opencontainers.image.title="CulOS"
LABEL org.opencontainers.image.description="Immutable KDE CulOS based on Fedora Kinoite 44"
LABEL org.opencontainers.image.version="44"

# Configurazioni KDE globali (puoi usare queste o i tuoi file)
COPY kdeglobals /etc/xdg/kdeglobals
COPY kwinrc /etc/xdg/kwinrc

# Script di primo boot (kernel CachyOS + pacchetti + auto-update)
COPY culos-postinstall.sh /usr/local/sbin/culos-postinstall.sh

# Unit systemd per eseguire lo script al primo boot
COPY culos-init.service /usr/lib/systemd/system/culos-init.service

RUN set -xeuo pipefail && \
    # Script eseguibile
    chmod +x /usr/local/sbin/culos-postinstall.sh && \
    \
    # Directory per i symlink systemd
    mkdir -p /etc/systemd/system/multi-user.target.wants && \
    \
    # Abilita il servizio CulOS di primo boot
    ln -sf /usr/lib/systemd/system/culos-init.service \
           /etc/systemd/system/multi-user.target.wants/culos-init.service
