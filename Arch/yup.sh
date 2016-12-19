#!/usr/bin/env bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#
#set -e
#set -x

ScriptName="$(basename $0)"

Mirrors=false
Optimize=false
Purge=false

WrongOption=""

ReflectorCountry='US' # reflector --list-countries
nReflectorMirrors=6
nReflectorMirrorsAge=12
nReflectorThreads=4

msg() {
	local msgStartOptions=""
	local msgEndOptions="\e[0m"

	case $2 in
		0|"")	# Generic message
			msgStartOptions="\e[1;33m${ScriptName}\e[0m: \e[94m"
			;;
		1)	# Error message
			msgStartOptions="\e[1;31m${ScriptName}\e[0m: \e[91m"
			;;
		2)	# Warning
			msgStartOptions="\e[1;38;5;209m${ScriptName}\e[0m: \e[93m"
			;;
		3)	# Information
			msgStartOptions="\e[1;94m${ScriptName}\e[0m: \e[94m"
			;;
		4)	# Success
			msgStartOptions="\e[1;92m${ScriptName}\e[0m: \e[32m"
			;;
		*)	# Fallback to Generic message
			msgStartOptions="\e[1;33m${ScriptName}\e[0m: \e[94m"
			;;
	esac

	echo -e "${msgStartOptions}${1}${msgEndOptions}";
}

ShowHelp() {
	echo "${ScriptName} - Package manager helper utility" >&2
	echo
	echo "Usage: ${0##*/} [-h | --help] [-m | --mirrors] [-o | --optimize] [-p | --purge]" >&2
	echo
	echo "Options:"
	echo -e "  -h, --help\t\tprint this help text and exit ;)"
	echo -e "  -m, --mirrors\t\tretrieve and filter a list of the latest Arch Linux mirrors first"
	echo -e "  -o, --optimize\tclean, upgrade and optimize pacman databases also"
	echo -e "  -p, --purge\t\tclean ALL files from cache, unused and sync repositories databases also"
	exit 20;
}




while [[ "$1" == -* ]]; do
	case $1 in
		-h | --help)
			ShowHelp
			;;

		-m | --mirrors)
			Mirrors=true
			;;

		-o | --optimize)
			Optimize=true
			;;

		-p | --purge)
			Purge=true
			;;

		 *)
			WrongOption=$1
			;;
	esac
	shift
done

# Check options for error
if [[ "$WrongOption" != "" ]] || [[ -n "$1" ]]; then
	msg "Invalid option. Try “${ScriptName} -h” for more information" 2;
	exit 10;
fi

if ! hash yaourt &>/dev/null; then
	msg "\e[1myaourt\e[0m: command not found! See https://archlinux.fr/yaourt-en on how to install it" 2;
	exit 1;
fi

# Grant root privileges
sudo -v || exit 2

if $Mirrors; then
	if ! hash reflector &>/dev/null; then
		msg "\e[1mreflector\e[0m: command not found! Use \e[1msudo pacman -S reflector\e[0m to install it" 2;
	else
		echo -e ":: \033[1mRetrieving and Filtering a list of the latest Arch Linux mirrors...\033[0m"

		sudo $(which reflector) --country ${ReflectorCountry} --latest ${nReflectorMirrors} --age ${nReflectorMirrorsAge} --fastest ${nReflectorMirrors} --threads ${nReflectorThreads} --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
		echo -e "\n\e[0;94m\e[40m"
		cat /etc/pacman.d/mirrorlist
		echo -e "\e[0;100m\e[0;91m"
		sudo rm -fv /etc/pacman.d/mirrorlist.*
		echo -e "\e[0m"
	fi
fi

# -y, --refresh
#	Passing two --refresh or -y flags will
#	force a refresh of all package databases, even if they appear to be up-to-date.
# -u, --sysupgrade
#	Pass this option twice to enable package downgrades; in this case, pacman will select sync packages
#	whose versions do not match with the local versions. This can be useful when the user switches from a
#	testing repository to a stable one.
# -a, --aur
#	Also search in AUR database.
yaourt --color -Syyuua

if $Optimize; then
	echo -e "\n:: \033[1mCleaning, Upgrading and Optimizing pacman databases...\033[0m"

	sudo pacman --color always -Scc --noconfirm
	sudo pacman-db-upgrade
	sudo pacman-optimize && sudo sync
fi

if $Purge; then
	echo -e "\n:: \033[1mCleaning ALL files from cache, unused and sync repositories databases...\033[0m"

	if [[ -d /var/lib/pacman/sync ]]; then
		if [[ -n $(pacman --color always -Qqdt) ]]; then sudo pacman --color always -Rs $(pacman -Qqdt); fi
		# -c, --clean
		#	Use one --clean switch to only remove packages that are no
		#	longer installed; use two to remove all files from the cache. In both cases, you will have a yes or no
		#	option to remove packages and/or unused downloaded databases.
		sudo pacman --color always -Scc

		echo -e "\nPacman sync repositories directory: /var/lib/pacman/sync"
		echo -en ":: \033[1mDo you want to remove ALL the sync repositories databases? [y/N] \033[0m"
		read ANS
		[[ ${ANS:-N} == [Yy] ]] && {
			echo "removing all sync repositories..."
			sudo rm -rfv /var/lib/pacman/sync
			msg "Repositories databases don't exist anymore. You may have to REFRESH them." 2
		}
	fi
fi

exit $?
