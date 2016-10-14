#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#

# Check to see if all needed tools are present
[[ -x $(which lynx 2>/dev/null) ]] || {
	echo -e ":: \e[1mlynx\e[0m: command not found!\nUse \e[0;94msudo apt-get install lynx\e[0m to install it" 1>&2;
	exit 1;
}
[[ -x $(which aria2c 2>/dev/null) ]] || {
	echo -e ":: \e[1maria2c\e[0m: command not found!\nUse \e[0;94msudo apt-get install aria2\e[0m to install it" 1>&2;
	exit 2;
}

declare -a arrSiteVBlnk
declare -a arrSiteVBbld

InstallVirtualBox() {
	local i=$1;
	let i*=2; local vboxurl="${arrSiteVBlnk[$i]}";
	let i+=1; local extpurl="${arrSiteVBlnk[$i]}";

	echo -e "Downloading “\e[1;32m${vboxurl##*/}\e[0m”, please wait...";
	aria2c -x10 -j10 -d /tmp "${vboxurl}";
	echo -e "Downloading “\e[1;32m${extpurl##*/}\e[0m”, please wait...";
	aria2c -x10 -j10 -d /tmp "${extpurl}";
	[[ $? -eq 0 ]] || exit 3;
	# Request root privileges
	echo -e "Following processes requires root user privileges.\nRequesting root access if we don't already have it...";
	echo -e "Installing VirtualBox...";
	sudo -v || exit 4;
	sudo sh /tmp/${vboxurl##*/};
	echo -e "...to uninstall it run the commands\n\e[0;94msudo /opt/VirtualBox/uninstall.sh\e[0m\n\e[0;94msudo rm -rf /opt/VirtualBox/\e[0m";
	[[ $(groups | grep vboxusers) ]] || {
		echo -e "\nAdding user $(whoami) to ‘vboxusers’ group...";
		sudo usermod -aG vboxusers $(whoami);
	}
	echo -e "\nInstalling VirtualBox extensions pack...";
	[[ -x $(which virtualbox 2>/dev/null) ]] && { $(which virtualbox) /tmp/${extpurl##*/}; } &
}

# Current VirtualBox version installed
#CurrVBbld=$(vboxmanage --version | tr [:alpha:] '-')
[[ -x $(which vboxmanage 2>/dev/null) ]] && {
	CurrVBver="$(vboxmanage --version | cut -d 'r' -f 1)";
	CurrVBbld=$(vboxmanage --version | cut -d 'r' -f 2);
} || {
	CurrVBver="0.0.0";
	CurrVBbld=0; # VirtualBox is not installed ...yet
}

Version="Linux_amd64.run"
ExtPack="vbox-extpack"

## http://stackoverflow.com/a/28417633
## http://stackoverflow.com/a/10586169

# Latest VirtualBox version now on site
IFS=$'\n' read -r -d '' -a arrSiteVBlnk <<< "$(lynx -listonly -nonumbers -dump https://www.virtualbox.org/wiki/Testbuilds | sed -n -e /$(echo ${Version})/p -e /$(echo ${ExtPack})/p)"
#echo "${arrSiteVBlnk[@]}" | tr [:space:] '\n'
# How to make it greedy or non-greedy?
#IFS=$'\n' read -r -d '' -a arrSiteVBbld <<< "$(echo "${arrSiteVBlnk[@]}" | tr [:space:] '\n' | sed -n "/$(echo ${Version})/s/.[^-]*-\(.*\)-.*/\1/p")"
IFS=$'\n' read -r -d '' -a arrSiteVBbld <<< "$(echo "${arrSiteVBlnk[@]}" | tr [:space:] '\n' | sed -n "/$(echo ${Version})/s/.*-\(.*\)-.*/\1/p")"
#echo "${arrSiteVBbld[0]}, ${arrSiteVBbld[1]}, ${arrSiteVBbld[2]}"

i=0
if [ ${CurrVBbld} -eq $i ]; then
	echo -e "VirtualBox wasn't found installed.";
	echo -e "On site latest version is this: ${arrSiteVBlnk[$i]}";
	read -p "Do you want to continue installing it? [Y/n]: " ANS
	[[ ${ANS:-Y} == [Yy] ]] && InstallVirtualBox $i
else
	while [ $i -lt ${#arrSiteVBbld[@]} ]; do
		if [ ${arrSiteVBbld[$i]} -gt ${CurrVBbld} ]; then
			echo -e "A newer version from current “\e[1;31mVirtualBox-${CurrVBver}-${CurrVBbld}\e[0m” was found, which is:";
			echo -e "${arrSiteVBlnk[$i*2]}";
			read -p "Do you want to continue installing? [Y/n]: " ANS
			[[ ${ANS:-Y} == [Yy] ]] && InstallVirtualBox $i
			break;
		fi;
		: $(( i+=2 ));
	done
	if [ $i -ge ${#arrSiteVBbld[@]} ]; then
		echo -e "No newer VirtualBox test build version was found.";
		read -p "Do you want to reinstall your current “VirtualBox-${CurrVBver}-${CurrVBbld}”? [y/N]: " ANS
		[[ ${ANS:-N} == [Yy] ]] && InstallVirtualBox ${#arrSiteVBbld[@]}-1
	fi
fi

# replace a forked subshell+cat with $(</etc/passwd)

exit $?
