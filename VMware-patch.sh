#!/usr/bin/env bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#
#
set -e
#Kernel modules fail to build after Linux 4.x

if [[ $EUID -ne 0 ]]; then
	exec $(which sudo) "$0"
fi

cd /usr/lib/vmware/modules/source

if [[ -f vmmon.old.tar ]]; then
	cp -fv vmmon.old.tar vmmon.tar
else
	cp -fv vmmon.tar vmmon.old.tar
fi
tar xf vmmon.tar

sed -r -i -e 's/get_user_pages(_remote)*/get_user_pages_remote/g' vmmon-only/linux/hostif.c

tar cf vmmon.tar vmmon-only
rm -rf vmmon-only
rm -fv vmmon.tar

#_______________________________________________________________________________
#-------------------------------------------------------------------------------

if [[ -f vmnet.old.tar ]]; then
	cp -fv vmnet.old.tar vmnet.tar
else
	cp -fv vmnet.tar vmnet.old.tar
fi
tar xf vmnet.tar

sed -r -i -e 's/get_user_pages(_remote)*/get_user_pages_remote/g' vmnet-only/userif.c
sed -i -e 's/dev->trans_start = jiffies/netif_trans_update\(dev\)/g' vmnet-only/netif.c

tar cf vmnet.tar vmnet-only
rm -rf vmnet-only
rm -fv vmnet.tar

exit $?
