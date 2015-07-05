#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/   
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___   
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/   
#                                    /_/           drxspace@gmail.com
#

[[ -z $1 ]] && {
	notify-send "Headless VirtualBox machine" "No Headless VirtualBox machine name was specified. Exiting..." -i face-plain &
	exit 1
}

for VB in $(VBoxManage list runningvms | cut -d ' ' -f 2); do
	if [[ "$VB" == "{${1}}" ]]; then
		notify-send "Headless VirtualBox machine" "Headless VirtualBox machine named:\n$(VBoxManage list runningvms | grep $1 | cut -d ' ' -f 1) is already running." -i face-tired &
		exit 2
	fi
done

/usr/bin/VBoxHeadless --vrde config --startvm "$1" &

sleep 4
for VB in $(VBoxManage list runningvms | cut -d ' ' -f 2); do
	if [[ "$VB" == "{$1}" ]]; then
		notify-send "Headless VirtualBox machine" "Headless VirtualBox machine named:\n$(VBoxManage list vms | grep $1 | cut -d ' ' -f 1) is starting.\n\nPlease wait a few moments for it..." -i face-wink &
		$(which paplay) /usr/share/sounds/freedesktop/stereo/device-added.oga
		exit 0
	fi
done	

notify-send "Headless VirtualBox machine" "Headless VirtualBox machine named:\n$(VBoxManage list vms | grep $1 | cut -d ' ' -f 1) won't start.\n\nPlease check its settings." -i face-sad &

exit $?
