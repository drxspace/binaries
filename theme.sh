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

Cinnamon=false
Unity=false
Disabled=""

BuildOnly=false
GTKThemeIt=false
UserThemeIt=false

Adapta=false
Arc=false
Vertex=false

GTKTheme=""
UserTheme=""

[[ -z "$1" ]] && {
  echo -e "${0##*/}: Try “${0##*/} -h” for more information.";
  exit 2;
}

while [[ -n "$1" ]]; do
  case $1 in
    -h | --help)
      # Show help
      Help
      ;;

    -c | --cinnamon)
      Disabled=$Disabled" --disable-cinnamon"
      ;;
    -u | --unity)
      Disabled=$Disabled" --disable-unity"
      ;;

    -s | --user-theme)
      UserThemeIt=true
      ;;
    -g | --gtk-theme)
      GTKThemeIt=true
      ;;

    -b | --build-only)
      BuildOnly=true
      ;;
    -l | --build-only-all)
      BuildOnly=true
      Adapta=true
      Arc=true
      Vertex=true
      ;;

    -a | --adapta)
      Adapta=true
      GTKTheme='Adapta'
      UserTheme='Adapta'
      ;;
    -n | --adapta-nokto)
      Adapta=true
      GTKTheme='Adapta-Nokto'
      UserTheme='Adapta-Nokto'
      ;;
    -r | --arc)
      Arc=true
      GTKTheme='Arc'
      UserTheme='Arc'
      ;;
    -d | --arc-darker)
      Arc=true
      GTKTheme='Arc-Darker'
      UserTheme='Arc'
      ;;
    -v | --vertex)
      Vertex=true
      GTKTheme='Vertex'
      UserTheme='Vertex'
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

! $Adapta && ! $Arc && ! $Vertex && {
  echo -e "${0##*/}: Nothing to be done.";
  exit 3;
}

echo "Requesting root access if we don't already have it..."
sudo -v

pushd . >/dev/null

if $Adapta; then
	cd "$HOME"/gitClones/Adapta
	sh autogen.sh
	sudo sh -c '
		make uninstall
		rm -rfv /usr/share/themes/Adapta
		make install'
	make clean 2>/dev/null
fi

if $Arc; then
	cd "$HOME"/gitClones/Arc-theme
	sh autogen.sh --prefix=/usr --disable-dark --disable-xfwm --disable-xfce-notify $(echo $Disabled) --with-gnome=$(awk -F'[<|>]' '/platform/{p=$3}/minor/{m=$3}END{print p"."m}' /usr/share/gnome/gnome-version.xml)
	sudo sh -c '
		make uninstall
		rm -rfv /usr/share/themes/{Arc,Arc-Darker,Arc-Dark}
		make install'
	make clean 2>/dev/null
fi

if $Vertex; then
	cd "$HOME"/gitClones/Vertex-theme/
	sh autogen.sh --prefix=/usr --disable-dark --disable-light --disable-xfwm $(echo $Disabled) --with-gnome=$(awk -F'[<|>]' '/platform/{p=$3}/minor/{m=$3}END{print p"."m}' /usr/share/gnome/gnome-version.xml)
	sudo sh -c '
		make uninstall
		rm -rfv /usr/share/themes/{Vertex,Vertex-Dark,Vertex-Light}
		make install'
	make clean 2>/dev/null
fi


! $BuildOnly && $GTKThemeIt && [[ -n "$GTKTheme" ]] && {
	gsettings set org.gnome.desktop.interface gtk-theme "$GTKTheme"
	gsettings set org.gnome.desktop.wm.preferences theme "$GTKTheme"
	gsettings set org.gnome.metacity theme "$GTKTheme" 2>/dev/null
}
! $BuildOnly && $UserThemeIt && [[ -n "$UserTheme" ]] && gsettings set org.gnome.shell.extensions.user-theme name "$UserTheme"


popd >/dev/null

exit 0