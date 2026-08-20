# culos.ks - Kickstart per installare CulOS (Fedora Kinoite 44)

text
lang it_IT.UTF-8
keyboard --vckeymap=it --layout=it
timezone Europe/Rome --utc

rootpw --lock
user --name=culos --groups=wheel

# Partizionamento automatico semplice
clearpart --all --initlabel
autopart --type=plain

# Standard package installation
%packages
@core
kinoite-core
%end

reboot
