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
        echo "removed."
    ;;
    *)
        cp $CWD/dzen-launcher /usr/bin/dzen-launcher
        echo "installed."
    ;;
esac
