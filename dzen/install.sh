#!/bin/bash

ROOT_UID=0
CWD=`pwd`

if [ "$UID" != "$ROOT_UID" ]
then
  echo "Error: Only root can run this script." >&2
  exit 1;
fi

case "$1" in
    remove)
        rm -rf /usr/bin/dzen-launcher
        rm -rf /usr/bin/dzen-init
        rm -rf /usr/bin/dzen-datetime
        rm -rf /usr/bin/dzen-netmon
        echo "removed."
    ;;
    *)
        cp $CWD/dzen-launcher /usr/bin/dzen-launcher
        cp $CWD/dzen-init     /usr/bin/dzen-init
        cp $CWD/dzen-datetime /usr/bin/dzen-datetime
        cp $CWD/dzen-netmon   /usr/bin/dzen-netmon
        echo "installed."
    ;;
esac
