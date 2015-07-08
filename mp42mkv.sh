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

OUTPUTPARAMS=""
GLOBALOPT="--disable-track-statistics-tags\n"
LANGSPARAMS=""
declare -a ALTERLANG=("el" "gre")
INPUTPARAMS=""

for f in *.mp4; do
	[[ -f "${f}" ]] && {
		[[ -f "${f%.*}".en.srt ]] && { LANGSPARAMS="--language\n0:eng\n--track-name\n0:English\n--default-track\n0:yes\n--forced-track\n0:no\n-s\n0\n-D\n-A\n-T\n--no-global-tags\n--no-chapters\n"$(printf "%s" "${f%.*}.en.srt\n"); }
		[[ -f "${f%.*}".${ALTERLANG[0]}.srt ]] && { LANGSPARAMS=${LANGSPARAMS}"--language\n0:${ALTERLANG[1]}\n--track-name\n0:Ελληνικά\n--forced-track\n0:no\n-s\n0\n-D\n-A\n-T\n--no-global-tags\n--no-chapters\n"$(printf "%s" "${f%.*}.${ALTERLANG[0]}.srt\n"); }

		OUTPUTPARAMS="--output\n${f%.*}.mkv\n"
		INPUTPARAMS="--forced-track\n0:no\n--forced-track\n1:no\n-a\n1\n-d\n0\n-S\n-T\n--no-global-tags\n--no-chapters\n${f}\n"

		echo -e "${OUTPUTPARAMS}${GLOBALOPT}${LANGSPARAMS}${INPUTPARAMS}" > /tmp/mkvoptionsfile
		sed -i -e 's/\\/\\\\/g' -e 's/ /\\s/g' -e 's/\"/\\2/g' -e 's/\:/\\c/g' -e 's/\#/\\h/g' /tmp/mkvoptionsfile

		"$(which mkvmerge)" @/tmp/mkvoptionsfile || {
			notify-send "MP4 to MKV convertor" "Problems with the converting proccess." -i face-worried;
			exit 2;
		}

	} || {
		notify-send "MP4 to MKV convertor" "None mp4 file found in this directory to convert." -i face-plain;
		exit 1;
	}
done

rm -vf /tmp/mkvoptionsfile *.{srt,mp4}
notify-send "MP4 to MKV convertor" "All mp4 files were converted to mkv." -i face-smile;

exit 0
