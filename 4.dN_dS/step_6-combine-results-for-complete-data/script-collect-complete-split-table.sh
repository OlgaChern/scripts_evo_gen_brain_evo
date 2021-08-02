#!/bin/bash



list_trees_res="results-dn-ds-filtered-tree_1.csv results-dn-ds-filtered-tree_2.csv results-dn-ds-filtered-tree_3.csv results-dn-ds-filtered-tree_4.csv results-dn-ds-filtered-tree_5.csv results-dn-ds-filtered-tree_6.csv results-dn-ds-filtered-tree_7.csv results-dn-ds-filtered-tree_8.csv results-dn-ds-filtered-tree_9.csv"
list_splits_res="split-MOUSE.csv split-OTOGA.csv split-CALJA.csv split-MACMU.csv split-NOMLE.csv split-GORGO.csv split-PANTR.csv split-DEN.csv split-NEA.csv split-HUMAN.csv split-MO_CMNGPDNH.csv split-MOC_MNGPDNH.csv split-MOCM_NGPDNH.csv split-MOCMN_GPDNH.csv split-MOCMNG_HNDP.csv split-MOCMNP_HNDG.csv split-MOCMNDHN_PG.csv split-MOCMNGP_HND.csv split-MOCMNGPD_HN.csv split-MOCMNGPH_ND.csv split-MOCMNGPN_HD.csv"




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
			check="`cat $split | awk -F "=" '{print "," $1}' | grep ",$entrez," | wc -l | awk -F " " '{print $1}'`"
			if [ $check -ge 1 ]
			then
				result="`cat $split | awk -F "=" '{print "," $1}' | grep ",$entrez," |awk -F "," '{print $3}'`"
			fi
			results_all=(${results_all[*]} $result)
		done

		results_print="`echo "${results_all[*]}" | sed "s/ /,/g"`"
		echo "tree$tree_NUM,$entrez,$ensembl,$oma,$results_print"
		#exit
	done
done
