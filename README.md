# CulOS

CulOS is my own opinionated, gaming‑friendly, KDE‑centric immutable distro built on Fedora Kinoite 44, with a CachyOS kernel bolted on and rpm‑ostree handling atomic updates under the hood. [fedora.gitlab](https://fedora.gitlab.io/ostree/docs/fedora-atomic-desktops/updates-upgrades-rollbacks/)

I basically took “Kinoite”, sent it to the gym, gave it better shoes, and told it to stop breaking itself with random `dnf upgrade` adventures.

***

## What CulOS is (from my point of view)

I wanted:

- A **serious, stable base**, so I picked Fedora Atomic Desktop (Kinoite 44) and kept its OSTree model: atomic upgrades, clean rollbacks, and a base system that doesn’t slowly rot just because I tried one cursed package in 2024. [github](https://github.com/coreos/rpm-ostree/blob/main/docs/administrator-handbook.md)
- A **snappier kernel**, so I wired in the CachyOS kernel using `rpm-ostree override remove ... --install kernel-cachyos`, following the way people install custom kernels on Silverblue/Kinoite. [coreos.github](https://coreos.github.io/rpm-ostree/administrator-handbook/)
- A **sane default toolbox**: podman, distrobox, NVIDIA drivers, Vulkan bits, fonts, icon themes, and KDE tweaks, added as layered packages and global `/etc/xdg` configs so new users (including me) land in a nice setup without spending the first evening in `nano` and `dconf-editor`. [travier.github](https://travier.github.io/rpm-ostree/administrator-handbook/)

So CulOS, to me, is “Kinoite 44, but tuned like I’m the slightly obsessive friend who already broke their system three times, learned from it, and now bakes the lessons into the image.”

***

## What the installer and system do for me

When I boot the CulOS ISO:

- I get the familiar **Fedora Anaconda wizard**, but under the hood it uses the `ostreecontainer` Kickstart command to install my CulOS container image as the system, instead of reconstructing everything from individual RPMs. [pykickstart.readthedocs](https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html)
- On the **first boot**, a systemd unit I wrote runs `culos-postinstall.sh`, which:
  - enables rpmfusion,  
  - adds the CachyOS COPR,  
  - replaces the Fedora kernel with `kernel-cachyos`,  
  - installs my extra packages (podman, distrobox, NVIDIA stack, etc.),  
  - configures rpm‑ostree automatic updates with `AutomaticUpdatePolicy=stage`, so updates are fetched and staged but I decide when to reboot. [fedorafaq](https://www.fedorafaq.com/en/how-to-override-packages-in-rpm-ostree-override-remove-override-replace/)

From then on, my system quietly keeps itself up to date in the background, while I stay in control of the reboot button.

***

## How and why I built it

I was bored — the dangerous kind of boredom where you open a terminal instead of Netflix — and I started **vibe‑coding a distro** with Gemini and Perplexity, mixing my weird requirements:  

- “Immutable, but flexible.”  
- “Gaming‑friendly, but not a meme OS.”  
- “Automatic updates, but no Windows‑style surprise reboots.”  

So I:

- re‑used the same tech stack real projects like Bazzite and Universal Blue use (Fedora Atomic, rpm‑ostree, container images, Kickstart `ostreecontainer`), [osbuild](https://osbuild.org/docs/on-premises/commandline/building-ostree-images/)
- added my personal flavor with CachyOS kernel, KDE tweaks, and a first‑boot script that does the heavy lifting once and then gets out of the way.  

In short: CulOS is both a legit, technically solid immutable distro, and a “I got bored and built exactly what I wanted, with two AI copilots and a slightly questionable sense of humor” project that I actually plan to use.

Oh this description is also AI generated
