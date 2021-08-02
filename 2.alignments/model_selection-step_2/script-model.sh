#!/bin/bash

iqtree_file="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/iqtree"
f_aln="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/2.alignments/aln-qual_30-final" # in this folder there are also aln with 1 pair of identical sequences that do not fit on any of the 9 trees, therefore, do not use the ls $f_aln to collect all genes for tree inference
f_work="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/2.alignments/model_selection-step_2"


#list="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/2.alignments/list-aln-final-after-check_ident"
#ls $f_aln > $list

list="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/2.alignments/list-for_model_selection-without_ident-with_pair_ident"


n=0
cat $list | while read -r line
do
	echo "$n submitting for model computations $line"
	n=$[$n+1]
	HUMAN="`echo "$line" | awk -F "-" '{print $4}'`"
	file="$f_aln/$line"
	file_out="$f_work/models-qual_30/$line"
	#rm $f_work/models-qual_30/${line}.*
	submit2sge -N g$n-m-$HUMAN -q desktops "$iqtree_file -s $file -st CODON -m TESTONLY -pre $file_out -redo"
	#$iqtree_file -s $file -st CODON -m TESTONLY -pre $file_out -redo
done
