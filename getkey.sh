#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/   
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___   
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/   
#                                    /_/           drxspace@gmail.com
#

[[ $(which yad 2>/dev/null) ]] || {
	notify-send "Copy me that key" "I couldn't copy that key.\n‘yad’ command is missing." -i face-sad;
	exit 1;
}
[[ $(which xsel 2>/dev/null) ]] || {
	notify-send "Copy me that key" "I couldn't copy that key.\n‘yad’ command is missing." -i face-sad;
	exit 2;
}

KeysFile="$HOME/Documents/keys.txt"
entries=($(cat ${KeysFile} | awk 'BEGIN { FS=":"; entry = ""; sep = " "; } { gsub(/\[:blank:\]*/, "", $1); } { entry = entry $1 sep; }; END { print entry; }'))

AKey=$(yad --center --width 320 --entry --title "Copy me that key" \
    --image=document-send \
    --button="gtk-ok:0" --button="gtk-cancel:1" \
    --text "Choose key:" \
    --entry-text ${entries[*]})
ret=$?

[[ $ret -eq 1 ]] && exit 0

sed -n "/${AKey} *:/s/^.*: //p" ${KeysFile} | tr -d '\n' | xsel -ib
notify-send "Copy me that key" "${AKey} key copied okay." -i face-wink

exit $?
