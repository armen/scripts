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
WGET="wget --tries=1 --timeout=30 --continue"

logfile='/tmp/gw.log'
redirect='/dev/null'
storage="${HOME}/.wallpapers/national_geographic"

url="${1}"

# check the arguments, if debug is presented do the redirection to log file
test "${1}" = 'debug' && redirect="${logfile}" && url="${2}"

if [ "${url}x" = "x" ]
then
    url="http://photography.nationalgeographic.com/photography/photo-of-the-day/"
fi

$WGET -O /tmp/document $url >> $redirect 2>&1

link=`cat /tmp/document | sed -n '/Download Wallpaper/ !n; /Download Wallpaper/ { s/.*href="\([^"]\+\)">Download Wallpaper.*/\1/; p; q;}'`

if [ "${link}x" == "x" ]
then
    link=`grep /tmp/document -e '<meta property="og:image"' | sed -e 's/.*content="\([^"]\+\)".*/\1/'`
fi

description=`grep /tmp/document -A 100 -e '<div id="caption">' | sed -e "s/<a.*<\/a>//" | sed -n '1h;1!H; ${g;s/.*<p>\([^<]\+\)<\/p>.*/\1/g;p;}'`
title=`grep /tmp/document -A 100 -e '<div id="caption">' | sed -n '1h;1!H; ${g;s/.*<h2>\([^<]\+\)<\/h2>.*/\1/g;p;}'`
caption=`echo $title | sed -e 's/[- ,]/_/g; s/[\n\r]//g;' \
         | tr [:upper:] [:lower:]`
ogurl=`grep /tmp/document -e '<meta property="og:url"' | sed -e 's/.*content="\([^"]\+\)".*/\1/'`
credit=`grep /tmp/document -e '"credit"' | sed -e 's/<[^>]\+>//g' | sed -e 's/^\s*//'`
crediturl=`grep /tmp/document -e '"credit"' | sed -e 's/.*href="\([^"]\+\)".*/\1/' | grep -e "http"`

rm -rf /tmp/document

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

    cd $storage
    prev_filename=$(ls ?????_$filename 2>/dev/null)

    if [ "${prev_filename}x" != "x" ]
    then
        filesize=$(stat -c%s $prev_filename)
        test $filesize = 0 && rm -f $prev_filename
        filename=$prev_filename
    else
        id=$( printf %05d $(( $(find $storage -maxdepth 1 -type f -name "[0-9]*.jpg" \
                                | sort -d | tail -n 1 \
                                | sed -e "s/[^1-9]\+\([1-9][0-9]*\)_.*/\1+1/" \
                                      -e "s/[^1-9]\+0\+_.*/1/") )) )
        filename="${id}_${filename}"
    fi

    if [ ! -f "${storage}/${filename}" ]
    then
        $WGET --output-document=$filename $link >> $redirect 2>&1

        echo $title >> "${filename}.txt"
        echo $description >> "${filename}.txt"
        echo >> "${filename}.txt"
        echo $credit >> "${filename}.txt"
        echo $crediturl >> "${filename}.txt"
        echo $ogurl >> "${filename}.txt"
    fi

    cd - > /dev/null
    echo "${storage}/${filename}"
fi
