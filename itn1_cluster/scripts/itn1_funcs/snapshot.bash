#!/bin/bash

## gives a bird-view of node health and stats
## don't run this too often. a watch -n5 is more than enough
## NOTE: you could have multiple panels open with fewer checks in each one

## TODO: improve 'dashboard' and possibly offer switches for diversify info
function itn1CurrentStatus() {
    checkNodesNum "$1"
    notAtALL

    clear
    echo -e "--- NODE_$1 Stats ---\\n"
    nextEpoch
    itn1blocksDelta "$1"
    echo
    itn1HowManySlots "$1"
    itn1NextScheduledBlock "$1"
    echo
    echo "%CPU %MEM CACHE LOAD AVERAGE"
    NODE_PID=$(systemctl --no-pager show --property MainPID --value itn1_cluster@"$1".service)
    echo "$(top -b -n 3 -d 0.2 -p "$NODE_PID" | tail -1 | awk '{print $9,$10}') $(free -m -w | awk '/Mem:/ {print $7}')M  $(awk '{print $1,$2,$3}' /proc/loadavg)"
    echo
    itn1NodeStats "$1"
    echo
    echo "---"
    itn1IsBlockValid "$1" "$($JCLI rest v0 node stats get -h "$ITN1_RESTAPI_URL" | awk '/lastBlockHash/ {print $2}')"
    echo
}
