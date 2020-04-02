#!/bin/bash

## time and date calculations, used internally by the script
function intDateFunc() {
    ## getting a constant from jcli is taxing for the REST API....
    #chainstartdate=$($JCLI rest v0 settings get -h "$ITN1_RESTAPI_URL" | awk '/block0Time/ {print $2}' | tr -d '"' | xargs -I{} date "+%s" -d {})
    ## .... better to just shove it in a variables if it changes..
    chainstartdate=1576264417
    elapsed=$((($(date +%s) - chainstartdate)))
    epoch=$(((elapsed / 86400)))
    slot=$(((elapsed % 86400) / 2))
    nowBlockDate="$epoch.$slot"
    nextepoch="$((($(date +%s) + (86400 - (elapsed % 86400)))))"
    nextepochToDate="$(date --iso-8601=s -d@+$nextepoch)"
    dateNow="$(date --iso-8601=s)"
    ### currently not possible to calculate nowBlockHeight=""
}

## self-explanatory
function itn1NodeStats() {
    checkNodesNum "$1"
    notAtALL

    $JCLI rest v0 node stats get -h "$ITN1_RESTAPI_URL"
}

## self-explanatory
function itn1PoolStats() {
    checkNodesNum "$1"
    notAtALL

    $JCLI rest v0 stake-pool get "$(awk '/node_id/ {print $2}' "$NODE_DIR"/"$NODE_SECRET")" -h "$ITN1_RESTAPI_URL"
}

## self-explanatory
function itn1NetStats() {
    checkNodesNum "$1"
    notAtALL

    $JCLI rest v0 network stats get -h "$ITN1_RESTAPI_URL"
}

# top snapshot of jourmungandr
function itn1ResourcesStat() {
    checkNodesNum "$1"
    notAtALL

    echo "Here's some quick system resources stats for ITN_NODE_$1: "
    NODE_PID=$(systemctl --no-pager show --property MainPID --value itn1_cluster@"$1".service)
    top -b -n 4 -d 0.1 -p "$NODE_PID" | tail -2
}

## check logs to calculate exact bootstrap time
function itn1BootstrapTime() {
    checkNodesNum "$1"

    ## if ALL is set
    if [[ "$ALLISSET" == "true" ]]; then
        ## loop over all nodes
        for ((i = 1; i <= "$ITN1_NODES_COUNT"; i++)); do
            ## temporary node variable to cycle through
            NODE_RESTAPI_PORT="${ITN1_REST_API_PORT%?}$i"
            NODE_RESTAPI_URL="http://127.0.0.1:$NODE_RESTAPI_PORT/api"
            NODE_STATE=$($JCLI rest v0 node stats get -h "$NODE_RESTAPI_URL" | awk '/state/ {print $2}')
            if [ "$NODE_STATE" == "Bootstrapping" ]; then
                echo "ITN_NODE_$i is still bootstrapping, check back soon"
                continue
            else
                NODE_PID=$(systemctl --no-pager show --property MainPID --value itn1_cluster@"$i".service)
                NODE_UPTIME=$($JCLI rest v0 node stats get -h "$NODE_RESTAPI_URL" | awk '/uptime/ {print $2}')
                NODE_PSTIME=$(ps -o etimes= -p "$NODE_PID" | awk '{print $i}')
                todateUPTIME=$(date --iso-8601=s -d@+"$NODE_UPTIME")
                toDatePSTIME=$(date --iso-8601=s -d@+"$NODE_PSTIME")
                dateutils.ddiff "$todateUPTIME" "$toDatePSTIME" -f "Bootstrap for ITN_NODE_$i took exactly %M minutes and %S seconds"
            fi
        done
    else
        NODE_STATE=$($JCLI rest v0 node stats get -h "$ITN1_RESTAPI_URL" | awk '/state/ {print $2}')
        if [ "$NODE_STATE" == "Bootstrapping" ]; then
            echo "ITN_NODE_$1 is still bootstrapping, check back soon"
            exit 1
        else
            NODE_PID=$(systemctl --no-pager show --property MainPID --value itn1_cluster@"$1".service)
            NODE_UPTIME=$($JCLI rest v0 node stats get -h "$ITN1_RESTAPI_URL" | awk '/uptime/ {print $2}')
            NODE_PSTIME=$(ps -o etimes= -p "$NODE_PID" | awk '{print $1}')
            todateUPTIME=$(date --iso-8601=s -d@+"$NODE_UPTIME")
            toDatePSTIME=$(date --iso-8601=s -d@+"$NODE_PSTIME")
            dateutils.ddiff "$todateUPTIME" "$toDatePSTIME" -f "Bootstrap for ITN_NODE_$i took exactly %M minutes and %S seconds"
        fi
    fi
}

