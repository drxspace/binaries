#!/bin/bash -e
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#

if [[ $EUID -ne 0 ]]; then
	exec $(which sudo) "$0"
fi

echo -e "\n:: \033[1mAMD Catalyst\033[0m\n"
catalyst_build_module $(uname -r)

echo -e "\n:: \033[1mVMware\033[0m\n"
vmware-modconfig --console --install-all

echo -e "\n:: \033[1mVirtualBox\033[0m\n"
dkms install vboxhost/$(pacman -Q virtualbox|awk {'print $2'}|sed 's/\-.\+//') -k $(uname -rm|sed 's/\ /\//')
dkms install vboxguest/$(pacman -Q virtualbox|awk {'print $2'}|sed 's/\-.\+//') -k $(uname -rm|sed 's/\ /\//')

echo -e "\n:: \033[1mUpdating Grub\033[0m\n"
update-grub -a

exit $?
