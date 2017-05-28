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
	exec $(which sudo) "$0" || exit 1
fi

if [[ -d /var/lib/pacman/sync ]]; then
	# Cleaning an Arch Linux installation
	# https://andreascarpino.it/posts/cleaning-an-arch-linux-installation.html
	if [[ -n $(pacman --color always -Qqdtt) ]]; then
		sudo pacman --color always -Rs $(pacman -Qqdtt);
	fi

	# -c, --clean
	#	Use one --clean switch to only remove packages that are no
	#	longer installed; use two to remove all files from the cache. In both cases, you will have a yes or no
	#	option to remove packages and/or unused downloaded databases.
	#sudo pacman --color always -Scc
	yaourt -Scc

	echo -e "\nPacman sync repositories directory: /var/lib/pacman/sync"
	echo -en ":: \033[1mDo you want to remove ALL the sync repositories databases? [y/N] \033[0m"
	read ANS
	[[ ${ANS:-N} == [Yy] ]] && {
		echo "removing all sync repositories..."
		sudo rm -rfv /var/lib/pacman/sync
		echo -e "\e[93mRepositories databases don't exist anymore. You may have to REFRESH them.\e[0m"
	}

	# Write any data buffered in memory out to disk
	sudo sync
fi

exit $?
