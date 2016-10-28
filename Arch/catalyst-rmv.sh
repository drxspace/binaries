#!/usr/bin/env bash
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

pacman -S xorg-server xorg-server-common xorg-server-xwayland xorg-server-utils xorg-xinit mesa xorg-apps xorg-fonts xorg-twm xorg-xclock xterm

pacman -S xf86-input-evdev xf86-video-vesa xf86-video-ati

cp -fv /etc/X11/xorg.conf.original-0 /etc/X11/xorg.conf

pacman -S dkms linux linux-headers

#chown -R $(id -un):$(id -gn) <home dirs>
