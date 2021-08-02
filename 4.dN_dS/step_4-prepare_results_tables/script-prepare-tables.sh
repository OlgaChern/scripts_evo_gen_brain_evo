#!/bin/bash

f="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/4.dN_dS/step_2-filtering_unstable/summary_files-per_tree"
#f_work="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/4.dN_dS/step_3-dN_dS-filtering-summary_per_branch"


# tree_1_HN: 9=HUMAN=HN, tree_1: 9=HUMAN, 10=NEA, 11=HN
# after $8 add -5 two times (9 should become 11 for HN)
#awk '$8 = $8 FS "-5"' summary_files-per_tree/tree_1_HN/tree_1_HN-masked-un+e_short | awk '$8 = $8 FS "-5"' | sed "s/ /,/g" > results_1-dn-ds-filtered-tree_1_HN.csv
file="$f/tree_1_HN/tree_1_HN-masked-un+e_short"
awk '$8 = $8 FS "-5"' $file | awk '$8 = $8 FS "-5"' | sed "s/ /,/g" > results_1-dn-ds-filtered-tree_1_HN.csv

# tree_4_HN: 9=HUMAN=HN, tree_4: 9=HUMAN, 10=NEA, 11=HN
#awk '$8 = $8 FS "-5"' summary_files-per_tree/tree_4_HN/tree_4_HN-masked-un+e_short | awk '$8 = $8 FS "-5"' | sed "s/ /,/g" > results_1-dn-ds-filtered-tree_4_HN.csv
file="$f/tree_4_HN/tree_4_HN-masked-un+e_short"
awk '$8 = $8 FS "-5"' $file | awk '$8 = $8 FS "-5"' | sed "s/ /,/g" > results_1-dn-ds-filtered-tree_4_HN.csv

# tree_7_HN: 10=HUMAN=HN, tree_7: 10=HUMAN, 11=NEA, 12=HN
#awk '$9 = $9 FS "-5"' summary_files-per_tree/tree_7_HN/tree_7_HN-masked-un+e_short | awk '$9 = $9 FS "-5"' | sed "s/ /,/g" > results_1-dn-ds-filtered-tree_7_HN.csv
file="$f/tree_7_HN/tree_7_HN-masked-un+e_short"
awk '$9 = $9 FS "-5"' $file | awk '$9 = $9 FS "-5"' | sed "s/ /,/g" > results_1-dn-ds-filtered-tree_7_HN.csv


# tree_8_PG: 6=PANTR=PG, tree_8: 6=GORGO, 7=PANTR, 8=PG
#awk '$5 = $5 FS "-5"' summary_files-per_tree/tree_8_PG/tree_8_PG-masked-un+e_short | awk '$5 = $5 FS "-5"' | sed "s/ /,/g" > results_1-dn-ds-filtered-tree_8_PG.csv
file="$f/tree_8_PG/tree_8_PG-masked-un+e_short"
awk '$5 = $5 FS "-5"' $file | awk '$5 = $5 FS "-5"' | sed "s/ /,/g" > results_1-dn-ds-filtered-tree_8_PG.csv

# HERE ADD minus DENISOVAN ND!!!!!!!!!!!
# tree_8_ND: 10 NEANDERTHAL 0 -> 12 ND 1
# should be:
# 10 DENISOVAN 0
# 11 NEANDERTHAL 0
# 12 ND 1
file="$f/tree_8_ND/tree_8_ND-masked-un+e_short"
awk '$9 = $9 FS "-5"' $file | awk '$9 = $9 FS "-5"' | sed "s/ /,/g" > results_1-dn-ds-filtered-tree_8_ND.csv


for i in {1..9}
do
	echo "modifying results for tree_${i}"
	cat $f/tree_${i}/tree_${i}-masked-un+e_short | sed "s/ /,/g" > results_1-dn-ds-filtered-tree_${i}.csv
done



all_trees="tree_1  tree_1_HN  tree_2  tree_3  tree_4  tree_4_HN  tree_5  tree_6  tree_7  tree_7_HN  tree_8 tree_8_PG tree_8_ND tree_9"
for t in $all_trees
do
	awk -F "-" '{print $2,$3,$4}' $f/$t/$t-aln | sed "s/ /,/g" > $f/$t/$t-aln-info
	paste $f/$t/$t-aln-info results_1-dn-ds-filtered-$t.csv > results-dn-ds-filtered-$t.csv
	sed -i 's/\t/,/g' results-dn-ds-filtered-$t.csv
done




for i in 1 4 7 8
do
	cp results-dn-ds-filtered-tree_${i}.csv results-dn-ds-filtered-tree_${i}-without-ident-pairs.csv
	if [ $i -eq 8 ]
	then
		echo "preparing results with ident pairs: tree_${i}_PG"
		cat results-dn-ds-filtered-tree_${i}_PG.csv >> results-dn-ds-filtered-tree_${i}.csv
		cat results-dn-ds-filtered-tree_${i}_ND.csv >> results-dn-ds-filtered-tree_${i}.csv
	else
		echo "preparing results with ident pairs: tree_${i}_HN"
		cat results-dn-ds-filtered-tree_${i}_HN.csv >> results-dn-ds-filtered-tree_${i}.csv
	fi
done

f_next="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/4.dN_dS/step_5-prepare-per-split-tables"
cp results-dn-ds-filtered-tree_{1..9}.csv $f_next
