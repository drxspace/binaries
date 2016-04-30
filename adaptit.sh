#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#

Help() {
  echo -e "${0##*/}: Showing help ... as always empty";
  exit 20;
}

WrongOption=""
Theme=false
Ubuntu=true
Arch=false

while [[ "$1" == -* ]]; do
  case $1 in
    -h | --help)
      # Show help
      Help
      ;;
    -a | --arch)
      Arch=true ; Ubuntu=false
      ;;
    -u | --ubuntu)
      Ubuntu=true ; Arch=false
      ;;
    -t | --theme)
      Theme=true
      ;;
     *)
      WrongOption=$1
      ;;
  esac
  shift
done

# Check for option error
if [[ "$WrongOption" != "" ]]; then
  echo -e "${0##*/}: invalid option -- $WrongOption\nTry “${0##*/} -h” for more information.";
  exit 10;
fi

echo "Requesting root access if we don't already have it..."
sudo -v

pushd . >/dev/null

cd "$HOME"/gitClones/Adapta
sh autogen.sh
sudo sh -c '
  make uninstall
  rm -rfv /usr/share/themes/Adapta
  make install
'
#make clean

gsettings set org.gnome.desktop.interface gtk-theme 'Adapta'
gsettings set org.gnome.desktop.wm.preferences theme 'Adapta'
gsettings set org.gnome.metacity theme 'Adapta'
$Theme && gsettings set org.gnome.shell.extensions.user-theme name 'Adapta'

popd >/dev/null

exit 0
