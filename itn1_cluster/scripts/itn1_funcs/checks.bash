#!/bin/bash

## check if a block is valid. if NOT, your pool may be forking
function itn1IsBlockValid() {
    checkNodesNum "$1"
    notAtALL

    if [ -n "$2" ]; then
        blockId="$2"
    else
        echo "you must provide one paramenter, it must be a valid block id"
        echo "e.g: $SCRIPTNAME --block-valid $1 <blockId>"
        exit 1
    fi

    if $JCLI rest v0 block "$blockId" next-id get -h "$ITN1_RESTAPI_URL" >/dev/null 2>&1; then
        echo "Success: \"${blockId}\" is VALID"
    else
        echo "ERROR: \"${blockId}\" NOT FOUND!!! YOU COULD BE FORKED"
    fi
}

## get a list of fragment_id
function itn1FragmentsIds() {
    checkNodesNum "$1"
    notAtALL

    echo "This is a list of the current fragment_id:"
    $JCLI rest v0 message logs -h "$ITN1_RESTAPI_URL" | grep "fragment_id"
}

## returns count for frament_id
function itn1FragmentIdCount() {
    checkNodesNum "$1"
    notAtALL

    echo "What is the current fragment_id count?"
    $JCLI rest v0 message logs -h "$ITN1_RESTAPI_URL" | grep -c "fragment_id"
}

## check the status of a transaction/frament
function itn1FragmentStatus() {
    checkNodesNum "$1"
    notAtALL

    if [ -n "$2" ]; then
        fragment="$2"
    else
        echo "you must provide a valid fragment_id"
        echo "e.g: $SCRIPTNAME --fragment $1 <fragment_id>"
        exit 1
    fi

    $JCLI rest v0 message logs -h "$ITN1_RESTAPI_URL" --output-format json | jq ".[] | select(.fragment_id==\"$fragment\")"
}
