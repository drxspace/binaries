#!/bin/bash
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

gawk -i inplace 'BEGIN { occurs = 0; }
                 /^Exec=terminator/ {
                   occurs++;
                   if (occurs == 1)
                     gsub(/^Exec=terminator.*/, "terminator --geometry=960x540+480-96");
                   else if (occurs == 2)
                     gsub(/^Exec=terminator.*/, "terminator --geometry=720x405-480-0");
                 }
                 { print; }' /usr/share/applications/terminator.desktop && echo "termites: Injection's okay." || echo "termites: Injection failed..."
## -v INPLACE_SUFFIX=.bak

exit 0
