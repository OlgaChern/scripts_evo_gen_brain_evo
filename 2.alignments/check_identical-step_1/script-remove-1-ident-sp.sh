#!/bin/bash

sp_rm=">$1"
file_in="$2"
file_out="$3"

first="`grep ">" $file_in | head -n 1`"
last="`grep ">" $file_in | tail -n 1`"
	
if [ $last == $sp_rm ]
then
	echo "$sp_rm is LAST"
	sed -n -e "/$first/,/$sp_rm/ p" $file_in | sed -e '$d' > $file_out
elif [ $last != $sp_rm ]
then
	echo "$sp_rm is NOT LAST"
	n_del="`sed -n -e "/$sp_rm/,/>/ p" $file_in | sed -e '$d' | sed "/$sp_rm/d" | wc -l | awk -F " " '{print $1}'`"
	sed "/$sp_rm/,+${n_del}d" $file_in > $file_out
fi
