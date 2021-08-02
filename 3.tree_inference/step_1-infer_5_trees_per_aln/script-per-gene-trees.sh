#!/bin/bash

iqtree_file="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/iqtree"
#=========================================================================
f_main="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180"
f_work="$f_main/3.tree_inference/step_1-infer_5_trees_per_aln"
f_aln="$f_main/2.alignments/aln-qual_30-final"
f_model="$f_main/2.alignments/model_selection-step_2/models-qual_30"
f_trees_out="$f_work/trees-qual_30/"
#=========================================================================
list="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/2.alignments/list-for_model_selection-without_ident-with_pair_ident" # if all the model runs finished 
#=========================================================================

n=0
cat $list | while read -r line
do
	aln="$f_aln/$line"
	n=$[$n+1]
	HUMAN="`echo $aln | awk -F "oma_orthologs" '{print $2}'|awk -F "-" '{print $4}'`"
	model="`grep "Best-fit model:" $f_model/$line.log | awk -F " " '{print $3}'`"

for NUM in {1..5}
do
	f="$f_trees_out/$line/r$NUM"
	mkdir -p $f
		
	file_out="$f/$line"
	echo "tree run $NUM: n$n $HUMAN: $line $model"
	submit2sge -N r$NUM-g$n-$HUMAN-tree -q desktops "$iqtree_file -s $aln -st CODON -m $model -pre $file_out -bb 1000"
done
#exit
done
