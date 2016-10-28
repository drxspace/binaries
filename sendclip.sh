#!/usr/bin/env bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/   
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___   
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/   
#                                    /_/           drxspace@gmail.com
#

[[ $(which yad 2>/dev/null) ]] || {
	notify-send "Copy to clipboard" "I couldn't copy nothing to clipboard.\n‘yad’ command is missing." -i face-sad;
	exit 1;
}
[[ $(which xsel 2>/dev/null) ]] || {
	notify-send "Copy to clipboard" "I couldn't copy nothing to clipboard.\n‘xsel’ command is missing." -i face-sad;
	exit 2;
}

Help() {
  echo -e "sendclip: Showing help ... empty, as always";
  exit 20;
}

WrongOption=""
AsFile=""

KeysFile="$HOME/Documents/keys.txt"
PhonesFile="$HOME/Documents/phones.txt"

while [[ "$1" == -* ]]; do
  case $1 in
    -h | --help)
      # Show help
      Help
      ;;
    -k | --key)
      AsFile="$KeysFile"
      TitleBar="Copy me that key"
      Label="Choose key:"
      ;;
    -p | --phone)
      AsFile="$PhonesFile"
      TitleBar="Copy me that phone number"
      Label="Choose a name:"
      ;;
     *)
      WrongOption=$1
      ;;
  esac
  shift
done

# Check for option error
if [[ "$WrongOption" != "" ]] || [[ -z ${AsFile} ]]; then
  echo -e "sendclip: invalid option -- ${WrongOption}\nTry “sendclip -h” for more information.";
  exit 10;
fi

entries=($(awk 'BEGIN { FS=":"; entry = ""; sep = "\t"; }
                { entry = entry $1 sep; };
                END { print entry; }'  ${AsFile}))
AKey=$(yad --center --width=300 --entry --title="${TitleBar}" \
    --image=document-send \
    --button="gtk-ok:0" --button="gtk-cancel:1" \
    --entry-label="${Label}" --entry-text=${entries[*]})
ret=$?
[[ $ret -eq 1 ]] && exit 0

sed -n "/${AKey}/s/^.*: //p" ${AsFile} | tr -d '\n' | xsel -ib
notify-send "${TitleBar}" "${AKey} copied to clipboard" -i face-wink

exit $?














