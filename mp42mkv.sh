#!/usr/bin/env bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#
#set -x
#set -e

mp42mkvScriptName="$(basename $0)"

mesg() {
	local mesgStartOptions=""
	local mesgEndOptions="\e[0m"

	case $2 in
	0|"")	# Generic message
		mesgStartOptions="\e[1;33m${mp42mkvScriptName}\e[0m: "
		;;
	1)	# Error message
		mesgStartOptions="\e[1;31m${mp42mkvScriptName}\e[0m: "
		;;
	2)	# Warning
		mesgStartOptions="\e[1;38;5;209m${mp42mkvScriptName}\e[0m: "
		;;
	3)	# Information
		mesgStartOptions="\e[1;94m${mp42mkvScriptName}\e[0m: "
		;;
	4)	# Success
		mesgStartOptions="\e[1;92m${mp42mkvScriptName}\e[0m: "
		;;
	 *)
		
		;;
	esac


	echo -e "${mesgStartOptions}${1}${mesgEndOptions}";
}

Help() {
	mesg "Showing help ... as always empty";
	exit 20;
}

Undot() {
	echo -n "${1//./ }";
}

BoxTried=0
BoxError=0
BoxWarn=0
BoxOkay=0
FileArg=""
WrongOption=""
yes=false
no=false

INPUTPARAMS=""
IFS=$'\n\b'

nLANGUAGES=2
declare -A LANGUAGES
# Enter your prefered language first to be set as the default
LANGUAGES[0,0]="el"
LANGUAGES[0,1]="gre"
LANGUAGES[0,2]="Ελληνικοί υπότιτλοι"
LANGUAGES[0,3]="ISO-8859-7"
#
LANGUAGES[1,0]="en"
LANGUAGES[1,1]="eng"
LANGUAGES[1,2]="English subtitles"
LANGUAGES[1,3]="ISO-8859-1"

subExtension="srt"

while [[ "$1" == -* ]]; do
	case $1 in
	-h)
		# Show help
		Help
		;;
	-s)
		subExtension="srt"
		;;
	-v)
		subExtension="vtt"
		;;
	-y)
		yes=true
		;;
	-n)
		no=true
		;;
	 *)
		WrongOption=$1
		;;
	esac
	shift
done

# Check for option error
if [[ "$WrongOption" != "" ]]; then
	mesg "Invalid option -- $WrongOption\nTry “mp42mkv -h” for more information" 2;
	exit 10;
fi
if $yes && $no; then
	mesg "Invalid option coexistence\nTry “mp42mkv -h” for more information" 2;
	exit 11;
fi
if [[ "$@" == "" ]]; then
	FileArg="$(ls *.{avi,mp4} 2>/dev/null)";
elif [[ -f "$@" ]]; then
	FileArg="$@";
