#!/bin/bash

LOG=`date +%m-%d-%y_%H%M`.log
benchmark=parsec

echo "==== Running $benchmark ===="
cmd="cd bench/parsec-3.0; source env.sh; parsecmgmt -k -a run -p $benchmark -i native -n 8"
echo "=== $benchmark ===" >> log/$LOG
ssh root@esx "sched-stats -r" | tee -a log/$LOG
echo | tee -a log/$LOG
(time fab -H vm1 cmd:"$cmd" --hide=stdout) 2>&1 | tee -a log/$LOG
ssh root@esx "vsi_traverse -o /vmfs/volumes/datastore1/$LOG" | tee -a log/$LOG
echo "==== Done $benchmark ===="
