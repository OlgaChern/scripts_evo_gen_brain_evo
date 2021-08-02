#/bin/bash
#==================================================================================================
iqtree="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/iqtree"
#==================================================================================================
f_main="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180"
f_work="$f_main/3.tree_inference/step_1-infer_5_trees_per_aln"
f_tree_qual_30="$f_work/trees-qual_30/"
f_work_2="$f_main/3.tree_inference/step_2-check_if_one_of_9"

f_top_trees="/project/olga-phylo/brain-evo/data/final-analysis/tree_inference"
#==================================================================================================
all_ident_seq_info="$f_main/2.alignments/check_identical-step_1/list-aln-with-identical-seq-1_pair-2227" # only pairs
#==================================================================================================
list_name="list-for_model_selection-without_ident-with_pair_ident"
list_1="$f_main/2.alignments/$list_name"
list="$f_work_2/$list_name"
cp $list_1 $list


#for list in $list_all
#do
#check_ident="NO_IDENT"
#check_list="`echo "$list" | grep "with-identical" | wc -l | awk -F " " '{print $1}'`"
#if [ $check_list -eq 1 ]
#then
#	echo "PERFORMING ANALYSIS for alignments WITH IDENTICAL sequences: $list"
#	check_ident="IDENT_PAIR"
#else
#	echo "PERFORMING ANALYSIS for alignments WITHOUT IDENTICAL sequences: $list"
#fi


f_info="$list-info-topologies" # output file

if [ -e $f_info-ML_tree_check ]
then
	rm $f_info-ML_tree_check
fi

if [ -e $f_info-1_PAIR-ignored ]
then
	rm $f_info-1_PAIR-ignored
fi


if [ -e $f_info-dn_ds_list ]
then
	rm $f_info-dn_ds_list
fi


n=0
NUM=5
cat $list | while read -r line
do
	n=$[$n+1]
	f="$f_work_2/analysis-rfdist/$line"
	mkdir -p $f
	
	#if [ "`ls $f | wc -l | awk -F " " '{print $1}'`" -gt 0 ]
	#then
	#	echo "$line: Not empty: remove old files from directory"
	#	rm $f/*
	#else
	#	echo "$line: Empty. Proceed with analysis"
	#fi
	

# CHECK if all gene tree runs are finished and successful==========================================================================================
	file_trees="$f/trees-all"
	check="`cat $f_tree_qual_30/${line}/r*/${line}.log | grep "Analysis results written to:" | wc -l | awk -F " " '{print $1}'`"
	if [ $check -eq $NUM ]
	then
		echo "INFO: all $NUM trees are available: $line" 
		max_llh="`grep "BEST SCORE" $f_tree_qual_30/${line}/r*/*.log | awk -F " : " '{print $2}' | sort -n | tail -n 1`"
        	run_max_llh="`grep "BEST SCORE" $f_tree_qual_30/${line}/r*/*.log | grep "\ $max_llh" | head -n 1 | awk -F "${line}/" '{print $2}' | awk -F "/" '{print $1}'| sed "s/r//g"`"
		ml_tree="$f_tree_qual_30/${line}/r$run_max_llh/${line}.treefile"
		t="$ml_tree"

		tree_dn_ds_full=""
		tree_dn_ds_short=""

		dn_ds="NO"
