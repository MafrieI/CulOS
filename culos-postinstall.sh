#!/bin/bash
# culos-postinstall.sh - CulOS first boot: CachyOS kernel, extra packages, automatic updates (no auto reboot)
set -xeuo pipefail

echo "== CulOS post-install: abilito rpmfusion free + nonfree =="

rpm-ostree install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

echo "== Aggiungo repo COPR CachyOS per Fedora =="

wget \
  "https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/repo/fedora-$(rpm -E %fedora)/bieszczaders-kernel-cachyos-fedora-$(rpm -E %fedora).repo" \
  -O /etc/yum.repos.d/bieszczaders-kernel-cachyos.repo

echo "== Sostituisco kernel Fedora con kernel CachyOS (override) =="

rpm-ostree override remove \
  kernel \
  kernel-core \
  kernel-modules \
  kernel-modules-core \
  kernel-modules-extra \
  --install kernel-cachyos

echo "== Installo pacchetti extra CulOS =="

rpm-ostree install \
  podman \
  distrobox \
  akmod-nvidia \
  xorg-x11-drv-nvidia-cuda \
  mesa-vulkan-drivers \
  google-sans-flex-fonts \
  papirus-icon-theme

echo "== Configuro aggiornamenti automatici rpm-ostree (policy: stage, nessun reboot automatico) =="

cat > /etc/rpm-ostreed.conf << 'EOF'
[Daemon]
AutomaticUpdatePolicy=stage
EOF

# Ricarica la configurazione del demone
rpm-ostree reload || true

# Abilita il timer di aggiornamento automatico
systemctl enable rpm-ostreed-automatic.timer --now || true

echo "== CulOS post-install completo: riavvia quando vuoi per usare il nuovo kernel CachyOS ed eventuali aggiornamenti =="

# Disabilita il servizio di primo boot per evitare che si ripeta
systemctl disable culos-init.service || true
