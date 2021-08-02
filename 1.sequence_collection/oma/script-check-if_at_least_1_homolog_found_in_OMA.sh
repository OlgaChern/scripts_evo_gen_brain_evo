#!/bin/bash

################################################################################################################################################
# ./script-check-if_at_least_1_homolog_found_in_OMA.sh > ../initial_lists/list-human-entrezGeneIDs-10077-new-check-homolog_availability
################################################################################################################################################


file_entrez_human_brain="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/1.sequence_collection/initial_lists/list-human-entrezGeneIDs-10077-new"
file_out="$file_entrez_human_brain-TABLE-entrez-enseml-oma"
file="$file_out-ALL-INFO-by-ENSEMBL_GENE" # list with ALL info


list="$file_entrez_human_brain-NF-OMAgrNA" # list entrez with OMAgrNA
grep "OMAgrNA" $file | awk -F "|" '{print $2}' | sort | uniq > $list



n=0
m="`wc -l $list | awk -F " " '{print $1}'`"

cat $list | while read -r line
do
	n=$[$n+1]
	c="`grep "|$line|" $file | sed "/OMAgrNA/d" | wc -l | awk -F " " '{print $1}'`"
	check="FAIL|NA"
	if [ $c -gt 0 ]
	then
		check="AVAILABLE|$c"
	else
		check="NOT_AVAILABLE|$c"
	fi
		echo "$n out of $m|$line|$check"
done
