#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#

# Using przemoc's lockable script boilerplate
# https://gist.github.com/przemoc/571091
LOCKFILE="/var/lock/`basename $0`"
LOCKFD=99

_lock()             { flock -$1 $LOCKFD; }
_no_more_locking()  { _lock u; _lock xn && rm -f $LOCKFILE; }
_prepare_locking()  { eval "exec $LOCKFD>\"$LOCKFILE\""; trap _no_more_locking EXIT; }

_prepare_locking

exlock_now()        { _lock xn; }  # obtain an exclusive lock immediately or fail
exlock()            { _lock x; }   # obtain an exclusive lock
unlock()            { _lock u; }   # drop a lock

# Check to see if all needed tools are present
[[ -x $(which wget 2>/dev/null) ]] || {
	echo -e ":: \e[1mwget\e[0m: command not found!\nUse sudo apt-get install wget to install it" 1>&2;
	exit 2;
}
[[ -x $(which notify-send 2>/dev/null) ]] || {
	echo -e ":: \e[1mnotify-send\e[0m: command not found!\nUse sudo apt-get install libnotify-bin to install it" 1>&2;
	exit 3;
}

if [[ -z "$XAUTHORITY" ]] && [[ -e "$HOME/.Xauthority" ]]; then
	export XAUTHORITY="$HOME/.Xauthority";
fi

if [[ $EUID -ne 0 ]]; then
	exec $(which sudo) "$0";
fi

# Initialize the sound system
[[ -x $(which paplay 2>/dev/null) ]] && [[ -d /usr/share/sounds/freedesktop/stereo/ ]] && {
	WarnSnd="$(which paplay) /usr/share/sounds/freedesktop/stereo/suspend-error.oga";
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
	local url="$(sed -n -e 's/^# deb[[:space:]]//' -e "s/[[:space:]]*# disabled on upgrade to $(echo ${ReleaseCodename})//gp" "$1")";
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
	echo -n "$(cat "$1" | grep -E "^# deb[[:space:]]" | cut -d\/ -f4)";
}


exlock_now || {
	echo -e "\e[1m(!)\e[0m This script is already running\n    Please try again later..." 1>&2;
	$(${WarnSnd});
	exit 1;
}

grep -lE "[[:space:]]*# disabled on upgrade to $(echo ${ReleaseCodename})" /etc/apt/sources.list.d/*.list > /tmp/wantupg.lst
nRepos=$(wc -l < /tmp/wantupg.lst)

if [[ $nRepos -gt 0 ]]; then
	echo -en "\e[1;34m::\e[0;34m There are $nRepos repositories that I'll try to re-enable.\n   Please wait for this process to complete...";
	notify-send "Re-enable Repositories" "\nThere are $nRepos repositories that I'll try to re-enable.\nPlease wait for this process to complete..." -i face-wink;
	$(${StartSnd});

	for PPAfn in $(cat /tmp/wantupg.lst); do
		PPAurl=$(makeURL "$PPAfn");
		$Verbose && echo -en "\e[0m\n-  URL in process: $PPAurl";
		PPAisOK "$PPAurl";
		return_val=$?;
		if [[ $return_val -eq 1 ]]; then
			: $(( nNewRepos++ ));
			$Verbose && echo -en "\e[1;32m\n++ Re-enabled repository's URL: $PPAurl";
			notify-send "Re-enable Repositories" "\n$(getPPAsName "$PPAfn") repository was re-enabled" -i face-smile;
			$(${FoundSnd});
			echo $PPAfn >> /tmp/wantupg.new-lst;
		fi;
	done
	# Re-enable any working repositories
	[[ -f /tmp/wantupg.new-lst ]] && cat /tmp/wantupg.new-lst | xargs -n1 sed -i -e 's/^# deb[[:space:]]/deb /' -e "s/[[:space:]]*# disabled on upgrade to $(echo ${ReleaseCodename})//g";
fi

# Do some cleaning
rm -f /tmp/wantupg.*

if [[ $nRepos -eq 0 ]]; then
	echo -e "\e[0mThere are no repositories to re-enable. Bye!"
	notify-send "Re-enable Repositories" "\nThere are no repositories to re-enable. Bye!" -i face-smirk;
	$(${NoneSnd});
elif [[ $nNewRepos -gt 0 ]]; then
	echo -e "\e[0m\n\nDone. $nNewRepos repositories were re-enabled.";
	notify-send "Re-enable Repositories" "\n$nNewRepos repositories were re-enabled" -i face-cool;
	$(${HappySnd});
else # $nRepos -gt 0 && $nNewRepos -eq 0
	echo -e "\e[0m\n\nDone. None of the repositories was re-enabled.";
	notify-send "Re-enable Repositories" "\nNone of the repositories was re-enabled" -i face-worried;
	$(${UnhappySnd});
fi

unlock

exit $?
