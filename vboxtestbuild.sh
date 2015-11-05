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
[[ -x $(which wget 2>/dev/null) ]] || {
	echo -e ":: \e[1mwget\e[0m: command not found!\nUse \e[0;94msudo apt-get install wget\e[0m to install it" 1>&2;
	exit 2;
}

declare -a arrSiteVBlnk
declare -a arrSiteVBver

InstallVirtualBox() {
	local i=$1;
	local vboxurl="${arrSiteVBlnk[$i]}"; let i+=1;
	local extpurl="${arrSiteVBlnk[$i]}";
	
	echo "Downloading “${vboxurl##*/}”, please wait...";
	wget -q --show-progress --progress=bar:force -N -4 -t 1 -O /tmp/${vboxurl##*/} "${vboxurl}";
	echo "Downloading “${extpurl##*/}”, please wait...";
	wget -q --show-progress --progress=bar:force -N -4 -t 1 -O /tmp/${extpurl##*/} "${extpurl}";
	# Request root privileges
	echo -e "Following processes requires root user privileges.\nRequesting root access if we don't already have it...";
	echo -e "Installing VirtualBox...";
	sudo -v;
	sudo sh /tmp/${vboxurl##*/};
	echo -e "...to uninstall it run the commands\n\e[0;94msudo /opt/VirtualBox/uninstall.sh\e[0m\n\e[0;94msudo rm -rf /opt/VirtualBox/\e[0m";
	[[ $(groups | grep vboxusers) ]] || {
		echo -e "\nAdding user $(whoami) to ‘vboxusers’ group...";
		sudo usermod -aG vboxusers $(whoami);
	}
	echo -e "\nInstalling VirtualBox extensions pack...";
	[[ -x $(which virtualbox 2>/dev/null) ]] && $(which virtualbox) /tmp/${extpurl##*/} & ;
}

# Current VirtualBox version installed
#CurrVBver=$(vboxmanage --version | tr [:alpha:] '-')
[[ -x $(which vboxmanage 2>/dev/null) ]] && {
	CurrVBver=$(vboxmanage --version | cut -d 'r' -f 2);
} || {
	CurrVBver=0; # VirtualBox is not installed ...yet
}

Build="Linux_amd64.run"
ExtPack="vbox-extpack"

## http://stackoverflow.com/a/28417633
## http://stackoverflow.com/a/10586169

# Latest VirtualBox version now on site
IFS=$'\n' read -r -d '' -a arrSiteVBlnk <<< "$(lynx -listonly -nonumbers -dump https://www.virtualbox.org/wiki/Testbuilds | sed -n -e /$(echo ${Build})/p -e /$(echo ${ExtPack})/p)"
#echo "${arrSiteVBlnk[@]}" | tr [:space:] '\n'

# Should I make it greedy or non-greedy?
#IFS=$'\n' read -r -d '' -a arrSiteVBver <<< "$(echo "${arrSiteVBlnk[@]}" | tr [:space:] '\n' | sed -n "/$(echo ${Build})/s/.*-\(.*\)-.*/\1/p")"
#IFS=$'\n' read -r -d '' -a arrSiteVBver <<< "$(echo "${arrSiteVBlnk[@]}" | tr [:space:] '\n' | sed -n "/$(echo ${Build})/s/.[^-]*-\(.*\)-.*/\1/p")"
IFS=$'\n' read -r -d '' -a arrSiteVBver <<< "$(echo "${arrSiteVBlnk[@]}" | tr [:space:] '\n' | sed -n "/$(echo ${Build})/s/.*-\(.*\)-.*/\1/p")"
#echo "${arrSiteVBver[0]}, ${arrSiteVBver[1]}"

i=0
while [ $i -lt ${#arrSiteVBver[@]} ]; do
	if [ ${arrSiteVBver[$i]} -gt ${CurrVBver} ]; then
		echo "A newer VirtualBox test build version was found...";
		echo "${arrSiteVBlnk[$i]}";
		read -p "Do you want to continue installing? [Y/n]: " ANS
		[[ ${ANS:-Y} == [Yy] ]] && InstallVirtualBox $i
		break;
	fi;
	: $(( i+=2 ));
done

if [ $i -ge ${#arrSiteVBver[@]} ]; then
	echo "No newer VirtualBox test build version was found.";
fi

#for (( i=0; i<${#arrSiteVBver[@]}; i++ )); do
#done

# replace a forked subshell+cat with $(</etc/passwd)

exit $?
