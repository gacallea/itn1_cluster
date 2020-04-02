#!/bin/bash

## ALL OF THESE ARE PROVIDED FOR CONVENIENCE. FEEL FREE TO USE SYSTEMCTL AS USUAL :)
function itn1ClusterStart() {
    systemctl start itn1_cluster.target
}

function itn1ClusterStop() {
    systemctl stop itn1_cluster.target
}

function itn1ClusterREStart() {
    systemctl restart itn1_cluster.target
}

function itn1ClusterStatus() {
    #systemctl status itn1_cluster.target
    systemctl status itn1_cluster@*.service
}

function itn1ClusterEnable() {
    systemctl enable itn1_cluster.target
}

function itn1ClusterDisable() {
    systemctl disable itn1_cluster.target
}

function itn1NodeStart() {
    checkNodesNum "$1"
    notAtALL
    systemctl start itn1_cluster@"$ITN1_NODE_NUM".service
}

function itn1NodeStop() {
    checkNodesNum "$1"
    notAtALL
    systemctl stop itn1_cluster@"$ITN1_NODE_NUM".service
}

function itn1NodeStatus() {
    checkNodesNum "$1"
    notAtALL
    systemctl status itn1_cluster@"$ITN1_NODE_NUM".service
}

function itn1NodeREStart() {
    checkNodesNum "$1"
    notAtALL
    systemctl restart itn1_cluster@"$ITN1_NODE_NUM".service
}
