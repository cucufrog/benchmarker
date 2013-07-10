#!/bin/bash


BENCHMARKS="\
parsec.blackscholes \
parsec.bodytrack \
parsec.canneal \
parsec.dedup \
parsec.ferret \
parsec.fluidanimate \
parsec.freqmine \
parsec.raytrace \
parsec.streamcluster \
parsec.swaptions \
parsec.vips \
parsec.x264 \
ouyang.hackbench \
ouyang.iozone \
ouyang.specjbb \
ouyang.kernel \
"
#parsec.netferret \
#parsec.netdedup \
#parsec.netstreamcluster \
#parsec.facesim \

LOG=`date +%m-%d-%y_%H%M`.log
echo > log/$LOG
for benchmark in $BENCHMARKS; do
	echo "==== Running $benchmark ===="
	cmd="cd bench/parsec-3.0; source env.sh; parsecmgmt -a run -p $benchmark -i native -n 8 -d /mnt"
	echo "=== $benchmark ===" >> log/$LOG
	ssh root@esx "sched-stats -t vcpu-state-counts | grep ubuntu | grep vcpu" | tee -a log/$LOG
	echo | tee -a log/$LOG
	(time fab -H vm1,vm2,vm3 cmd:"$cmd" --hide=stdout) 2>&1 | tee -a log/$LOG
	ssh root@esx "sched-stats -t vcpu-state-counts | grep ubuntu | grep vcpu" | tee -a log/$LOG
	echo "==== Done $benchmark ===="
done
