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

gawk -i inplace 'BEGIN { occurs = 0 } 
                 /^Exec=terminator/ { 
                   occurs++; 
                   if (occurs == 1) 
                     gsub(/terminator.*/, "terminator --geometry=960x540+0-96"); 
                   else if (occurs == 2) 
                     gsub(/terminator.*/, "terminator --geometry=720x405-0-0"); 
                 }
                 { print; }' /usr/share/applications/terminator.desktop || echo "termites: Injection failed..."
## -v INPLACE_SUFFIX=.bak 

#sed -i 's/^Exec=terminator/Exec=terminator --geometry=960x540+0-64/' /usr/share/applications/terminator.desktop

exit 0
