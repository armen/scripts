#!/bin/bash
#
# You can use this script to download a wallpaper from National Geographic and
# then set the downloaded wallpaper in your prefered desktop environemnt
# For example I use following command as a cron job
#
#    gw | xargs feh --bg-fill

storage=~/.wallpapers/national_geographic
url=http://photography.nationalgeographic.com/photography/photo-of-the-day/
wget -O /tmp/document $url 2>/dev/null
link=`cat /tmp/document | sed -n '/Download Wallpaper/ !n; /Download Wallpaper/ { s/.*href="\([^"]\+\)">Download Wallpaper.*/\1/; p; q;}'`
caption=`cat /tmp/document | sed -n '/id="caption"/ !n; /<h2>/ !n; /<h2>/ { s/.*<h2>\([^<]\+\)<\/h2>/\1/; s/[- ,]/_/g; s/[\n\r]//g; p; q; }' | tr [:upper:] [:lower:]`
rm -rf /tmp/document

if [ "${link}x" != "x" ]
then
    if [ ! -d $storage ]
    then
        mkdir -p $storage
    fi

    filepath=`echo "$link" | perl -MURI -le 'chomp($link = <>); print URI->new($link)->path'`
    filename=`basename "${filepath}"`

    if [ "${caption}x" != "x" ]
    then
        extension=`echo "${filename}"| sed -e "s/.*\(\.[a-zA-Z]\+\)/\1/"`
        filename="${caption}${extension}"
    fi

    if [ ! -f "${storage}/${filename}" ]
    then
        cd $storage
        wget --continue --output-document=$filename $link 2>/dev/null
        cd - > /dev/null
    fi

    echo "${storage}/${filename}"
fi
