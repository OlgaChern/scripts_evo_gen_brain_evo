#!/bin/bash

f="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/4.dN_dS/step_1-compute_dn_ds"
f_work="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/4.dN_dS/step_2-filtering_unstable"

list="$f/list-dn_ds-with-topology-info"




collect_data="NO"


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

	# already collected
        #edges="$file_out-edges"
        #omega="$file_out-omega"
        llh="$file_out-llh"

	dN_file="$file_out-dN"
	dS_file="$file_out-dS"


        if [ $collect_data == "YES" ]
        then
                results_dn_ds="$f/RESULTS/${tree}_*/$aln/out"

		query="dN tree:"
                if [ -e $dN_file ]
                then
                        #echo "file: dN_file exists | $dN_file"
			rm $dN_file
			cat $results_dn_ds | grep -A 1 "$query" | grep "MOUSE" | sed "s/(//g" | sed "s/)//g" | sed "s/://g"| sed "s/,/ /g" | sed "s/;//g" | sed "s/MOUSE //g" | sed "s/OTOGA //g" | sed "s/CALJA //g" | sed "s/MACMU //g" | sed "s/NOMLE //g" | sed "s/HUMAN //g" | sed "s/PANTR //g" > $dN_file

                else
                        cat $results_dn_ds | grep -A 1 "$query" | grep "MOUSE" | sed "s/(//g" | sed "s/)//g" | sed "s/://g"| sed "s/,/ /g" | sed "s/;//g" | sed "s/MOUSE //g" | sed "s/OTOGA //g" | sed "s/CALJA //g" | sed "s/MACMU //g" | sed "s/NOMLE //g" | sed "s/HUMAN //g" | sed "s/PANTR //g" > $dN_file
                fi

		query="dS tree:"
		if [ -e $dS_file ]
                then
                        #echo "file: dS_file exists | $dS_file"
			rm $dS_file
			cat $results_dn_ds | grep -A 1 "$query" | grep "MOUSE" | sed "s/(//g" | sed "s/)//g" | sed "s/://g"| sed "s/,/ /g" | sed "s/;//g" | sed "s/MOUSE //g" | sed "s/OTOGA //g" | sed "s/CALJA //g" | sed "s/MACMU //g" | sed "s/NOMLE //g" | sed "s/HUMAN //g" | sed "s/PANTR //g" > $dS_file
                else
                        cat $results_dn_ds | grep -A 1 "$query" | grep "MOUSE" | sed "s/(//g" | sed "s/)//g" | sed "s/://g"| sed "s/,/ /g" | sed "s/;//g" | sed "s/MOUSE //g" | sed "s/OTOGA //g" | sed "s/CALJA //g" | sed "s/MACMU //g" | sed "s/NOMLE //g" | sed "s/HUMAN //g" | sed "s/PANTR //g" > $dS_file
                fi

		# lazy fix
		edges="$dN_file"
                omega="$dS_file"

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

	fi

	# Write dN dS for the run with max llh
	joint_results="$f_work/summary_files-per_tree/$tree_out/$tree_out"
        mkdir -p $f_work/summary_files-per_tree/$tree_out
        Rscript --vanilla script-COLLECT-dN_dS-max_llh.r $dN_file $dS_file $llh $joint_results	
#exit
done
