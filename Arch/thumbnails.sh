#!/usr/bin/env bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/   
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___   
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/   
#                                    /_/           drxspace@gmail.com
#

# Thumbnails
# ----------
# You will need a tool for creating thumbnails, such as ffmpegthumbnailer.
# Make sure the necessary codecs are installed.
set -e

VIDEO_EXTENSIONS="flv webm mkv mp4 mpeg
avi ogg quicktime x-avi x-flv x-mp4
x-mpeg x-webm x-mkv application@x-extension-webm
x-matroska x-ms-wmv x-msvideo x-msavi
x-theora@ogg x-theora@ogv x-ms-asf x-m4v"

sudo pacman --needed -S gconf gconf-editor gnome-settings-daemon vlc ffmpegthumbnailer gstreamer0.10-{{bad,good,ugly,base}{,-plugins},ffmpeg}

rm -rf ~/.thumbnails/fail ~/.cache/thumbnails/*
echo -n "Registering filetype"

for mediatype in  ${VIDEO_EXTENSIONS}; do
	echo -n " ${mediatype}"
	gconftool-2 -s "/desktop/gnome/thumbnailers/video@${mediatype}/enable" -t boolean "true"
	gconftool-2 -s "/desktop/gnome/thumbnailers/video@${mediatype}/command" -t string "$(which ffmpegthumbnailer) -s %s -i %i -o %o -c png -f -t 10"
done

echo -e "\nokay"

exit 0
