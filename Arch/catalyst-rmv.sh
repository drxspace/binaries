#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/   
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___   
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/   
#                                    /_/           drxspace@gmail.com
#
set -e

[[ $EUID -ne 0 ]] && exec $(which sudo) $0

systemctl disable atieventsd
systemctl disable temp-links-catalyst
pacman -Rdd catalyst-total

pacman -S xorg-apps xorg-fonts xf86-input-evdev xf86-video-ati

pacman -S xorg-server xorg-server-utils xorg-xinit mesa xf86-video-vesa xorg-twm xorg-xclock xterm

pacman -S dkms linux linux-headers

#chown -R $(id -un):$(id -gn) <home dirs>
