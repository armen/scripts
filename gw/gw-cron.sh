#!/bin/bash
#
# Usage:
#
# * */3 * * * /usr/bin/gw-cron &
#
# or
#
# */5 * * * * /usr/bin/gw-cron debug &

# set the DISPLAY, feh needs it
export DISPLAY=':0.0'

logfile='/tmp/gw.log'
redirect='/dev/null'

# check the arguments, if debug is presented do the redirection to log file
test "${1}" = 'debug' && redirect="${logfile}"

bg=$(/usr/bin/gw $@)

[ -f "${bg}" ] && /usr/bin/feh --bg-fill $bg >> $redirect 2>&1

exit 0
