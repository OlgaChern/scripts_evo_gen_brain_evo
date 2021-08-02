#!/bin/bash

for d in dN dS
do

list_trees_res="results-${d}_max_llh-tree_1.csv results-${d}_max_llh-tree_2.csv results-${d}_max_llh-tree_3.csv results-${d}_max_llh-tree_4.csv results-${d}_max_llh-tree_5.csv results-${d}_max_llh-tree_6.csv results-${d}_max_llh-tree_7.csv results-${d}_max_llh-tree_8.csv results-${d}_max_llh-tree_9.csv"
list_splits_res="split-${d}-MOUSE.csv split-${d}-OTOGA.csv split-${d}-CALJA.csv split-${d}-MACMU.csv split-${d}-NOMLE.csv split-${d}-GORGO.csv split-${d}-PANTR.csv split-${d}-DEN.csv split-${d}-NEA.csv split-${d}-HUMAN.csv split-${d}-MO_CMNGPDNH.csv split-${d}-MOC_MNGPDNH.csv split-${d}-MOCM_NGPDNH.csv split-${d}-MOCMN_GPDNH.csv split-${d}-MOCMNG_HNDP.csv split-${d}-MOCMNP_HNDG.csv split-${d}-MOCMNDHN_PG.csv split-${d}-MOCMNGP_HND.csv split-${d}-MOCMNGPD_HN.csv split-${d}-MOCMNGPH_ND.csv split-${d}-MOCMNGPN_HD.csv"

file_results="results-split-table-from-9-trees-${d}.csv"
if [ -e $file_results ]
then
	rm $file_results
fi


for tree in $list_trees_res
do
	tree_NUM="`echo "$tree" | awk -F "tree" '{print $2}' | sed "s/\.csv//g"`"
	cat $tree | while read -r line
	do
		entrez="`echo "$line" | awk -F "," '{print $1}'`"
		ensembl="`echo "$line" | awk -F "," '{print $2}'`"
		oma="`echo "$line" | awk -F "," '{print $3}'`"


		results_all=()
		for split in $list_splits_res
		do
			#echo "checking split: $split"
			result="-6"
			# I use = as separator, coz I want the full line to be $1
			check="`cat $split | awk -F "=" '{print "," $1}' | grep ",$entrez," | wc -l | awk -F " " '{print $1}'`"
			if [ $check -ge 1 ]
			then
				result="`cat $split | awk -F "=" '{print "," $1}' | grep ",$entrez," |awk -F "," '{print $3}'`"
			fi
			results_all=(${results_all[*]} $result)

			#echo "checking split: $split: $result : ${results_all[*]}"
		done

		results_print="`echo "${results_all[*]}" | sed "s/ /,/g"`"
		echo "tree$tree_NUM,$entrez,$ensembl,$oma,$results_print" >> $file_results
		echo "$d|tree$tree_NUM|$entrez,$ensembl,$oma"
		#exit
	done
done

done
