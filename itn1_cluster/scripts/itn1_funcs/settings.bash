#!/bin/bash

## self-explanatory
function itn1Settings() {
    checkNodesNum "$1"
    notAtALL

    $JCLI rest v0 settings get -h "$ITN1_RESTAPI_URL"
}
