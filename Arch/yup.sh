#!/usr/bin/env bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#
#set -e set -x
#set -x set -e

ScriptName="$(basename $0)"

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
	echo -e "\e[1;38;5;209m${ScriptName}\e[0m - Package manager helper utility (depends on \e[1myaourt\e[0m -- https://archlinux.fr/yaourt-en and \e[1mreflector\e[0m -- https://wiki.archlinux.org/index.php/Reflector)" >&2
	echo -e "\nUsage: ${0##*/} [-c | --country] [-h | --help] [-m | --mirrors] [-o | --optimize] [-p | --purge] [-r | --refresh-keys] [-u | --update]" >&2
	echo -e "\nOptions:" >&2
	echo -e "  -c, --country CODE\tTwo letters country code from where to generate the mirrorlist" >&2
	echo -e "\t\t\tUse the command \e[1mreflector --list-countries\e[0m to list them" >&2
	echo -e "\t\t\tThe \e[1m-m\e[0m option is implied" >&2
	echo -e "  -h, --help\t\tPrint this help text and exit" >&2
	echo -e "  -m, --mirrors\t\tRetrieve and filter a list of the latest Arch Linux mirrors" >&2
	echo -e "  -o, --optimize\tClean, upgrade and optimize pacman databases" >&2
	echo -e "  -p, --purge\t\tClean ALL files from cache, unused and sync repositories databases" >&2
	echo -e "  -r, --refresh-keys\tRefresh pacman GnuPG keys" >&2
	echo -e "  -u, --update\t\tUpgrades all packages that are out-of-date, package downgrades enabled" >&2
	exit 10;
}

# reflector --list-countries
_CountryCodes=("AU" "AT" "BY" "BE" "BA" "BR" "BG" "CA" "CL" "CN" "CO" "HR" "CZ" "DK" "EC" "FI" "FR" "DE" "GR" "HK" "HU" "IS" "ID" "IE" "IL" "IT" "JP" "KZ" "LV" "LT" "LU" "MK" "NL" "NC" "NO" "PH" "PL" "PT" "QA" "RO" "RU" "SG" "SK" "SI" "ZA" "KR" "ES" "SE" "CH" "TW" "TH" "TR" "UA" "GB" "US" "VN")

isCountry() {
	local cc
	for cc in "${_CountryCodes[@]}"; do [[ "$cc" == $1 ]] && return 0; done
	return 1
}

Mirrors=false
Optimize=false
Purge=false
RefreshKeys=false
Update=false
nReflectorMirrors=10
nReflectorMirrorsAge=12
nReflectorThreads=4
ReflectorCountry=''

WrongOption=""

yupRC="${HOME}"/.config/yuprc

initiateRC() {
	echo "# ${ScriptName} - Package manager helper utility config settings" > "${yupRC}";
	echo "#" >> "${yupRC}";
	echo "#" >> "${yupRC}";
	echo "ReflectorCountry=${ReflectorCountry}" >> "${yupRC}";
	return 1
}

if [ -f "${yupRC}" ]; then
	source "${yupRC}";
fi
if [ -z "${ReflectorCountry}" ]; then
	ReflectorCountry='DE' # DE (Denmark) is the default country code
	initiateRC;
fi


while [[ "$1" == -* ]]; do
	case "$1" in
		-c | --country)
			shift
			isCountry "${1^^}" && {
				ReflectorCountry=${1^^};
				sed -i "/ReflectorCountry/s/=.*/=$(echo ${ReflectorCountry})/" "${yupRC}"
				Mirrors=true;
			} || {
				msg "Invalid country code. Try “${ScriptName} -h” for more information" 1
				exit 20;
			}
			;;

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

		-r | --refresh-keys)
			RefreshKeys=true
			;;

		-u | --update)
			Update=true
			;;

		 *)
			WrongOption=$1
			;;
	esac
	shift
done

# Check options for error
if [[ "${WrongOption}" != "" ]] || [[ -n "$1" ]]; then
	msg "Invalid option "${WrongOption}". Try “${ScriptName} -h” for more information" 1;
	exit 30;
fi

if ! hash yaourt &>/dev/null; then
	msg "\e[1myaourt\e[0m: command not found! See https://archlinux.fr/yaourt-en on how to install it" 1;
	exit 40;
fi

# Grant root privileges
sudo -v || exit 1

