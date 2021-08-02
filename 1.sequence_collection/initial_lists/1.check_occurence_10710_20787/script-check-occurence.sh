#!/bin/bash

list_1="list-human-entrezGeneIDs-10710-sort"
list_2="list-entrez-29180"

out_F="${list_1}-F"
out_NF="${list_1}-NF"

awk -F " " '{print "=" $1 "="}' $list_2 > ${list_2}-mod


n=0
cat $list_1 | while read -r line
do
	n=$[$n+1]
	c="`grep "=$line=" ${list_2}-mod | wc -l | awk -F " " '{print $1}'`"
	if [ $c -eq 0 ]
	then
		echo "entrez $n: NF: $line"
		echo "$line" >> $out_NF
	else
		echo "entrez $n"
		echo "$line" >> $out_F
	fi
done