else
	mesg "Invalid filename “$@”" 2;
	exit 12;
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# main of script
#
for f in ${FileArg}; do
	OUTPUTPARAMS="--ui-language\nen_US\n--output\n${f%.*}.mkv\n"
	INPUTPARAMS="--language\n0:und\n--language\n1:und\n(\n${f}\n)\n"

	LANGSPARAMS=""
	# We won't convert if no proper subtitle file(s) found for the current movie
	WontBoxed=true;
	for ((k=0; k < nLANGUAGES ; k++)); do
		[[ -f "${f%.*}".${LANGUAGES[${k},0]}.${subExtension} ]] && {
			# Check if we must convert subtitles file to utf-8 first
			[[ -z $(file -bi "${f%.*}".${LANGUAGES[${k},0]}.${subExtension} | grep "utf-8" 2>/dev/null) ]] && {
				mesg "Converting subtitle file ${f%.*}.${LANGUAGES[${k},0]}.${subExtension} to “utf-8”" 3;
				mv "${f%.*}".${LANGUAGES[${k},0]}.${subExtension} "${f%.*}".${LANGUAGES[${k},0]}.${subExtension}.tmp;
				iconv -f ${LANGUAGES[${k},3]} -t UTF8 -o "${f%.*}".${LANGUAGES[${k},0]}.${subExtension} "${f%.*}".${LANGUAGES[${k},0]}.${subExtension}.tmp || {
					mv "${f%.*}".${LANGUAGES[${k},0]}.${subExtension}.tmp "${f%.*}".${LANGUAGES[${k},0]}.${subExtension};
					mesg "Problems with the conversion process of subtitle file ${f%.*}.${LANGUAGES[${k},0]}.${subExtension} to “utf-8”" 1;
					continue;
				}
			}
			# Check if we have to convert ’ to Ά in the subtitle file
			[[ "${LANGUAGES[${k},0]}" = "el" ]] && {
				nAlphas=$(grep -o -c -E "’[[:alpha:]]{2,}" "${f%.*}.${LANGUAGES[${k},0]}.${subExtension}")
				[[ ${nAlphas} -gt 0 ]] && {
					sed -i "s/’/Ά/g" "${f%.*}.${LANGUAGES[${k},0]}.${subExtension}"
					mesg "Chech process of the subtitle file found and alter ${nAlphas} “’” character(s)" 4;
				}
			}
			WontBoxed=false;
			LANGSPARAMS=${LANGSPARAMS}"--sub-charset\n0:UTF-8\n--language\n0:${LANGUAGES[${k},1]}\n--track-name\n0:${LANGUAGES[${k},2]}\n(\n""${f%.*}.${LANGUAGES[${k},0]}.${subExtension}""\n)\n";
			# Cleaning
			rm -f "${f%.*}".${LANGUAGES[${k},0]}.${subExtension}.tmp;
		}
	done

	$WontBoxed && {
		mesg "Subtitle file(s) not found or not defined for the movie “${f}”" 1;
		continue;
	}

	MOVIETITLE="--title\n$(Undot "${f%.*}")\n"
	TRACKORDER="" #--track-order\n$(???)\n

	echo -e "${OUTPUTPARAMS}${INPUTPARAMS}${LANGSPARAMS}${MOVIETITLE}${TRACKORDER}" | \
	sed -e 's/\\/\\\\/g' -e 's/ /\\s/g' -e 's/\"/\\2/g' -e 's/\:/\\c/g' -e 's/\#/\\h/g' > /tmp/mkvoptionsfile

	"$(which mkvmerge)" @/tmp/mkvoptionsfile 2>/dev/null; RetCode=$?
	: $(( BoxTried++ ));

	[[ $RetCode -gt 1 ]] && {
		: $(( BoxError++ ));
		mesg "Problems with the packaging process of the movie “${f}”" 1;
	} || {
		[[ $RetCode -eq 1 ]] && {
			: $(( BoxWarn++ ));
			mesg "Packaging process of the movie “${f}” done with warning(s)" 2;
		} || {
			: $(( BoxOkay++ ));
			mesg "Packaging process of the movie “${f}” done okay" 4;
		}
		{ $yes || $no; } || read -p "Do you want to delete the packaged files? [Y/n]: " ANS;
		[[ ${ANS:-Y} == [Yy] ]] && { $no || mesg "Cleaning packade files" 3; rm -fv "${f%.*}"*.{avi,mp4,${subExtension}}; }
	}
done

if [[ $BoxTried -gt 0 ]]; then
	mesg "Cleaning garbages" 3
	rm -fv /tmp/mkvoptionsfile 2>/dev/null;
	mesg "All packaging processes have finished
Tried $BoxTried movie(s)
$(( BoxWarn + BoxOkay )) movie(s) packaged to MKV
$BoxWarn movie(s) gave warning(s) and $BoxOkay done just fine";
	[[ $BoxError -gt 0 ]] && mesg "$BoxError movie(s) aborted" 1;
else
	mesg "None relevant file found to be packaged";
	exit 1;
fi

exit 0
