#!/bin/bash

# the --help command -- show the usage text
function usage() {
        cat <<USAGE

Usage: '$SCRIPTNAME command [options]'

        COMMANDS                                OPTIONS                             DESCRIPTION

        -h | --help                     ('int1' for node, e.g: 1)                   show this help message and exit

        --start-cluster                                                             start all $ITN1_NODES_COUNT itn1_cluster nodes
        --stop-cluster                                                              stop all $ITN1_NODES_COUNT itn1_cluster nodes
        --restart-cluster                                                           restart all $ITN1_NODES_COUNT itn1_cluster nodes
        --status-cluster                                                            show all $ITN1_NODES_COUNT itn1_cluster nodes status
        --enable-cluster                                                            make itn1_cluster persistent on reboot
        --disable-cluster                                                           remove itn1_cluster reboot persistance

        --start-node                            int1                                start a single node
        --stop-node                             int1                                stop a single node
        --restart-node                          int1                                restart a single node
        --status-node                           int1                                status of a single node
        --settings                              int1                                show settings of a single node

        --get-leader                            int1 || --all                       get the leader(s) ID(s) of a single node; '--all' for all nodes
        --promote-leader                        int1 || --all                       add next progressive leader ID to a node; use '--all' at your own risk....
        --demote-leader                         int1 int2 || --all                  remove the 'int2' leader ID from a single node; '--all' for all nodes
        --swap-leader                           int1 int2                           swap leadership from node 'int1' to node 'int2'; be very careful with this one....

        --account-balance                       int1                                check $POOL_TICKER account balance
        --current-stakes                        int1                                check $POOL_TICKER current stakes balance
        --live-stakes                           int1                                check $POOL_TICKER live stakes balance
        --epoch-stakes                          int1 int2                           check $POOL_TICKER specific epoch 'int2' stakes balance
        --epoch-rewards                         int1 int2                           check $POOL_TICKER specific epoch 'int2' rewards balance
        --rewards-balance                       int1                                check $POOL_TICKER rewards balance
        --rewards-history                       int1 int2                           check $POOL_TICKER rewards history 'int2' of the length last epoch(s) from tip

        --leader-logs                           int1                                show the full leader logs for $POOL_TICKER
        --scheduled-slots                       int1                                check how many slots is $POOL_TICKER node scheduled for
        --scheduled-dates                       int1                                show which scheduled DATEs in this epoch for $POOL_TICKER
        --scheduled-times                       int1                                show which scheduled TIMEs in this epoch for $POOL_TICKER
        --scheduled-next                        int1                                show when is the NEXT scheduled block for $POOL_TICKER node

        --live-logs                             int1                                show logs of a single node
        --last-logs                             int1 int2                           show last 'int2' lines of logs for a single node
        --problems                              int1 int2                           search for 'cannot|stuck|exit|unavailable' in 'int2' lines of logs for a single node
        --issues                                int1 int2                           search for 'WARN|ERRO' in 'int2' lines of logs for a single node

        --snapshot                              int1                                show a brief overview of a single node
        --bstrap-time                           int1 || --all                       calculate how long the 'int1' node bootstrap took; '--all' for all nodes
        --last                                  int1 || --all                       show when 'int1' node was last restarted; '--all' for all nodes

        --node-stats                            int1                                show 'int1' NODE stats
        --pool-stats                            int1                                show $POOL_TICKER pool stats
        --net-stats                             int1                                show 'int1' NETWORK stats
        --sys-stats                             int1                                show a TOP snapshot of 'int1' node
        --date-stats                            int1 int2 int3                      show 'int3' received block announcement in 'int2' lines of logs for 'int1' node

        --current-tip                           int1                                show the current tip for 'int1' node
        --next-epoch                                                                show a countdown to NEXT EPOCH
        --block-now                                                                 show SHELLEY current block
        --block-delta                           itn1                                show a single node block delta (as in how far behind it is)
        --block-valid                           int1 <blockid>                      check a block against the REST API to verify its validity

        --check-peers                                                               check ping to trusted peers with tcpping
        --connected-ips                         int1 int2                           count how many 'int2' connections to a specific IP
        --is-quarantined                        int1                                check if $POOL_TICKER public IP is quarantined (or was quarantined recently)
        --quarantined-ips                       int1                                show all quarantined IPs
        --quarantined-ips-count                 int1                                count of all quarantined IPs

        --fragments                             int1                                list all fragments_id from 'int1' node logs
        --fragments-count                       int1                                show the fragmented_id count from 'int1' node logs
        --fragment-status                       int1 <fragment_id>                  check a fragment_id/transaction status from 'int1' node logs

USAGE
}
