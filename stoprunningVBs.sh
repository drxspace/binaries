#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/   
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___   
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/   
#                                    /_/           drxspace@gmail.com
#

[[ $(VBoxManage list runningvms) ]] && {
	notify-send "Headless VirtualBox machine" "Shutting down VirtualBox machines..." -i computer &
	for VB in $(VBoxManage list runningvms | cut -d ' ' -f 2); do
		VBoxManage controlvm $VB acpipowerbutton
	done
}

[[ $(VBoxManage list runningvms) ]] && {
	i=0
	until [[ -z $(VBoxManage list runningvms) || $i -ge 60 ]]; do sleep 1; let i++; done
}

[[ $(VBoxManage list runningvms) ]] && {
	notify-send "Headless VirtualBox machine" "Poweroff remaining VirtualBox machines..." -i computer &
	for VB in $(VBoxManage list runningvms | cut -d ' ' -f 2); do
		VBoxManage controlvm $VB poweroff
	done
}

pkill notify-osd
notify-send "Headless VirtualBox machine" "All VirtualBox machines that were previously run are shut down." -i face-cool
$(which paplay) /usr/share/sounds/freedesktop/stereo/complete.oga

exit $?
