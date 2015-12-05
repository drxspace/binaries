#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#
#set -x

Undot() {
	echo -n "${1//./ }";
}

rm -f /tmp/mkvoptionsfile

declare -A ALTERLANG
ALTERLANG[0,0]="el"
ALTERLANG[0,1]="gre"
ALTERLANG[0,2]="Ελληνικοί υπότιτλοι"

INPUTPARAMS=""

IFS=$'\n\b'

for f in $(ls *.{avi,mp4} 2>/dev/null); do
	LANGSPARAMS=""
	
	OUTPUTPARAMS="--ui-language\nen_US\n--output\n${f%.*}.mkv\n"
	INPUTPARAMS="--language\n0:und\n--language\n1:und\n(\n${f}\n)\n--title\n$(Undot "${f%.*}")\n"

	[[ -f "${f%.*}".en.srt ]] && {
		LANGSPARAMS="--sub-charset\n0:UTF-8\n--language\n0:eng\n--track-name\n0:English subtitles\n(\n""${f%.*}.en.srt""\n)\n";
	}
	[[ -f "${f%.*}".${ALTERLANG[0,0]}.srt ]] && {
		LANGSPARAMS=${LANGSPARAMS}"--sub-charset\n0:UTF-8\n--language\n0:${ALTERLANG[0,1]}\n--track-name\n0:${ALTERLANG[0,2]}\n(\n""${f%.*}.${ALTERLANG[0,0]}.srt""\n)\n";
	}

	TRACKORDER="" #--track-order\n$(???)\n

	echo -e "${OUTPUTPARAMS}${INPUTPARAMS}${LANGSPARAMS}${TRACKORDER}" | \
	sed -e 's/\\/\\\\/g' -e 's/ /\\s/g' -e 's/\"/\\2/g' -e 's/\:/\\c/g' -e 's/\#/\\h/g' > /tmp/mkvoptionsfile

	"$(which mkvmerge)" @/tmp/mkvoptionsfile || {
		notify-send "MP4 to MKV convertor" "Problems with the converting proccess." -i face-worried;
		exit 2;
	}
done

[[ -f "/tmp/mkvoptionsfile" ]] && {
	rm -vf /tmp/mkvoptionsfile *.{avi,mp4,srt}
	notify-send "MP4 to MKV convertor" "All files were converted to mkv." -i face-smile;
} || {
	notify-send "MP4 to MKV convertor" "None avi or mp4 file found in this directory to convert." -i face-plain;
	exit 1;
}

exit 0
