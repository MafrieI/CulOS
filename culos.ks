# culos.ks - Kickstart per installare CulOS (Fedora Kinoite 44 container) via ostreecontainer

text
lang it_IT.UTF-8
keyboard --vckeymap=it --layout=it
timezone Europe/Rome --utc

rootpw --lock
user --name=culos --groups=wheel

# Partizionamento automatico semplice (puoi adattare a LVM/Btrfs se vuoi)
clearpart --all --initlabel
autopart --type=plain

# Comando chiave: installa l'immagine container CulOS come sistema OSTree
ostreecontainer --url=ostree:image/docker://ghcr.io/<tuo-utente>/culos:44

reboot
