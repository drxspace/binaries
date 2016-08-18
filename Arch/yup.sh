#!/bin/bash
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/
#                                    /_/           drxspace@gmail.com
#

#	-y, --refresh
#	Passing two --refresh or -y flags will
#	force a refresh of all package databases, even if they appear to be up-to-date.

#	-u, --sysupgrade
#	Pass this option twice to enable package downgrades; in this case, pacman will select sync packages
#	whose versions do not match with the local versions. This can be useful when the user switches from a
#	testing repository to a stable one.

#	-a, --aur
#	Also search in AUR database.

yaourt -Syyuua
