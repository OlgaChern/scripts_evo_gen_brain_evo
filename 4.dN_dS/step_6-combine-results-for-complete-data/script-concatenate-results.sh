#!/bin/bash


f_1st="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/4.dN_dS/results_first_half"
f_2nd="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/4.dN_dS/step_5-prepare-per-split-tables"
f_work="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/4.dN_dS/step_6-combine-results-for-complete-data"


for i in $f_1st/split-*
do
	#echo "$i"
	name="`echo "$i" | awk -F "split-" '{print "split-" $2}'`"
	cp $i $f_work/$name
	cat $f_2nd/$name >> $f_work/$name
	echo "$name"
done

for i in $f_1st/results-*
do
	#echo "$i"
	name="`echo "$i" | awk -F "results-dn-ds" '{print "results-dn-ds" $2}'`"
	cp $i $f_work/$name
        cat $f_2nd/$name >> $f_work/$name
	echo "$name"
done
