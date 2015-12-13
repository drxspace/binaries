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

Help() {
  echo -e "mp42mkv: Showing help...";
  exit 20;
}

Undot() {
  echo -n "${1//./ }";
}

ConvTried=0
ConvError=0
ConvWarn=0
ConvOkay=0
WrongOption=""
yes=false
no=false

INPUTPARAMS=""
IFS=$'\n\b'

noLANGUAGES=2
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

while [[ "$1" == -* ]]; do
  case $1 in
    -h)
      # Show help
      Help
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
  echo -e "mp42mkv: invalid option -- $WrongOption\nTry “mp42mkv -h” for more information.";
  exit 10;
fi
if $yes && $no; then
  echo -e "mp42mkv: invalid option coexistence\nTry “mp42mkv -h” for more information.";
  exit 11;
fi
if [[ "$@" == "" ]]; then
  FileArg="$(ls *.{avi,mp4} 2>/dev/null)";
elif [[ -f "$@" ]]; then
  FileArg="$@";
else
  echo -e "mp42mkv: invalid filename “$@”";
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
  WontConvert=true;
  for ((k=0; k < noLANGUAGES ; k++)); do
    [[ -f "${f%.*}".${LANGUAGES[${k},0]}.srt ]] && {
      WontConvert=false;
      # Check if we must convert subtitles file to utf-8 first
      [[ -z $(file -bi "${f%.*}".${LANGUAGES[${k},0]}.srt | grep "utf-8" 2>/dev/null) ]] && {
        echo -e "Converting subtitle file ${f%.*}.${LANGUAGES[${k},0]}.srt to “utf-8”";
        mv "${f%.*}".${LANGUAGES[${k},0]}.srt "${f%.*}".${LANGUAGES[${k},0]}.srt.tmp;
        iconv -f ${LANGUAGES[${k},3]} -t UTF8 -o "${f%.*}".${LANGUAGES[${k},0]}.srt "${f%.*}".${LANGUAGES[${k},0]}.srt.tmp && rm -f "${f%.*}".${LANGUAGES[${k},0]}.srt.tmp || {
          mv "${f%.*}".${LANGUAGES[${k},0]}.srt.tmp "${f%.*}".${LANGUAGES[${k},0]}.srt;
          echo -e "\e[0;30m\e[45mProblems with the conversion process of subtitle file ${f%.*}.${LANGUAGES[${k},0]}.srt to “utf-8”\e[0m";
          continue;
        }
      }
      LANGSPARAMS=${LANGSPARAMS}"--sub-charset\n0:UTF-8\n--language\n0:${LANGUAGES[${k},1]}\n--track-name\n0:${LANGUAGES[${k},2]}\n(\n""${f%.*}.${LANGUAGES[${k},0]}.srt""\n)\n";
    }
  done

  # We won't convert if no proper subtitle file(s) found for the current movie
  $WontConvert && {
    echo -e "\e[0;30m\e[45mNone proper subtitle file(s) found for the movie “${f}”\e[0m";
    continue;
  }

  MOVIETITLE="--title\n$(Undot "${f%.*}")\n"
  TRACKORDER="" #--track-order\n$(???)\n

  echo -e "${OUTPUTPARAMS}${INPUTPARAMS}${LANGSPARAMS}${MOVIETITLE}${TRACKORDER}" | \
  sed -e 's/\\/\\\\/g' -e 's/ /\\s/g' -e 's/\"/\\2/g' -e 's/\:/\\c/g' -e 's/\#/\\h/g' > /tmp/mkvoptionsfile

  "$(which mkvmerge)" @/tmp/mkvoptionsfile ; RetCode=$?
  : $(( ConvTried++ ));

  [[ $RetCode -gt 1 ]] && {
    : $(( ConvError++ ));
    echo -e "\e[0;30m\e[45mProblems with the conversion process of the movie “${f}”\e[0m";
  } || {
    [[ $RetCode -eq 1 ]] && {
      : $(( ConvWarn++ ));
      echo -e "\e[0;94mConversion process of the movie “${f}” done with warnings\e[0m";
    } || {
      : $(( ConvOkay++ ));
      echo -e "\e[0;92mConversion process of the movie “${f}” done okay\e[0m";
    }
    { $yes || $no; } || read -p "Do you want to delete the converted files? [Y/n]: " ANS;
    [[ ${ANS:-Y} == [Yy] ]] && { $no || rm -vf "${f%.*}"*.{avi,mp4,srt}; }
  }
done

if [[ $ConvTried -gt 0 ]]; then
  rm -f /tmp/mkvoptionsfile
  echo -e "\nAll conversion processes have finished.
Tried $ConvTried movie(s).
$(( ConvWarn + ConvOkay )) movie(s) converted to MKV.
$ConvWarn gave warnings and $ConvOkay done just fine.";
  [[ $ConvError -gt 0 ]] && echo -e "$ConvError movie(s) aborted.";
else
  echo -e "\nNo AVI nor MP4 file found to convert.\e[0m";
  exit 1;
fi

exit 0
