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

nRepos=0
nNewRepos=0
ReleaseCodename="$(lsb_release -cs)"

PPAWasFound() {
	[[ -z "$(wget -q --no-check-certificate -S --spider "$1" 2>&1 | grep -E '^\s*HTTP.*?404')" ]] && return 1
	return 0
}

grep -lE "^# deb[[:space:]]" /etc/apt/sources.list.d/*.list > /tmp/distupg.lst
nRepos=$(wc -l < /tmp/distupg.lst)

if [[ $nRepos -gt 0 ]]; then
	notify-send "Reenable Repositories" "\nThere are $nRepos repositories that I'll try to reenable.\nPlease wait for this process to complete..." -i face-wink;
	echo -en "\e[1;34m::\e[0;34m There are $nRepos repositories that I'll try to reenable.\n   Please wait for this process to complete..."

	cat /tmp/distupg.lst | xargs -n1 sed -i -e 's/^# deb[[:space:]]/deb /' -e "s/ # disabled on upgrade to $(echo ${ReleaseCodename})//g"
#	apt-get -qq update 2>/tmp/distupg.err

	for ppa in $(cat /tmp/distupg.lst); do
		PPAWasFound "..."
		return_val=$?
		if [[ $return_val -eq 1 ]]; then
			: $(( nNewRepos++ ));
		else
			echo $ppa >> /tmp/distupg.new-lst;
		fi;
	done

	cat /tmp/distupg.new-lst | xargs -n1 sed -i -e 's/^deb[[:space:]]/# deb /' -e "/^# deb[[:space:]]/s/$/ # disabled on upgrade to $(echo ${ReleaseCodename})/"
else
	notify-send "Reenable Repositories" "\nThere are no repositories to reenable" -i face-smirk;
fi

rm -f /tmp/distupg.*

if [[ $nNewRepos -gt 0 ]]; then
	echo -e "\e[0m\n\nDone. $nNewRepos repositories were reenabled."
else
	echo -e "\e[0m\n\nDone. None repository was reenabled."
fi

exit $?
