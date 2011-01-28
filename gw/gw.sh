#!/bin/bash
#
# You can use this script to download a wallpaper from National Geographic and
# then set the downloaded wallpaper in your prefered desktop environemnt
# For example I use following command
#
#    gw | xargs feh --bg-fill
#

# XXX: I do sucksify the wget, probably you don't, remove the tsocks from the
# begining if you like
WGET="tsocks wget"


storage=~/.wallpapers/national_geographic
feeds=http://feeds.nationalgeographic.com/ng/photography/photo-of-the-day/

$WGET -O /tmp/feeds $feeds >/dev/null 2>&1
url=`cat /tmp/feeds | grep --max-count=1 "<pheedo:origLink" \
     | sed -e "s/.*\(http[^<]\+\)<.*/\1/"`
title=`cat /tmp/feeds | grep --max-count=1 -A 1 "<item>" \
       | sed -n "/<title>/ !n; s/.*<title>\([^<]\+\)<.*/\1/; p;"`
description=`head /tmp/feeds -n 45 \
             | sed -n '1h;1!H; ${g;s/.*<media:description>\([^<]\+\)<\/media:description>.*/\1/g;p;}' \
             | sed -e 's/(This photo and caption were submitted[^)]\+)//'`
caption=`echo $title | sed -e 's/[- ,]/_/g; s/[\n\r]//g;' \
         | tr [:upper:] [:lower:]`

$WGET -O /tmp/document $url >/dev/null 2>&1
link=`cat /tmp/document | sed -n '/Download Wallpaper/ !n; /Download Wallpaper/ { s/.*href="\([^"]\+\)">Download Wallpaper.*/\1/; p; q;}'`

if [ "${link}x" == "x" ]
then
    link=`cat /tmp/document | grep --max-count=1 "media-live.*cache" \
          | sed -e 's/.*\(http[^"]\+\).*/\1/'`
fi

rm -rf /tmp/document
rm -rf /tmp/feeds

if [ "${link}x" != "x" ]
then
    if [ ! -d $storage ]
    then
        mkdir -p $storage
    fi

    filepath=`echo "$link" | perl -MURI -le \
              'chomp($link = <>); print URI->new($link)->path'`
    filename=`basename "${filepath}"`

    if [ "${caption}x" != "x" ]
    then
        extension=`echo "${filename}"| sed -e "s/.*\(\.[a-zA-Z]\+\)/\1/"`
        filename="${caption}${extension}"
    fi

    if [ ! -f "${storage}/${filename}" ]
    then
        cd $storage
        $WGET --continue --output-document=$filename $link >/dev/null 2>&1
        echo $description > "${filename}.txt"
        cd - > /dev/null
    fi

    echo "${storage}/${filename}"
fi
