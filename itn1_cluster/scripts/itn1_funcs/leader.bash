#!/bin/bash

## does the node have one or more leader IDs?
function itn1GetLeader() {
    checkNodesNum "$1"

    ## if ALL is set
    if [[ "$ALLISSET" == "true" ]]; then
        ## loop over all nodes
        for ((i = 1; i <= "$ITN1_NODES_COUNT"; i++)); do
            ## to get each REST API port
            ITN1_RESTAPI_URL="http://127.0.0.1:${ITN1_REST_API_PORT%?}$i/api"
            ## set node number for prints
            NODE_NUM="$i"
            ## list leaders info for all nodes
            nodeStatus=$($JCLI rest v0 node stats get -h "$ITN1_RESTAPI_URL" | awk '/state/ {print $2}')
            if [ "$nodeStatus" == "Running" ]; then
                HAS_LEADERS=$($JCLI rest v0 leaders get -h "$ITN1_RESTAPI_URL" | grep -v -e "^\\---" -e "^\\[" -c)
                if [[ "$HAS_LEADERS" -ge 1 ]]; then
                    echo "ITN1_NODE_$NODE_NUM has: $HAS_LEADERS leader(s) with the following IDs: "
                    "$JCLI" rest v0 leaders get -h "$ITN1_RESTAPI_URL" | grep -v -e "^\\---" -e "^\\["
                else
                    echo "ITN1_NODE_$NODE_NUM has: NO leader!!!"
                fi
            elif [ "$nodeStatus" == "Bootstrapping" ]; then
                echo "NODE Warn: ITN1_NODE_$NODE_NUM is Bootstrapping, exiting the routine"
                continue
            else
                echo "NODE Error: ITN1_NODE_$NODE_NUM NOT AVAILABLE, IS IT DOWN?"
                continue
            fi
        done
    else
        ## set node number for prints
        NODE_NUM="$1"
        ## if single node is provided, then just check the one node...
        nodeStatus=$($JCLI rest v0 node stats get -h "$ITN1_RESTAPI_URL" | awk '/state/ {print $2}')
        if [ "$nodeStatus" == "Running" ]; then
            HAS_LEADERS=$($JCLI rest v0 leaders get -h "$ITN1_RESTAPI_URL" | grep -v -e "^\\---" -e "^\\[" -c)
            if [[ "$HAS_LEADERS" -ge 1 ]]; then
                echo "ITN1_NODE_$NODE_NUM has: $HAS_LEADERS leader(s) with the following IDs: "
                "$JCLI" rest v0 leaders get -h "$ITN1_RESTAPI_URL" | grep -v -e "^\\---" -e "^\\["
            else
                echo "ITN1_NODE_$NODE_NUM has: NO leader!!!"
            fi
        elif [ "$nodeStatus" == "Bootstrapping" ]; then
            echo "NODE Warn: ITN1_NODE_$NODE_NUM is Bootstrapping, exiting the routine"
            exit 41
        else
            echo "NODE Error: ITN1_NODE_$NODE_NUM NOT AVAILABLE, IS IT DOWN?"
            exit 40
        fi
    fi
}

## promote all deduplication of code
function promoteALL() {
    ## loop over all nodes
    for ((i = 1; i <= "$ITN1_NODES_COUNT"; i++)); do
        ## set the environemnt variables for each node
        ITN1_RESTAPI_URL="http://127.0.0.1:${ITN1_REST_API_PORT%?}$i/api"
        NODE_DIR="${ITN1_MAIN_DIR}/itn1_node_$i"
        NODE_SECRET="itn1_node_${i}_secret.yaml"
        ## does it have a lader already?
        HAS_LEADERS=$($JCLI rest v0 leaders get -h "$ITN1_RESTAPI_URL" | grep -v -e "^\\---" -e "^\\[" -c)
        ## if it does, warn the user and continue with the other nodes instead...
        if [[ "$HAS_LEADERS" -ge 1 ]]; then
            echo "ATTENTION!!!!: ITN1_NODE_$i ALREADY HAS LEADER(s) WITH THE FOLLOWING ID(s): "
            "$JCLI" rest v0 leaders get -h "$ITN1_RESTAPI_URL" | grep -v -e "^\\---" -e "^\\["
            echo "Please act manually on node ITN1_NODE_$i to avoid complications....."
            continue
        else
            ##...otherwise promote leader for node
            echo -n "ADDING a new leader to ITN1_NODE_$i with ID ==> "
            "$JCLI" rest v0 leaders post -f "$NODE_DIR"/"$NODE_SECRET" -h "$ITN1_RESTAPI_URL"
            ## let's pause for a second in between, just in case
        fi
    done
}

## self-explanatory
function itn1PromoteLeader() {
    ## checksum $2 here because of batch mode....
    checkNodesNum "$1" "$2"

    ## if ALL is set
    if [[ "$ALLISSET" == "true" ]] && [[ "$BATCHMODE" == "false" ]]; then
        ## let's make sure the user knows there are consequences
        read -r -p "ATTENTION: HAVING MULTIPLE LEADERS CAN HAVE DIRE CONSEQUENCES!!!! TYPE 'YES' (no quotes) TO CONTINUE -- YOU'VE BEEN WARNED... "
        if [[ $REPLY != "YES" ]]; then
            exit 90
        fi
        promoteALL
    elif [[ "$ALLISSET" == "true" ]] && [[ "$BATCHMODE" == "true" ]]; then
        promoteALL
    else
        ## promote single node to leader candidate
        echo -n "ADDING a new leader to ITN1_NODE_$1 with ID ==> "
        "$JCLI" rest v0 leaders post -f "$NODE_DIR"/"$NODE_SECRET" -h "$ITN1_RESTAPI_URL"
    fi
}

