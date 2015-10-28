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

GLOBALOPT="--disable-track-statistics-tags\n"

declare -A ALTERLANG
ALTERLANG[0,0]="el"
ALTERLANG[0,1]="gre"
ALTERLANG[0,2]="Ελληνικοί υπότιτλοι"

INPUTPARAMS=""

IFS=$'\n\b'

for f in *.{avi,mp4}; do
	[[ -f "${f}" ]] && {
		OUTPUTPARAMS=""
		LANGSPARAMS=""
		[[ -f "${f%.*}".en.srt ]] && { LANGSPARAMS="--language\n0:eng\n--track-name\n0:English subtitles\n--sub-charset\n0:UTF-8\n--default-track\n0:yes\n--forced-track\n0:no\n-s\n0\n-D\n-A\n-T\n--no-global-tags\n--no-chapters\n(\n""${f%.*}.en.srt""\n)\n"; }
		[[ -f "${f%.*}".${ALTERLANG[0,0]}.srt ]] && { LANGSPARAMS=${LANGSPARAMS}"--language\n0:${ALTERLANG[0,1]}\n--track-name\n0:${ALTERLANG[0,2]}\n--sub-charset\n0:UTF-8\n--forced-track\n0:no\n-s\n0\n-D\n-A\n-T\n--no-global-tags\n--no-chapters\n(\n""${f%.*}.${ALTERLANG[0,0]}.srt""\n)\n"; }

		OUTPUTPARAMS="--output\n${f%.*}.mkv\n"
		INPUTPARAMS="--forced-track\n0:no\n--forced-track\n1:no\n-a\n1\n-d\n0\n-S\n-T\n--no-global-tags\n--no-chapters\n--title\n$(Undot "${f%.*}")\n(\n${f}\n)\n"

		echo -e "${OUTPUTPARAMS}${GLOBALOPT}${LANGSPARAMS}${INPUTPARAMS}" > /tmp/mkvoptionsfile
		sed -i -e 's/\\/\\\\/g' -e 's/ /\\s/g' -e 's/\"/\\2/g' -e 's/\:/\\c/g' -e 's/\#/\\h/g' /tmp/mkvoptionsfile

		"$(which mkvmerge)" @/tmp/mkvoptionsfile || {
			notify-send "MP4 to MKV convertor" "Problems with the converting proccess." -i face-worried;
			exit 2;
		}
	} || {
		notify-send "MP4 to MKV convertor" "None avi or mp4 file found in this directory to convert." -i face-plain;
		exit 1;
	}
done

rm -vf /tmp/mkvoptionsfile *.{avi,mp4,srt}
notify-send "MP4 to MKV convertor" "All files were converted to mkv." -i face-smile;

exit 0
