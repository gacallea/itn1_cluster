#!/bin/bash

## self-explanatory
function itn1LeaderLogs() {
    checkNodesNum "$1"
    notAtALL

    echo "Leader Logs for $POOL_TICKER: (NODE_$1) "
    $JCLI rest v0 leaders logs get -h "$ITN1_RESTAPI_URL"
}

## self-explanatory
function itn1HowManySlots() {
    checkNodesNum "$1"
    notAtALL

    echo -n "HOW MANY slots has $POOL_TICKER been scheduled for? "
    $JCLI rest v0 leaders logs get -h "$ITN1_RESTAPI_URL" | grep -c created_at_time
}

## self-explanatory
function itn1ScheduleDates() {
    checkNodesNum "$1"
    notAtALL

    echo "Which DATES have been scheduled during this epoch?"
    $JCLI rest v0 leaders logs get -h "$ITN1_RESTAPI_URL" | awk '/scheduled_at_date/ {print $2}' | sed 's/"//g' | sort -V
}

## self-explanatory
function itn1ScheduleTime() {
    checkNodesNum "$1"
    notAtALL

    echo "Which TIMES have been scheduled during this epoch?"
    $JCLI rest v0 leaders logs get -h "$ITN1_RESTAPI_URL" | awk '/scheduled_at_time/ {print $2}' | sed 's/"//g' | sort -g
}

## self-explanatory
## how long before the next scheduled block?
function itn1NextScheduledBlock() {
    checkNodesNum "$1"
    notAtALL

    mapfile -t scheduleDateToTest < <($JCLI rest v0 leaders logs get -h "$ITN1_RESTAPI_URL" | awk '/scheduled_at_time/ {print $2}' | sed 's/"//g' | sort -V)
    for i in "${scheduleDateToTest[@]}"; do
        if ! [[ $(dateutils.ddiff now "$i") =~ "-" ]]; then
            dateutils.ddiff now "$i" -f "BLOCK SCHEDULED IN %H hours %M minutes and %S seconds"
        fi
    done
}
