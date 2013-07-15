#!/bin/bash


#parsec.blackscholes \
#parsec.bodytrack \
#parsec.canneal \
#parsec.dedup \
#parsec.ferret \
#parsec.fluidanimate \
#parsec.freqmine \
#parsec.raytrace \
#parsec.streamcluster \
#parsec.swaptions \
BENCHMARKS="\
parsec.vips \
parsec.x264 \
ouyang.hackbench \
ouyang.iozone \
ouyang.specjbb \
"

BENCHMARKS_TMP="ouyang.hackbench"

#parsec.netferret \
#parsec.netdedup \
#parsec.netstreamcluster \
#parsec.facesim \
#ouyang.kernel \

LOG=`date +%m-%d-%y_%H%M`.log
echo > log/$LOG

for benchmark in $BENCHMARKS_TMP; do
	echo "==== Running $benchmark ===="
	cmd="cd bench/parsec-3.0; source env.sh; parsecmgmt -k -a run -p $benchmark -i native -n 8 -d /mnt"
	echo "=== $benchmark ===" >> log/$LOG
	#ssh root@esx "sched-stats -t vcpu-state-counts | grep ubuntu | grep vcpu" | tee -a log/$LOG
	ssh root@esx "sched-stats -r" | tee -a log/$LOG
	echo | tee -a log/$LOG
	(time fab -H vm1,vm2,vm3,vm4 cmd:"$cmd" --hide=stdout) 2>&1 | tee -a log/$LOG
	#ssh root@esx "sched-stats -t vcpu-state-counts | grep ubuntu | grep vcpu" | tee -a log/$LOG
	ssh root@esx "vsi_traverse -o /vmfs/volumes/datastore1/log/$LOG" | tee -a log/$LOG
	echo "==== Done $benchmark ===="
done

#fab -H vm1,vm2,vm3,vm4 cmd:"rm -rf ~/bench/parsec-3.0/log/*" --hide=stdout 
