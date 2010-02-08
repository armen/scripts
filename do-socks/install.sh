#!/bin/sh

ROOT_UID=0
CWD=`pwd`

DAEMON="$CWD/do-socks.sh"
INITSCRIPT="$CWD/do-socks"
CONFIG="$CWD/do-socks.cfg"
SH_SETUP="$CWD/do-socks-sh-setup"

if [ "$UID" != "$ROOT_UID" ]
then
  echo "Error: Only root can run this script." >&2
  exit 1;
fi

case "$1" in
    remove)
        ignore=`/etc/init.d/do-socks stop 2>/dev/null`

        rm -f "/etc/init.d/do-socks"
        rm -f "/usr/sbin/do-socksd"
        rm -f "/etc/default/do-socks.cfg"

        echo
        update-rc.d "do-socks" remove
        echo
    ;;
    *)

        cp $DAEMON "/usr/sbin/do-socks.sh"
        cp $INITSCRIPT "/etc/init.d/do-socks"
        cp $SH_SETUP "/usr/bin/do-socks-sh-setup"

        echo
        update-rc.d "do-socks" defaults 99 01
        echo

        cp $CONFIG /etc/default/

    ;;
esac