if $Mirrors; then
	if hash pacman-mirrors &>/dev/null; then
		echo -e ":: \033[1mRetrieving and Filtering a list of the latest Manjaro-Arch Linux mirrors...\033[0m"
		sudo pacman-mirrors -c Germany -m  rank
	elif ! hash reflector &>/dev/null; then
		msg "\e[1mreflector\e[0m: command not found! Use \e[1msudo pacman -S reflector\e[0m to install it" 2;
	else
		# Grant root privileges
		sudo -v || exit 2
		echo -e ":: \033[1mRetrieving and Filtering a list of the latest Arch Linux mirrors...\033[0m"
		sudo $(which reflector) --country ${ReflectorCountry} --latest ${nReflectorMirrors} --age ${nReflectorMirrorsAge} --fastest ${nReflectorMirrors} --threads ${nReflectorThreads} --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
		echo -e "\n\e[0;94m\e[40m"
		cat /etc/pacman.d/mirrorlist
		echo -e "\e[0;100m\e[0;91m"
		sudo rm -fv /etc/pacman.d/mirrorlist.*
		echo -e "\e[0m"
		# Write any data buffered in memory out to disk
		sudo sync
	fi
fi

### Standard Action
# -y, --refresh
#	Passing two --refresh or -y flags will
#	force a refresh of all package databases, even if they appear to be up-to-date.
# -a, --aur
#	Also search in AUR database.
yaourt --color -Syy --aur --devel # Standard Action

if $RefreshKeys; then
	# Grant root privileges
	sudo -v || exit 3

	echo -e ":: \033[1mRefreshing pacman GnuPG keys...\033[0m"

	Flavours="archlinux"
	KeyRings="archlinux-keyring"
	[[ $(yaourt  -Ssq apricity-keyring) ]] && { Flavours=${Flavours}" apricity"; KeyRings=${KeyRings}" apricity-keyring"; }
	[[ $(yaourt  -Ssq antergos-keyring) ]] && { Flavours=${Flavours}" antergos"; KeyRings=${KeyRings}" antergos-keyring"; }
	[[ $(yaourt  -Ssq manjaro-keyring) ]] && { Flavours=${Flavours}" manjaro"; KeyRings=${KeyRings}" manjaro-keyring"; }

	msg "~> Clear out the downloaded software packages..." 3
	sudo pacman --color always -Scc --noconfirm
	msg "~> Removing & reinitiating the local keys..." 3
	rm -rfv ${HOME}/.gnupg
	gpg --list-keys
	msg "~> Loading trusted certificates..." 3
	sudo touch ${HOME}/.gnupg/dirmngr_ldapservers.conf
	sudo dirmngr < /dev/null
	msg "~> Removing existing trusted keys..." 3
	sudo rm -rfv /var/lib/pacman/sync
	sudo rm -rfv /etc/pacman.d/gnupg
	msg "~> Reinitiating pacman trusted keys..." 3
	sudo pacman-key --init
	sudo pacman-key --populate ${Flavours}
	msg "~> Reinstaling needing packages..." 3
	sudo pacman -Sy --force --noconfirm --quiet gnupg ${KeyRings}
	msg "~> Refreshing pacman trusted keys..." 3
	sudo pacman-key --refresh-keys
	msg "~> Listing pacman's keyring..." 3
	sudo gpg --homedir /etc/pacman.d/gnupg --list-keys
	# Write any data buffered in memory out to disk
	sudo sync
fi

if $Update && [ $(yaourt -Qu --aur | wc -l) -gt 0 ]; then
	# Grant root privileges
	sudo -v || exit 4

	echo -e "\n:: \033[1mUpdating packages...\033[0m"

#	 -u, --sysupgrade
#		Pass this option twice to enable package downgrades; in this case, pacman will select sync packages
#		whose versions do not match with the local versions. This can be useful when the user switches from a
#		testing repository to a stable one.
#	-a, --aur
#		With -u or --sysupgrade, upgrade aur packages that are out of date.
	yaourt --color -Suu --aur
	# Write any data buffered in memory out to disk
	sudo sync
fi

if $Optimize; then
	# Grant root privileges
	sudo -v || exit 5

	echo -e "\n:: \033[1mCleaning, Upgrading and Optimizing pacman databases...\033[0m"

	sudo pacman --color always -Scc --noconfirm
	sudo pacman-db-upgrade
	sudo pacman-optimize
	# Write any data buffered in memory out to disk
	sudo sync
fi

if $Purge; then
	# Grant root privileges
	sudo -v || exit 6

	echo -e "\n:: \033[1mCleaning ALL files from cache, unused and sync repositories databases...\033[0m"

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
			msg "Repositories databases don't exist anymore. You may have to REFRESH them." 2
		}
	fi
fi

exit $?
