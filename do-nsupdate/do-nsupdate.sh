#!/bin/bash

# local settings, must be changed
KEY="/etc/dnssec/Khome.vardump.org.+157+33145.private"
SERVER="209.9.227.207"
ZONE="vardump.org"
NTPSERVERS="ntp.belnet.be brussels.belnet.be leuven.belnet.be"
HOSTNAME="home.vardump.org" #HOSTNAME="$(hostname | cut -d. -f1)"
IPADDR=$(curl -s http://echoip.vardump.org)

while (true);
do

    echo $IPADDR > "/tmp/do-nsupdate"

cat <<EOF | nsupdate -d -k "$KEY"
        server $SERVER
        zone $ZONE
        update delete $HOSTNAME
        update add $HOSTNAME 60 A $IPADDR
        send
EOF

    OLDIP=$(cat "/tmp/do-nsupdate")

    while ( [ "x${OLDIP}" == "x${IPADDR}" ] );
    do
        sleep 5
        NEWIP=$(curl -s http://echoip.vardump.org/)

        if [ "x${NEWIP}" != "x" ] ; then
            IPADDR=$NEWIP
        fi

    done

done
