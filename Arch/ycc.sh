#!/bin/bash
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

if [[ -d /var/lib/pacman/sync ]]; then
	if [[ -n $(pacman -Qqdt) ]]; then pacman -Rs $(pacman -Qqdt); fi
	pacman -Scc

	echo -e "\nPacman sync repositories directory: /var/lib/pacman/sync"
	echo -en ":: \033[1mDo you want to remove all the sync repositories databases? [y/N] \033[0m"
	read ANS
	[[ ${ANS:-N} == [Yy] ]] && {
		echo "removing all sync repositories..."
		rm -rfv /var/lib/pacman/sync
	}
fi
