#!/bin/bash

function checkNodesNum() {
    ALLISSET="false"
    BATCHMODE="false"
    ## was a node number given
    if [[ -z "$1" ]]; then
        ## please specify an argument
        echo "Error: you must provide a node instance number"
        exit 1
    fi

    if [[ "$1" == "--all" ]]; then
        ALLISSET="true"
        if [[ -n "$2" ]] && [[ "$2" == "--batch-mode" ]]; then
            BATCHMODE="true"
        fi
    else
        ITN1_NODE_NUM="$1"
        ## must be an integer
        if ! [[ "$ITN1_NODE_NUM" =~ ^[0-9]+$ ]]; then
            echo "INT Error: node count can be integers only"
            exit 30
        ## must be greater than 0 but less or equal than total amount of nodes
        elif [[ "$ITN1_NODE_NUM" -lt 1 ]] || [[ "$ITN1_NODE_NUM" -gt "$ITN1_NODES_COUNT" ]]; then
            echo "Error: you must enter a valid node count between 1 and $ITN1_NODES_COUNT..."
            exit 3
        fi

        ## if all is good, set these to be used in node related commands
        NODE_DIR="${ITN1_MAIN_DIR}/itn1_node_$1"
        NODE_CONF="itn1_node_${1}_config.yaml"
        NODE_SECRET="itn1_node_${1}_secret.yaml"
        ITN1_RESTAPI_URL="http://127.0.0.1:${ITN1_REST_API_PORT[$1 - 1]}/api"
    fi
}

function notAtALL() {
    if [[ "$ALLISSET" == "true" ]] || [[ "$BATCHMODE" == "true" ]]; then
        echo "Error: '--all' and/or '--batch-mode' are not a valid option for this command..."
        exit 128
    fi
}

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
