#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
	exec $(which sudo) "$0" || exit1
fi
cd "$( dirname "$0" )"

wget -q https://github.com/powerline/fonts/archive/master.zip
unzip master.zip
cd fonts-master/

# Set source and target directories
powerline_fonts_dir=$( pwd )
find_command="find \"$powerline_fonts_dir\" \( -name '*.[o,t]tf' -or -name '*.pcf.gz' \) -type f -print0"
font_dir="/usr/share/fonts/truetype/ttf-powerline"
[[ -d $font_dir ]] && rm -rf $font_dir
mkdir -p $font_dir

echo "Copying fonts..."
eval $find_command | xargs -0 -I % cp "%" "$font_dir/"

# Reset font cache on Linux
if command -v fc-cache @>/dev/null ; then
    echo "Resetting font cache, this may take a moment..."
    fc-cache -frv $font_dir
fi

cd ../
rm -rfv master.zip* fonts-master/
echo "All Powerline fonts installed to $font_dir"

exit 0
