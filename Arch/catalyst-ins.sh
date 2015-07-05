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

pacman -S catalyst-utils catalyst-libgl lib32-catalyst-utils lib32-catalyst-libgl catalyst-generator
catalyst_build_module
aticonfig -f --initial

systemctl enable temp-links-catalyst
systemctl start temp-links-catalyst
systemctl daemon-reload
