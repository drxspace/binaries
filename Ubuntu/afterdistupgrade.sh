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
[[ -x $(which wget 2>/dev/null) ]] || {
	echo -e ":: \033[1mwget\033[0m: command not found!\nUse sudo apt-get install wget to install it" 1>&2;
	exit 1;
}
[[ -x $(which notify-send 2>/dev/null) ]] || {
	echo -e ":: \033[1mnotify-send\033[0m: command not found!\nUse sudo apt-get install libnotify-bin to install it" 1>&2;
	exit 2;
}

if [[ -z "$XAUTHORITY" ]] && [[ -e "$HOME/.Xauthority" ]]; then
	export XAUTHORITY="$HOME/.Xauthority";
fi

if [[ $EUID -ne 0 ]]; then
	exec $(which sudo) "$0";
fi

# Initialize the sound system
[[ -x $(which paplay 2>/dev/null) ]] && [[ -d /usr/share/sounds/freedesktop/stereo/ ]] && {
	StartSnd="$(which paplay) /usr/share/sounds/freedesktop/stereo/window-attention.oga";
	FoundSnd="$(which paplay) /usr/share/sounds/freedesktop/stereo/complete.oga";
	NoneSnd="$(which paplay) /usr/share/sounds/freedesktop/stereo/message-new-instant.oga";
	HappySnd="$(which paplay) /usr/share/sounds/freedesktop/stereo/bell.oga";
	UnhappySnd=${StartSnd};
}

Verbose=true
nRepos=0
nNewRepos=0
ReleaseCodename="$(lsb_release -cs)"

makeURL() {
	local url="$(cat "$1" | grep -E "^deb[[:space:]]" | cut -d\  -f2-)";
	if [[ $(echo -n "$url" | wc -w) -gt 2 ]]; then
		url="$(echo -n $url | tr \  \/)";
		echo -n "${url//$ReleaseCodename/dists\/$ReleaseCodename}";
	else
		echo -n "${url% *}";
	fi
}

PPAisOK() {
	[[ $(wget -q --no-check-certificate -S --spider "$1" 2>&1 | grep -E '^\s*HTTP.*?200') ]] && return 1;
	return 0;
}

getPPAsName() {
	echo -n "$(cat "$1" | grep -E "^deb[[:space:]]" | cut -d\/ -f4)";
}

grep -lE "^# deb[[:space:]]" /etc/apt/sources.list.d/*.list > /tmp/distupg.lst
nRepos=$(wc -l < /tmp/distupg.lst)

if [[ $nRepos -gt 0 ]]; then
	echo -en "\e[1;34m::\e[0;34m There are $nRepos repositories that I'll try to re-enable.\n   Please wait for this process to complete...";
	$(${StartSnd});
	notify-send "Re-enable Repositories" "\nThere are $nRepos repositories that I'll try to re-enable.\nPlease wait for this process to complete..." -i face-wink;

	cat /tmp/distupg.lst | xargs -n1 sed -i -e 's/^# deb[[:space:]]/deb /' -e "s/ # disabled on upgrade to $(echo ${ReleaseCodename})//g";

	for PPAfn in $(cat /tmp/distupg.lst); do
		PPAurl=$(makeURL "$PPAfn");
		$Verbose && echo -en "\e[0m\n-  URL in process: $PPAurl";
		PPAisOK "$PPAurl";
		return_val=$?;
		if [[ $return_val -eq 1 ]]; then
			: $(( nNewRepos++ ));
			$Verbose && echo -en "\e[1;32m\n++ Re-enabled repository's URL: $PPAurl";
			$(${FoundSnd});
			notify-send "Re-enable Repositories" "\n$(getPPAsName "$PPAfn") repository was re-enabled" -i face-smile;
		else
			echo $PPAfn >> /tmp/distupg.new-lst;
		fi;
	done

	cat /tmp/distupg.new-lst | xargs -n1 sed -i -e 's/^deb[[:space:]]/# deb /' -e "/^# deb[[:space:]]/s/$/ # disabled on upgrade to $(echo ${ReleaseCodename})/";
fi

rm -f /tmp/distupg.*

if [[ $nRepos -eq 0 ]]; then
	echo -e "\e[0mThere are no repositories to re-enable. Bye!"
	$(${NoneSnd});
	notify-send "Re-enable Repositories" "\nThere are no repositories to re-enable. Bye!" -i face-smirk;
elif [[ $nNewRepos -gt 0 ]]; then
	echo -e "\e[0m\n\nDone. $nNewRepos repositories were re-enabled.";
	$(${HappySnd});
	notify-send "Re-enable Repositories" "\n$nNewRepos repositories were re-enabled" -i face-cool;
else # $nRepos -gt 0 && $nNewRepos -eq 0
	echo -e "\e[0m\n\nDone. None of the repositories was re-enabled.";
	$(${UnhappySnd});
	notify-send "Re-enable Repositories" "\nNone of the repositories was re-enabled" -i face-worried;
fi

exit $?
