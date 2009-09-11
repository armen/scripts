#!/bin/sh

ROOT_UID=0
CWD="`pwd`"

DAEMON="$CWD/do-nsupdate.sh"
INITSCRIPT="$CWD/do-nsupdate"

if [ "$UID" -ne "$ROOT_UID" ]
then
  echo "Error: Only root can run this script." >&2
  exit 1;
fi

case "$1" in
    remove)
        /etc/init.d/do-nsupdate stop

        rm -f /etc/init.d/do-nsupdate
        rm -f /usr/sbin/do-nsupdated

      echo
      update-rc.d do-nsupdate remove
      echo
    ;;
    *)

        cp $DAEMON /usr/sbin/do-nsupdate.sh
        cp $INITSCRIPT /etc/init.d/do-nsupdate

        echo
        update-rc.d do-nsupdate defaults 99 01
        echo

        /etc/init.d/do-nsupdate start
    ;;
esac
