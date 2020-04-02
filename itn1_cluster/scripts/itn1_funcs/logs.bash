#!/bin/bash

## show live logs for node
function itn1LiveLogs() {
    checkNodesNum "$1"
    notAtALL
    journalctl -f -u itn1_cluster@"$ITN1_NODE_NUM".service
}

## the last $howManyLines lines of the current logs for node
function itn1LastLogs() {
    checkNodesNum "$1"
    notAtALL
    if [ -n "$2" ]; then
        howManyLines="$2"
        if ! [[ "$howManyLines" =~ ^[0-9]+$ ]]; then
            echo "INT Error: the number of lines can be integers only"
            exit 30
        fi
    else
        echo "you must provide how many lines you want to go far back in the logs, as one paramenter"
        echo "e.g: $SCRIPTNAME --last-logs $1 500"
        exit 2
    fi

    journalctl --no-pager -n "$howManyLines" -u itn1_cluster@"$ITN1_NODE_NUM".service
}

## are there any serious problems in the last $howManyLines lines of the current logs for node?
function itn1ProblemsInLogs() {
    checkNodesNum "$1"
    notAtALL
    if [ -n "$2" ]; then
        howManyLines="$2"
        if ! [[ "$howManyLines" =~ ^[0-9]+$ ]]; then
            echo "INT Error: the number of lines can be integers only"
            exit 30
        fi
    else
        echo "you must provide how many lines you want to go far back in the logs, as one paramenter"
        echo "e.g: $SCRIPTNAME --problems $1 500"
        exit 2
    fi

    journalctl --no-pager -n "$howManyLines" -u itn1_cluster@"$ITN1_NODE_NUM".service | grep -i -E 'cannot|stuck|exit|unavailable'
}

## are there any issues in the last $howManyLines lines of the current logs for node?
function itn1IssuesInLogs() {
    checkNodesNum "$1"
    notAtALL
    if [ -n "$2" ]; then
        howManyLines="$2"
        if ! [[ "$howManyLines" =~ ^[0-9]+$ ]]; then
            echo "INT Error: the number of lines can be integers only"
            exit 30
        fi
    else
        echo "you must provide how many lines you want to go far back in the logs, as one paramenter"
        echo "e.g: $SCRIPTNAME --issues $1 500"
        exit 2
    fi

    journalctl --no-pager -n "$howManyLines" -u itn1_cluster@"$ITN1_NODE_NUM".service | grep -E "WARN|ERRO"
}
