#!/bin/bash

for path in `find /sys/devices/platform/smapi/BAT* -type d`
do
    name=`basename $path`
    id=`echo $name | sed -e "s/[^0-9]\+//g"`
    state=`cat ${path}/state`
    remaining_percent=`cat ${path}/remaining_percent`

    if [[ $id > 0 ]]
    then
        echo -n " "
    fi

    case $state in
       discharging)
           printf "<fc=#d33682>B%d %2d%%</fc>" $id $remaining_percent
           ;;
       charging)
           printf "<fc=#859900>B%d %2d%%</fc>" $id $remaining_percent
           ;;
       *)
           printf "B%d %2d%%" $id $remaining_percent
           ;;
    esac


done

echo
