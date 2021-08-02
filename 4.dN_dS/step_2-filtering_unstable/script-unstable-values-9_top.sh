#!/bin/bash
f="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/4.dN_dS/step_1-compute_dn_ds"
f_work="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/4.dN_dS/step_2-filtering_unstable"

list="$f/list-dn_ds-with-topology-info"
collect_data="YES"

if [ $collect_data == "YES" ]
then
if [ -e $list-results-info ] 
then
	rm $list-results-info
fi
fi

rm -r summary_files-per_tree/*

n=0
cat $list | while read -r line
do
	n=$[$n+1]

	aln="`echo "$line" | awk -F " " '{print $1}'`"
	tree_file="`echo "$line" | awk -F " " '{print $2}'`"
	tree="`echo "$line" | awk -F " " '{print $3}'`"
	ident="`echo "$line" | grep "minus" | wc -l | awk -F " " '{print $1}'`"

	ident_tree="NA"
	ident_pair="NA"
	tree_out="$tree"
	if [ $ident -eq 1 ]
	then
		ident_tree="`echo "$tree_file" | awk -F "/" '{print $10}'`"
		ident_pair="`echo "$ident_tree" | awk -F "_" '{print $3}'`"
		tree_out="$ident_tree"
	fi

	echo "gene $n: $aln"
	results_file="$f_work/summary_files/$aln/"
	mkdir -p $results_file

	# Collect from all runs
	file_out="$results_file/summary"
	edges="$file_out-edges"
	omega="$file_out-omega"
	llh="$file_out-llh"


	if [ $collect_data == "YES" ]
	then
		results_dn_ds="$f/RESULTS/${tree}_*/$aln/out"

		if [ -e $edges ]
		then
			edges_new="NO"
			echo "file: edges exists | $edges"
		else
			edges_new="YES"
			cat $results_dn_ds | grep -A 4 "tree length = " | grep "MOUSE" | sed "s/(//g" | sed "s/)//g" | sed "s/://g"| sed "s/,/ /g" | sed "s/;//g" | sed "s/MOUSE //g" | sed "s/OTOGA //g" | sed "s/CALJA //g" | sed "s/MACMU //g" | sed "s/NOMLE //g" | sed "s/HUMAN //g" | sed "s/PANTR //g" > $edges
		fi

		if [ -e $omega ]
                then
			omega_new="NO"
                        echo "file: omega exists | $omega"
                else
			omega_new="YES"
			cat $results_dn_ds | grep -A 1 "w ratios as labels for TreeView:" | grep "MOUSE" | sed "s/(//g" | sed "s/)//g" | sed "s/  / /g" | sed "s/ , / /g" | sed "s/ ;//g" | sed "s/#//g" |sed "s/MOUSE //g" | sed "s/OTOGA //g" | sed "s/CALJA //g" | sed "s/MACMU //g" | sed "s/NOMLE //g" | sed "s/HUMAN //g" | sed "s/PANTR //g"> $omega
		fi

		if [ -e $llh ]
                then
                        echo "file: llh exists | $llh"
                else
			cat $results_dn_ds | grep "lnL(ntime:" | awk -F " " '{print $5}' > $llh
		fi

		# Refine accordingly
		if [ $edges_new == "YES" ] && [ $omega_new == "YES" ]
		then
		if [ $ident -ne 1 ]
		then
			sed -i "s/NEANDERTHAL //g" $edges
			sed -i "s/GORGO //g" $edges
			sed -i "s/DENISOVAN //g" $edges


			sed -i "s/NEANDERTHAL //g" $omega
                	sed -i "s/GORGO //g" $omega
			sed -i "s/DENISOVAN //g" $omega

		elif [ $ident_pair == "HN" ]
		then
			sed -i "s/GORGO //g" $edges
			sed -i "s/GORGO //g" $omega
			sed -i "s/DENISOVAN //g" $edges
			sed -i "s/DENISOVAN //g" $omega

		elif [ $ident_pair == "PG" ]
		then
			sed -i "s/NEANDERTHAL //g" $edges
			sed -i "s/NEANDERTHAL //g" $omega
			sed -i "s/DENISOVAN //g" $edges
                        sed -i "s/DENISOVAN //g" $omega

		elif [ $ident_pair == "ND" ]
                then
                        sed -i "s/GORGO //g" $edges
                        sed -i "s/GORGO //g" $omega

			sed -i "s/NEANDERTHAL //g" $edges
			sed -i "s/NEANDERTHAL //g" $omega
		else
			echo "ERROR: ident and ident_pair? : $aln : $ident : $ident_pair"
		fi
		elif [ $edges_new == "NO" ] && [ $omega_new == "NO" ]
		then
			echo "both files exist, no need to refine | edges: $edges_new | omega: $omega_new"
		else
			echo "POTENTIAL ERROR: only one out of two files exists | edges: $edges_new | omega: $omega_new"
		fi

	fi

	# check
	e_num="`wc -l $edges | awk -F " " '{print $1}'`"
	w_num="`wc -l $omega | awk -F " " '{print $1}'`"
	llh_num="`wc -l $llh | awk -F " " '{print $1}'`"

	if [ $collect_data == "YES" ]
	then
		echo "check_5_runs|$aln|$e_num|$w_num|$llh_num|" >> $list-results-info
	fi
	plot_file="$results_file/$aln"
	joint_results="$f_work/summary_files-per_tree/$tree_out/$tree_out"
        mkdir -p $f_work/summary_files-per_tree/$tree_out
	Rscript --vanilla script-unstable-values-9_top.r $aln $edges $omega $llh $tree $plot_file ${ident_tree} $ident_pair $joint_results
	echo "$aln" >> $f_work/summary_files-per_tree/$tree_out/$tree_out-aln
#exit
done


