#!/bin/bash
#
# You can use this script to download a wallpaper from National Geographic and
# then set the downloaded wallpaper in your prefered desktop environemnt
# For example I use following command as a cron job
#
#    gw | xargs feh --bg-fill

storage=~/.wallpapers/national_geographic
url=http://photography.nationalgeographic.com/photography/photo-of-the-day/
link=`wget -O /dev/stdout $url 2>/dev/null | sed -n '/Download Wallpaper/ !n; /Download Wallpaper/ { s/.*href="\([^"]\+\)">Download Wallpaper.*/\1/; p; q;}'`

if [ ! -d $storage ]
then
    mkdir -p $storage
fi

filepath=`echo "$link" | perl -MURI -le 'chomp($link = <>); print URI->new($link)->path'`
filename=`basename "${filepath}"`

if [ ! $storage/$filename ]
then
    cd $storage
    wget --continue --output-document=$filename $link 2>/dev/null
    cd -
fi

echo "$storage/$filename"
