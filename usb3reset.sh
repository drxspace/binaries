#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#

# Taken from this answer http://askubuntu.com/a/290519
# Further info for the script here: http://digital.ni.com/public.nsf/allkb/1D120A90884C25AF862573A700602459

if [[ $EUID -ne 0 ]]; then
	exec $(which sudo) "$0"
fi

# reseting USB3 ports (if there none you'll get errors)
for usb in $(ls /sys/bus/pci/drivers/xhci_hcd/ | grep :); do
	echo ${usb} >/sys/bus/pci/drivers/xhci_hcd/unbind;
	sleep 3;
	echo ${usb} >/sys/bus/pci/drivers/xhci_hcd/bind;
done

(( $? )) || echo "USB3 port(s) reset complete. Turn off and then back on your pc if you don't see any change.'"

exit $?
