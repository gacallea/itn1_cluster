#!/bin/bash

## check which IPs your pool has quarantined
function itn1QuarantinedIps() {
    checkNodesNum "$1"
    notAtALL

    echo "List of IP addresses that were quarantined somewhat recently:"
    curl -s "$ITN1_RESTAPI_URL"/v0/network/p2p/quarantined | rg -o "/ip4/.{0,16}" | sed -r '/\n/!s/[0-9.]+/\n&\n/;/^([0-9]{1,3}\.){3}[0-9]{1,3}\n/P;D' | sort -u
    echo "End of somewhat recently quarantined IP addresses."
}

## check how many quaratined IPs are in the above list?
function itn1NOfQuarantinedIps() {
    checkNodesNum "$1"
    notAtALL

    echo "How many IP addresses were quarantined?"
    itn1QuarantinedIps "$1" | wc -l
}

## check if your pool was recently quarantined
function itn1IsPoolQuarantined() {
    checkNodesNum "$1"
    notAtALL

    this_node=$(itn1QuarantinedIps "$1" | rg "${ITN1_PUBLIC_IP_ADDR}")
    if [ -n "${this_node}" ]; then
        echo "ERROR! You were quarantined at some point in the recent past!"
        echo "Execute '$SCRIPTNAME --node-stats $1 | grep peerConnectedCnt' to confirm that you are connecting to other nodes."
    else
        echo "You are clean as a whistle."
    fi
}

## TODO: improve this to avoid repeating cycle
## check ping for trusted peers with tcpping
function itn1CheckPeers() {
    checkNodesNum "$1"
    notAtALL

    sed -e '/address/!d' -e '/#/d' -e 's@^.*/ip./\([^/]*\)/tcp/\([0-9]*\).*@\1 \2@' "$NODE_DIR"/"$NODE_CONF" |
        while read -r addr port; do
            tcpping -x 1 "$addr" "$port"
        done
}

## count connections to nodes and order them by highest number of connections
## accepts 1 paramenter to filter out connections less than supplied number
function itn1ConnectedIps() {
    checkNodesNum "$1"
    notAtALL

    if [ -n "$2" ]; then
        howManyConnections="$2"
        if ! [[ "$howManyConnections" =~ ^[0-9]+$ ]]; then
            echo "INT Error: the number of connections must be integers only"
            exit 30
        fi
    else
        echo "you must provide one paramenter, it must be a valid integer for a minum number of connections to check against"
        echo "e.g: $SCRIPTNAME --connected-ips $1 10 -- this will show IPs that are connect 10 or more times"
        exit 1
    fi

    echo "IP addresses that are connected to ITN_NODE_$1 more than $howManyConnections times:"
    netstat -tn 2>/dev/null | tail -n +3 | awk '{print $5}' | grep -E -v "127.0.0.1|$ITN1_PUBLIC_IP_ADDR" | cut -d: -f1 | sort | uniq -c | sort -nr | awk "{if (\$1 >= $howManyConnections) print \$1,\$2}"
    echo
}
