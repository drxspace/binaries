#!/bin/bash -e
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

# List of countries with Arch Linux repository mirrorlists that we want to participate to the rank
declare -a COUNTRIES=("BG" "DE" "FR" "GR" "RO" "IT")

# Download the Arch Linux repository mirrorlist
echo -en "\e[1;34m::\e[0;34m Downloading the Arch Linux repository mirrorlist. Please wait..."
wget -q -N "https://www.archlinux.org/mirrorlist/?country=${COUNTRIES[0]}&country=${COUNTRIES[1]}&country=${COUNTRIES[2]}&country=${COUNTRIES[3]}&country=${COUNTRIES[4]}&country=${COUNTRIES[5]}&protocol=http&protocol=https&ip_version=4&use_mirror_status=on" -O- | grep -E "^#Server" | sed 's/^#//' > /tmp/mirrorlist.tmp

## Rank the mirrors using the included Bash script ‘/usr/bin/rankmirrors’. Operand -n 6 means only output the 6 fastest mirrors
echo -en "\n\e[1;34m::\e[0;34m Ranking the mirrors. Please wait..."
$(which rankmirrors) -n 6 /tmp/mirrorlist.tmp > /etc/pacman.d/mirrorlist

echo -e "\e[0;94m\e[40m\n"
cat /etc/pacman.d/mirrorlist

echo -e "\e[0m\e[31m"
# Clean up the unwanted files
rm -fv /tmp/mirrorlist.tmp /etc/pacman.d/mirrorlist.*

echo -e "\e[0m\nDone okay."

exit $?