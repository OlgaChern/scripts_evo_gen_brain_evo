#!/bin/bash

all_trees="tree_1  tree_1_HN  tree_2  tree_3  tree_4  tree_4_HN  tree_5  tree_6  tree_7  tree_7_HN  tree_8 tree_8_ND tree_8_PG tree_9"
#all_trees="tree_2"
for tree in $all_trees
do
branch_id="/project/olga-phylo/brain-evo/data/final-analysis/tree_topologies/branch_correspondence/branch_id-$tree"
file="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/4.dN_dS/step_2-filtering_unstable/summary_files-per_tree/$tree/$tree"


file_out_results="$tree-results-aln_filtered_dN_dS"
paste $file-aln $file-masked-un+e_short > $file_out_results

mkdir -p plots_per_branch/$tree
file_out="plots_per_branch/$tree/$tree"

cat $branch_id | while read -r line
do
	b="`echo "$line" | awk -F " " '{print $1}'`"
	b_name="`echo "$line" | awk -F " " '{print $2}'`" 
	cat $file_out_results | awk -v b=$[b+1] -F " " '{print $1,$b}' | sort -k2 -n > $file-selection-$b-$b_name
done

#cat $file-w_percent | xargs -n 1 > $file-w_percent-mod

script_r="script-plot-branch-selection.r"
Rscript --vanilla $script_r $branch_id $file-e_max_llh  $file-masked-un  $file-masked-un+e_short  $file-split-of-values  $file-w_max_llh  $file-w_percent $tree

mv $file*selection* plots_per_branch/$tree/.
mv $file*Reliability* plots_per_branch/$tree/.
done


