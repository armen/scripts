#!/bin/bash

. sh-setup

log "started do-socks..." $LOG_DEBUG

CONFIG="/etc/default/do-socks.cfg"
PROXY_PORT=7777
PROXY_DOMAIN=localhost
OPTIONS="-v"

# Read config file if it is present
[ -r $CONFIG ] && . $CONFIG

function terminate()
{
    kill $ssh_pid 2>/dev/null
    exit 0
}

# Do the cleanup when one of SIGHUP, SIGINT, SIGTERM signals is received
trap terminate SIGHUP SIGINT SIGTERM

while (true);
do
    if [ "x$PROXY_USER" != "x" ]
    then
        OPTIONS="$OPTIONS -l $PROXY_USER"
    fi

    ssh $OPTIONS -ND $PROXY_PORT $PROXY_DOMAIN &
    ssh_pid=$!      # catch ssh's pid so we can cleanup it later when a SIGNAL received

    wait $ssh_pid   # wait for it

    ret=$?

    if [ $ret == 255 ]
    then
        # ssh returned with error, wait for two minutes
        sleep 120
    fi

done