# Check if there are ident sequences-------------------------------------
		ident_PAIR="NO_IDENT"
		check_ident="`grep "$line" $all_ident_seq_info | wc -l | awk -F " " '{print $1}'`"
		if [ $check_ident -gt 0 ]
		then
			file_trees="$f/trees-1+3"
			ident_PAIR="`grep "${line}" $all_ident_seq_info | awk -F "|" '{print $2}'`"
			if [ "$ident_PAIR" == "HUMAN NEANDERTHAL" ]
			then
				$iqtree -rf $t $f_top_trees/t3_HN_trees -pre $file_trees -quiet
				check="`grep "Tree" $file_trees.rfdist | grep " 0"| wc -l | awk -F " " '{print $1}'`"
					if [ $check -eq 1 ]
					then
						top="`grep "Tree" $file_trees.rfdist | grep " 0"| awk -F " " '{print $1}' | sed "s/Tree//g"`"
						if [ $top -eq 0 ]
						then
                                			top=1
						elif [ $top -eq 1 ]
						then
							top=4
						elif [ $top -eq 2 ]
                                        	then
                                                	top=7
						fi
						if_one_of_3_or_9_trees="one_of_3_YES"
						dn_ds="YES"
						tree_dn_ds_full="/project/olga-phylo/brain-evo/data/final-analysis/tree_topologies/9_species/minus_NEANDERTHAL/tree_${top}_HN"
                                                tree_dn_ds_short="tree_$top"
                        		else
						dn_ds="NO"
						if_one_of_3_or_9_trees="one_of_3_NO"
                        		fi
			elif [ "$ident_PAIR" == "GORGO PANTR" ]
			then
                       		$iqtree -rf $t $f_top_trees/t3_PG_trees -pre $file_trees -quiet
                       		check="`grep "Tree" $file_trees.rfdist | grep " 0"| wc -l | awk -F " " '{print $1}'`"
                                	if [ $check -eq 1 ]
                                	then
                                        	top="`grep "Tree" $file_trees.rfdist | grep " 0"| awk -F " " '{print $1}' | sed "s/Tree//g"`"
                                        	top=$[$top+7] 
						if_one_of_3_or_9_trees="one_of_3_YES"
						dn_ds="YES"
                                        	tree_dn_ds_full="/project/olga-phylo/brain-evo/data/final-analysis/tree_topologies/9_species/minus_GORGO/tree_${top}_PG"
                                        	tree_dn_ds_short="tree_$top"

                                	else
						dn_ds="NO"
						top="NA"
						if_one_of_3_or_9_trees="one_of_3_NO"
                                	fi
			elif [ "$ident_PAIR" == "DENISOVAN NEANDERTHAL" ]
			then
				$iqtree -rf $t $f_top_trees/t3_ND_trees -pre $file_trees -quiet
                                check="`grep "Tree" $file_trees.rfdist | grep " 0"| wc -l | awk -F " " '{print $1}'`"
				if [ $check -eq 1 ]
                                then
                                	top="`grep "Tree" $file_trees.rfdist | grep " 0"| awk -F " " '{print $1}' | sed "s/Tree//g"`"
                                        if [ $top -eq 0 ]
                                        then
                                        	top=2
                                        elif [ $top -eq 1 ]
                                        then
                                        	top=5
                                        elif [ $top -eq 2 ]
                                        then
                                                top=8
                                        fi
                                       	if_one_of_3_or_9_trees="one_of_3_YES"
                                        dn_ds="YES"
                                        tree_dn_ds_full="/project/olga-phylo/brain-evo/data/final-analysis/tree_topologies/9_species/minus_DENISOVAN/tree_${top}_ND"
                                        tree_dn_ds_short="tree_$top"
                                else
                                        dn_ds="NO"
                                        if_one_of_3_or_9_trees="one_of_3_NO"
				fi	
		
			else
				echo "$line|1_pair_ident|$ident_PAIR|ignored" >> $f_info-1_PAIR-ignored
			fi

	else
	# For alignments without identical sequences --------------------------------------------------------
		file_trees="$f/trees-1+9"
		$iqtree -rf $t $f_top_trees/t9_trees -pre $file_trees -quiet
		check="`grep "Tree" $file_trees.rfdist | grep " 0"| wc -l | awk -F " " '{print $1}'`"
				if [ $check -eq 1 ]
				then
					top="`grep "Tree" $file_trees.rfdist | grep " 0"| awk -F " " '{print $1}' | sed "s/Tree//g"`"
					top=$[$top+1]
					if_one_of_3_or_9_trees="one_of_9_YES"
					dn_ds="YES"
					tree_dn_ds_full="/project/olga-phylo/brain-evo/data/final-analysis/tree_topologies/10_species/tree_$top"
					tree_dn_ds_short="tree_$top"
				else
					dn_ds="NO"
					top="NA"
					if_one_of_3_or_9_trees="one_of_9_NO"
				fi
			# --------------------------------------------------------------------------------------------------
	fi

	echo "$line|$all_gene_trees_are_ident|$if_one_of_3_or_9_trees|$top|$ident_PAIR|$max_llh|$run_max_llh" >> $f_info-ML_tree_check
	

# prepare file for dn_ds analysis
	if [ $dn_ds == "YES" ]
	then
		echo "$line $tree_dn_ds_full $tree_dn_ds_short" >> $f_info-dn_ds_list
	fi


# CHECK if there are identical sequences *********************************************************************************************************


		# Check if there are short edges, if HND is monophyletic, if HNDPG is monophyletic
		#t_run=0
		#while [ $t_run -lt $NUM ]
		#do
		#	t_run=$[$t_run+1]
		#	t="$f_tree_qual_30/${line}/r$t_run/${line}.treefile"
		#	clade_out="$f/clades_r$t_run"
		#	clade_analysis="$f/clades_info_all_runs"
		#	script_r="/project/olga-phylo/brain-evo/data/final-analysis/tree_inference/script-branch-clade-analysis.r"
		#	Rscript --vanilla $script_r $t $clade_out $clade_analysis
		#done

		#HUMAN="`echo "$line" | awk -F "-" '{print $4}'`"
		#submit2sge -N clade$n-$HUMAN -q compute "/project/olga-phylo/brain-evo/data/final-analysis/tree_inference/script-analyse-trees-per-gene.sh $line"
	else
		echo "ERROR: not all $NUM are there: $line"
	fi
# CHECK if all gene tree runs are finished and successful==========================================================================================
#exit

done
