#!/bin/bash
# usage: run.sh <timeout> <display> <size> <scale>
rm -f /tmp/trailer/client.log; touch /tmp/trailer/client.log
/tmp/trailer/watch.sh /tmp/trailer/client.log $2 $3 &
cd /tmp/trailer-client && HOME=/tmp/trailer-home DISPLAY=$2 OTCLIENT_DPI_SCALE=$4 timeout $1 ./otclient > /tmp/trailer/client.log 2>&1
echo CLIENT_EXIT=$? >> /tmp/trailer/status