## self-explanatory
function itn1DemoteLeader() {
    checkNodesNum "$1"

    ## if ALL is set
    if [[ "$ALLISSET" == "true" ]]; then
        ## loop over all nodes
        for ((i = 1; i <= "$ITN1_NODES_COUNT"; i++)); do
            ## set the environemnt variables for each node
            ITN1_RESTAPI_URL="http://127.0.0.1:${ITN1_REST_API_PORT%?}$i/api"
            nodeStatus=$($JCLI rest v0 node stats get -h "$ITN1_RESTAPI_URL" | awk '/state/ {print $2}')
            if [ "$nodeStatus" == "Running" ]; then
                ## does it have a lader already?
                HAS_LEADERS=$($JCLI rest v0 leaders get -h "$ITN1_RESTAPI_URL" | grep -v -e "^\\---" -e "^\\[" -c)
                ## if it does, iterate over each node to demote each leader
                if [[ "$HAS_LEADERS" -ge 1 ]]; then
                    for ((l = 1; l <= "$HAS_LEADERS"; l++)); do
                        leaderID="$l"
                        ## demote node from leader candidate
                        echo "REMOVING <leaderId> ==> $leaderID <== from ITN1_NODE_$i"
                        "$JCLI" rest v0 leaders delete "$leaderID" -h "$ITN1_RESTAPI_URL"
                    done
                else
                    echo "ATTENTION!!!! ITN1_NODE_$i DOES NOT HAVE ANY LEADER TO DEMOTE!!!"
                    continue
                fi
            elif [ "$nodeStatus" == "Bootstrapping" ]; then
                echo "NODE Warn: ITN1_NODE_$NODE_NUM is Bootstrapping, exiting the routine"
                continue
            else
                echo "NODE Error: ITN1_NODE_$NODE_NUM NOT AVAILABLE, IS IT DOWN?"
                continue
            fi
        done
    else
        if [[ -n "$2" ]]; then
            leaderID="$2"
            if ! [[ "$leaderID" =~ ^[0-9]+$ ]]; then
                echo "INT Error: <leaderId> can be integers only"
                exit 30
            fi
        else
            echo "you must provide a valid <leaderId> to demote"
            echo "e.g: $SCRIPTNAME --demote-leader $1 <leaderId>"
            exit 2
        fi

        ## does it have a lader at all?
        HAS_LEADERS=$($JCLI rest v0 leaders get -h "$ITN1_RESTAPI_URL" | grep -v -e "^\\---" -e "^\\[" -c)
        ## if it does, warn the user and continue with the other nodes instead...
        if [[ "$HAS_LEADERS" -eq 0 ]]; then
            echo "ATTENTION!!!! ITN1_NODE_$1 DOES NOT HAVE ANY LEADER TO DEMOTE!!!"
            exit 1
        elif ! [[ "$HAS_LEADERS" =~ ^[0-9]+$ ]]; then
            echo "INT Error: <leaderId> can be integers only"
            exit 30
        elif [[ "$leaderID" -gt "$HAS_LEADERS" ]]; then
            echo "INT Error: <leaderId> is invalid (greater than leaders ID count)"
            exit 30
        else
            ## demote node from leader candidate
            echo "REMOVING <leaderId> ==> $leaderID <== from ITN1_NODE_$1"
            "$JCLI" rest v0 leaders delete "$leaderID" -h "$ITN1_RESTAPI_URL"
        fi
    fi
}

#function itn1SwapLeader() {
#    noArgsIsFineForThisOne
#
#    for (( i = 1; i <= "$ITN1_NODES_COUNT"; i++ )); do
#        ## to get each REST API port
#        ITN1_RESTAPI_URL="http://127.0.0.1:${ITN1_REST_API_PORT%?}$i/api"
#        ## set node number for prints
#        NODE_NUM="$i"
#        ## are node down?
#        NODE_DOWN=0
#        ## are slots assgined to the pool?
#        howManySlots=0
#        ## list leaders info for all nodes
#        nodeStatus=$($JCLI rest v0 node stats get -h "$ITN1_RESTAPI_URL" | awk '/state/ {print $2}')
#        if [ "$nodeStatus" == "Running" ]; then
#            ## how many slots?
#            howManySlots=$($JCLI rest v0 leaders logs get -h "$ITN1_RESTAPI_URL" | grep -c created_at_time)
#            echo "$howManySlots"
#        elif [ "$nodeStatus" == "Bootstrapping" ]; then
#            echo "NODE Warn: ITN1_NODE_$NODE_NUM is Bootstrapping, exiting the routine"
#            continue
#        else
#            WHICH_DOWN[++a]="ITN1_NODE_$NODE_NUM"
#            ((NODE_DOWN++))
#            continue
#        fi
#    done
#
#    if [ "$NODE_DOWN" -gt 0 ]; then
#        echo "NODE Error: ${WHICH_DOWN[*]} nodes are DOWN"
#    elif [ "$NODE_DOWN" -eq "$ITN1_NODES_COUNT" ]; then
#        echo "NODE Error: attention!!! ALL nodes are DOWN"
#        exit 42
#    fi
#}
