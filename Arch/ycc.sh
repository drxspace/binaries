#!/bin/bash
#

if [[ $EUID -ne 0 ]]; then
	exec $(which sudo) $0
fi

if [[ -d /var/lib/pacman/sync ]]; then
	if [[ -n $(pacman -Qqdt) ]]; then pacman -Rs $(pacman -Qqdt); fi
	pacman -Scc
	# Removes all the sync repositories .db also?
	echo -en "\n:: \033[1mDo you want to remove all the sync repositories .db also? [y/N]: \033[0m"
	read ANS
	[[ ${ANS:-N} == [Yy] ]] && {
		echo "removing all sync repositories..."
		rm -rfv /var/lib/pacman/sync
	}
fi