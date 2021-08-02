#!/bin/bash



for j in dN dS
do
	#==================================================================================
	# tree_1_HN: 9=HUMAN=HN, tree_1: 9=HUMAN, 10=NEA, 11=HN
	# after $8 add -5 two times (9 should become 11 for HN)
	tree=tree_1_HN
	file=summary_files-per_tree/$tree/$tree-${j}_max_llh
	results=results_1-${j}_max_llh-$tree.csv
	awk '$8 = $8 FS "-5"' $file | awk '$8 = $8 FS "-5"' | sed "s/ /,/g" > $results
	#==================================================================================
	# tree_4_HN: 9=HUMAN=HN, tree_4: 9=HUMAN, 10=NEA, 11=HN
	tree=tree_4_HN
	file=summary_files-per_tree/$tree/$tree-${j}_max_llh
	results=results_1-${j}_max_llh-$tree.csv
	awk '$8 = $8 FS "-5"' $file | awk '$8 = $8 FS "-5"' | sed "s/ /,/g" > $results
	#==================================================================================
	# tree_7_HN: 10=HUMAN=HN, tree_7: 10=HUMAN, 11=NEA, 12=HN
	tree=tree_7_HN
	file=summary_files-per_tree/$tree/$tree-${j}_max_llh
	results=results_1-${j}_max_llh-$tree.csv
	awk '$9 = $9 FS "-5"' $file | awk '$9 = $9 FS "-5"' | sed "s/ /,/g" > $results
	#==================================================================================
	# tree_8_PG: 6=PANTR=PG, tree_8: 6=GORGO, 7=PANTR, 8=PG
	tree=tree_8_PG
	file=summary_files-per_tree/$tree/$tree-${j}_max_llh
	results=results_1-${j}_max_llh-$tree.csv
	awk '$5 = $5 FS "-5"' $file | awk '$5 = $5 FS "-5"' | sed "s/ /,/g" > $results
	#==================================================================================
	tree=tree_8_ND
	file=summary_files-per_tree/$tree/$tree-${j}_max_llh
	results=results_1-${j}_max_llh-$tree.csv
	awk '$9 = $9 FS "-5"' $file | awk '$9 = $9 FS "-5"' | sed "s/ /,/g" > $results
	#==================================================================================


	for i in {1..9}
	do
		echo "modifying results for tree_${i}"
		cat summary_files-per_tree/tree_${i}/tree_${i}-${j}_max_llh| sed "s/ /,/g" > results_1-${j}_max_llh-tree_${i}.csv
	done

	all_trees="tree_1 tree_1_HN tree_2 tree_3 tree_4 tree_4_HN tree_5 tree_6 tree_7 tree_7_HN tree_8 tree_8_PG tree_8_ND tree_9"
	for t in $all_trees
	do
		awk -F "-" '{print $2,$3,$4}' summary_files-per_tree/$t/$t-aln | sed "s/ /,/g" > summary_files-per_tree/$t/$t-aln-info
		paste summary_files-per_tree/$t/$t-aln-info results_1-${j}_max_llh-$t.csv > results-${j}_max_llh-$t.csv
	done

	for i in 1 4 7 8
	do
		cp results-${j}_max_llh-tree_${i}.csv results-${j}_max_llh-tree_${i}-without-ident-pairs.csv
		if [ $i -eq 8 ]
		then
			echo "preparing results with ident pairs: tree_${i}_PG"
			cat results-${j}_max_llh-tree_${i}_PG.csv >> results-${j}_max_llh-tree_${i}.csv
			cat results-${j}_max_llh-tree_${i}_ND.csv >> results-${j}_max_llh-tree_${i}.csv
		else
			echo "preparing results with ident pairs: tree_${i}_HN"
			cat results-${j}_max_llh-tree_${i}_HN.csv >> results-${j}_max_llh-tree_${i}.csv
		fi
	done

done


#f_next="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/4.dN_dS/step_5-prepare-per-split-tables"
#cp results-*_max_llh-tree_{1..9}.csv $f_next

f_next="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/5.PREPARING_dN_dS_matrices/tables_for_all_6222_genes/part_2"
cp results-*_max_llh-tree_{1..9}.csv $f_next

mkdir results_tables_dN_and_dS
mv results_1-d* results_tables_dN_and_dS
mv results-d* results_tables_dN_and_dS
