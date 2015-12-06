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

SendNotification() {
	if [ -t 0 ]; then
		echo -e "$1";
	else
		notify-send "MP4 to MKV convertor" "$1" -i $2;
	fi
}

ConvTotal=0
ConvError=0
ConvWarn=0
ConvOkay=0

INPUTPARAMS=""
IFS=$'\n\b'

declare -A ALTERLANG
ALTERLANG[0,0]="el"
ALTERLANG[0,1]="gre"
ALTERLANG[0,2]="Ελληνικοί υπότιτλοι"

for f in $(ls *.{avi,mp4} 2>/dev/null); do
	# We won't convert if no subtitle files with proper filename found for the current movie
	[[ -z $(ls "${f%.*}".{en,${ALTERLANG[0,0]}}.srt 2>/dev/null) ]] && {
		SendNotification "No subtitle files with proper filename found for the movie “${f%.*}”" face-embarrassed;
		continue;
	}

	LANGSPARAMS=""

	OUTPUTPARAMS="--ui-language\nen_US\n--output\n${f%.*}.mkv\n"
	INPUTPARAMS="--language\n0:und\n--language\n1:und\n(\n${f}\n)\n"

	[[ -f "${f%.*}".en.srt ]] && {
		LANGSPARAMS="--sub-charset\n0:UTF-8\n--language\n0:eng\n--track-name\n0:English subtitles\n(\n""${f%.*}.en.srt""\n)\n";
	}

	[[ -f "${f%.*}".${ALTERLANG[0,0]}.srt ]] && {
		[[ -z $(file -bi "${f%.*}".${ALTERLANG[0,0]}.srt | grep "utf-8" 2>/dev/null) ]] && {
			# We must convert subtitles file to utf-8 first
			echo -e "Converting subtitle file ${f%.*}.${ALTERLANG[0,0]}.srt to “utf-8”";
			mv "${f%.*}".${ALTERLANG[0,0]}.srt "${f%.*}".${ALTERLANG[0,0]}.srt.ansi;
			iconv -f WINDOWS-1253 -t UTF8 -o "${f%.*}".${ALTERLANG[0,0]}.srt "${f%.*}".${ALTERLANG[0,0]}.srt.ansi;
			rm -f "${f%.*}".${ALTERLANG[0,0]}.srt.ansi;
		}
		LANGSPARAMS=${LANGSPARAMS}"--sub-charset\n0:UTF-8\n--language\n0:${ALTERLANG[0,1]}\n--track-name\n0:${ALTERLANG[0,2]}\n(\n""${f%.*}.${ALTERLANG[0,0]}.srt""\n)\n";
	}

	MOVIETITLE="--title\n$(Undot "${f%.*}")\n"
	TRACKORDER="" #--track-order\n$(???)\n

	echo -e "${OUTPUTPARAMS}${INPUTPARAMS}${LANGSPARAMS}${MOVIETITLE}${TRACKORDER}" | \
	sed -e 's/\\/\\\\/g' -e 's/ /\\s/g' -e 's/\"/\\2/g' -e 's/\:/\\c/g' -e 's/\#/\\h/g' > /tmp/mkvoptionsfile

	: $(( ConvTotal++ ));
	"$(which mkvmerge)" @/tmp/mkvoptionsfile ; RetCode=$?

	[[ $RetCode -gt 1 ]] && {
		: $(( ConvError++ ));
		SendNotification "Problems with the conversion process of movie “${f%.*}”" face-worried;
	} || {
		[[ $RetCode -eq 1 ]] && {
			: $(( ConvWarn++ ));
			SendNotification "Conversion process of movie “${f%.*}” done with warnings" face-plain;
		} || {
			: $(( ConvOkay++ ));
			SendNotification "Conversion process of movie “${f%.*}” done" face-smile;
		}
		if [ -t 0 ]; then
			read -p "Do you want to delete the converted files? [Y/n]: " ANS;
			[[ ${ANS:-Y} == [Yy] ]] && rm -vf "${f%.*}"*.{avi,mp4,srt};
		else
			rm -f "${f%.*}"*.{avi,mp4,srt};
		fi
	}
done

[[ $ConvTotal -gt 0 ]] && {
	rm -vf /tmp/mkvoptionsfile
	SendNotification "\nAll conversion processes have finished.
$(( ConvWarn + ConvOkay )) movie(s) converted to MKV.
${ConvWarn} of them with warnings.
${ConvOkay} of them were done OK." face-angel;
} || {
	SendNotification "None AVI or MP4 file found to convert." face-uncertain;
	exit 1;
}

exit 0
