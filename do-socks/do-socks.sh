#!/bin/bash

. do-socks-sh-setup

CONFIG="/etc/default/do-socks.cfg"
BIND_ADDRESS=localhost
BIND_PORT=7777
RECONNECT_AFTER=10
DEST_ADDRESS=localhost
SSH_OPTIONS="-v"
LOG_FILE="/var/log/do-socks.log"
LOG_LEVEL=$LOG_ALL

log "started do-socks..." $LOG_DEBUG

# Read config file if it is present
[ -r $CONFIG ] && . $CONFIG

function terminate()
{
    kill $ssh_pid 2>/dev/null
    exit 0
}

# Do the cleanup when one of SIGHUP, SIGINT, SIGTERM signals is received
trap terminate SIGHUP SIGINT SIGTERM

if [ "x$DEST_USER" != "x" ]
then
    SSH_OPTIONS="$SSH_OPTIONS -l $DEST_USER"
fi

while (true);
do

    ssh $SSH_OPTIONS -ND $BIND_ADDRESS:$BIND_PORT -o BatchMode="yes" -o ServerAliveInterval="120" -o ExitOnForwardFailure="yes" $DEST_ADDRESS &
    ssh_pid=$!      # catch ssh's pid so we can cleanup it later when a SIGNAL received

    wait $ssh_pid   # wait for it

    ret=$?

    if [ $ret == 255 ]
    then
        # ssh returned with error, wait for couple of seconds
        sleep $RECONNECT_AFTER
    fi

done
