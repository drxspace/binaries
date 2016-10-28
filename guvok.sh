#!/usr/bin/env bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#

if [[ $EUID -ne 0 ]]; then
	exec $(which sudo) "$0"
fi

sed -i 's|^Exec=guvcview$|#Exec=guvcview\n#Exec=guvcview -d /dev/video0\nExec=guvcview -d /dev/video1|' /usr/share/applications/guvcview.desktop && echo "guvok: Injection's okay." || echo "guvok: Injection failed..."

exit 0