## when was ITN_NODE last restarted
function itn1LastStart() {
    checkNodesNum "$1"

    ## if ALL is set
    if [[ "$ALLISSET" == "true" ]]; then
        ## loop over all nodes
        for ((i = 1; i <= "$ITN1_NODES_COUNT"; i++)); do
            NODE_PID=$(systemctl --no-pager show --property MainPID --value itn1_cluster@"$i".service)
            NODE_PSTIME=$(ps -o etimes= -p "$NODE_PID" | awk '{print $1}')
            echo "ITN_NODE_$i was last started @: $(date --date "-$NODE_PSTIME seconds")"
        done
    else
        NODE_PID=$(systemctl --no-pager show --property MainPID --value itn1_cluster@"$1".service)
        NODE_PSTIME=$(ps -o etimes= -p "$NODE_PID" | awk '{print $1}')
        echo "ITN_NODE_$1 was last started @: $(date --date "-$NODE_PSTIME seconds")"
    fi
}

## self-explanatory
function currentBlockDate() {
    intDateFunc
    echo "nowBlockDate: \"$nowBlockDate\""
}

## self-explanatory
function nextEpoch() {
    intDateFunc
    echo "NEXT    EPOCH: $(dateutils.ddiff "$dateNow" "$nextepochToDate" -f "%H hours %M minutes and %S seconds")"
}

## check the current tip of your pool
function itn1GetCurrentTip() {
    checkNodesNum "$1"
    notAtALL

    CURRENTTIPHASH=$($JCLI rest v0 tip get -h "$ITN1_RESTAPI_URL")
    LASTBLOCKHEIGHT="$($JCLI rest v0 node stats get -h "$ITN1_RESTAPI_URL" | awk '/lastBlockHeight/ {print $2}' | sed 's/"//g')"
    LASTPOOLID="$($JCLI rest v0 block "$CURRENTTIPHASH" get -h "$ITN1_RESTAPI_URL" | cut -c169-232)"

    echo "POOL TIP  : $LASTBLOCKHEIGHT"
    echo "TIP HASH  : $CURRENTTIPHASH"
    echo "LASTPOOL  : $LASTPOOLID"
}

## currently not possible to calculate nowBlockHeight=""
## function tipHeightDelta() {
##     intDateFunc
##     lastBlockHeight="$($JCLI rest v0 node stats get -h "$ITN1_RESTAPI_URL" | awk '/lastBlockHeight/ {print $2}' | sed 's/\"//g')"
##     deltaHeightCount=$(echo "$nowBlockHeight - $lastBlockHeight" | bc)
##
##     echo "CURRENT   TIP: $nowBlockHeight"
##     echo "$POOL_TICKER      TIP: $lastBlockHeight"
##     echo "TIP     DELTA: $deltaHeightCount"
## }

## what is the single node date delta?
function itn1blocksDelta() {
    intDateFunc
    checkNodesNum "$1"
    notAtALL

    lastBlockDate="$($JCLI rest v0 node stats get -h "$ITN1_RESTAPI_URL" | awk '/lastBlockDate/ {print $2}' | sed 's/\"//g')"
    deltaBlockCount=$(echo "$nowBlockDate - $lastBlockDate" | bc)
    if ! [[ "$deltaBlockCount" =~ ^[0-9]+$ ]]; then
        deltaBlockCount="${deltaBlockCount//\./0\.}"
    fi

    echo "CURRENT  DATE: $nowBlockDate"
    echo "NODE_$1   DATE: $lastBlockDate"
    echo "NODE_$1  DELTA: $deltaBlockCount"
}

## check the count for last received dates in logs
function itn1LastDates() {
    checkNodesNum "$1"
    notAtALL

    ## default values
    howManyLogLines=5000
    howManyDateResults=20

    ## how far back
    if [ -n "$2" ]; then
        howManyLogLines="$2"
        if ! [[ "$howManyLogLines" =~ ^[0-9]+$ ]]; then
            echo "INT Error: the number of lines can be integers only"
            exit 30
        fi
    fi

    ## how many to display
    if [ -n "$3" ]; then
        howManyDateResults="$3"
        if ! [[ "$howManyDateResults" =~ ^[0-9]+$ ]]; then
            echo "INT Error: the number of dates can be integers only"
            exit 30
        fi
    fi

    echo -e "--- NODE_$1 Date Annoucements Stats\\n"
    journalctl --no-pager -n "$howManyLogLines" -u itn1_cluster@"$ITN1_NODE_NUM".service | awk '/date:/ {print $18}' | sort | uniq -c | sort -Vr -k2 | sed 's/,//g' | head -"$howManyDateResults"
}
