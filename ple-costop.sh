#!/bin/bash

TAG="PLECostopX4"
DATA_DIR="~/data"
PARAM_LIST="3k"
INPUT="native"
NR_THREADS=8

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
"
#parsec.netferret \
#parsec.netdedup \
#parsec.netstreamcluster \
#parsec.facesim \
#ouyang.kernel \

BENCHMARKS_TMP="ouyang.hackbench"

CUR_DIR=`pwd`
TIMESTAMP=`date +%m%d%y-%H%M`
EXP_DIR="$TAG-$TIMESTAMP"
#EXP_DIR="test"

LOG="$TIMESTAMP.log"
echo > log/$LOG

#
# Cleaning
#
rm log/*
# XXX: number of VM
fab -H vm1 cmd:"rm -rf ~/bench/parsec-3.0/log/*"
ssh root@esx "rm /vmfs/volumes/datastore1/log/*"

#
# Benchmarking
#

date | tee -a log/$LOG
for param in $PARAM_LIST; do
	# update parameter
	bash ./"$param".sh | tee -a log/$LOG

	# iteration
	for i in 1 2 3 4 5; do
		# run
		for benchmark in $BENCHMARKS; do
			# reset
			ssh root@esx "sched-stats -r; sched-stats -s 1" | tee -a log/$LOG

			echo "==== Running $benchmark @param $param====" | tee -a log/$LOG

			cmd="cd bench/parsec-3.0; source env.sh; parsecmgmt -k -a run -p $benchmark -i $INPUT -n $NR_THREADS"
			# XXX: number of VM
			(time fab -H vm1 cmd:"$cmd" --hide=stdout) 2>&1 | tee -a log/$LOG
			#(time fab -H vm1 cmd:"$cmd" --hide=stdout) 2>&1 | tee -a log/$LOG
			
			#host stat dump
			ssh root@esx "vsi_traverse -o /vmfs/volumes/datastore1/log/$benchmark.log" | tee -a log/$LOG

			echo "==== Done $benchmark @param $param====" | tee -a log/$LOG
		done

		# data collection
		fab -H vm1 cmd:"cd ~/data; \
				git pull; \
				mkdir -p $EXP_DIR/$param-$i;"

		# XXX: number of VM
		for j in 1; do
		#for j in 1; do
			fab -H vm$j cmd:"cd ~/data; \
					git pull; \
					mv ~/bench/parsec-3.0/log/amd64* ./$EXP_DIR/$param-$i/guest$j; \
					git add .; \
					git commit -am \"add $param-$i guest$j \"; 
					git push;"
		done

		ssh root@esx "mkdir -p /vmfs/volumes/datastore1/data/$EXP_DIR/$param-$i" 
		ssh root@esx "mv /vmfs/volumes/datastore1/log/* /vmfs/volumes/datastore1/data/$EXP_DIR/$param-$i/" | tee -a log/$LOG
	done
done
date | tee -a log/$LOG

