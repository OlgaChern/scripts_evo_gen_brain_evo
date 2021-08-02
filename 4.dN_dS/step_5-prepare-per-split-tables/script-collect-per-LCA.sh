
for i in 1 2 3 4 5 14 15 16 17 
do
	for t in {1..9}
	do
		f="results-dn-ds-filtered-tree_$t.csv"
		out_f="per_LCA/LCA_$i/LCA-$i-tree_$t"
		mkdir -p per_LCA/LCA_$i
		cat $f | awk -v b=$[i+3] -F "," '{print $1,$b}' > $out_f
	done

	cat per_LCA/LCA_$i/* >> LCA-$i-all-trees
done 




LCA_GORGO=(6 6 6 7 7 7 6 6 6)
LCA_PANTR=(7 7 7 6 6 6 7 7 7)
LCA_HUMAN=(9 8 9 9 8 9 10 9 10)
LCA_NEA=(10 10 8 10 10 8 11 11 9)
LCA_DEN=(8 9 10 8 9 10 9 10 11)

LCA_PG=(0 0 0 0 0 0 8 8 8) # split of PG cherry
LCA_HNDP=(13 13 13 0 0 0 0 0 0) # HNDP from the rest
LCA_HNDG=(0 0 0 13 13 13 0 0 0) # HNDG from the rest
LCA_HND=(12 12 12 12 12 12 13 13 13)

LCA_HN=(11 0 0 11 0 0 12 0 0)
LCA_ND=(0 11 0 0 11 0 0 12 0)
LCA_HD=(0 0 11 0 0 11 0 0 12)



LCA_list="LCA_GORGO LCA_PANTR LCA_HUMAN LCA_NEA LCA_DEN LCA_PG LCA_HNDP LCA_HNDG LCA_HN LCA_ND LCA_HD LCA_HND"



# function to get the per split dn_ds collected in one file
collect_dn_ds_per_LCA(){
LCA=($1)
LCA_name=$2
for t in {0..8}
do
	i=${LCA[$t]}
#echo "$t - $i"
    j=$[$t+1]

    if [ $i -ne 0 ]
    then
        echo "corresponding LCA_$LCA_name in tree_$j : associated column $i"
        f="results-dn-ds-filtered-tree_$j.csv"
        out_f="per_LCA/LCA_${LCA_name}/LCA-$LCA_name-tree_$j"
    #rm -r per_LCA/LCA_${LCA_name}
        mkdir -p per_LCA/LCA_${LCA_name}
        cat $f | awk -v b=$[i+3] -F "," '{print $1,$b}' > $out_f
#    else
#echo "NO corresponding LCA_$LCA_name in tree_$j : associated column $i"
    fi
done

cat per_LCA/LCA_$LCA_name/* >> LCA-$LCA_name-all-trees
}


# calling the function for each specific split
collect_dn_ds_per_LCA "${LCA_GORGO[*]}" "GORGO"
collect_dn_ds_per_LCA "${LCA_PANTR[*]}" "PANTR"
collect_dn_ds_per_LCA "${LCA_HUMAN[*]}" "HUMAN"
collect_dn_ds_per_LCA "${LCA_NEA[*]}" "NEA"
collect_dn_ds_per_LCA "${LCA_DEN[*]}" "DEN"

collect_dn_ds_per_LCA "${LCA_PG[*]}" "PG"
collect_dn_ds_per_LCA "${LCA_HNDP[*]}" "HNDP"
collect_dn_ds_per_LCA "${LCA_HNDG[*]}" "HNDG"

collect_dn_ds_per_LCA "${LCA_HN[*]}" "HN"
collect_dn_ds_per_LCA "${LCA_ND[*]}" "ND"
collect_dn_ds_per_LCA "${LCA_HD[*]}" "HD"

collect_dn_ds_per_LCA "${LCA_HND[*]}" "HND"




sanity_check (){
    LCA=($1)
    LCA_name=$2
    for t in {0..8}
    do
        i=${LCA[$t]}
        #echo "$t - $i"
        j=$[$t+1]

        if [ $i -ne 0 ]
        then
            f="results-dn-ds-filtered-tree_$j.csv"
            out_f="per_LCA/LCA_${LCA_name}/LCA-$LCA_name-tree_$j"

            gene="`head -n 10 $out_f | tail -n 1 | awk -F " " '{print $1}'`"
            dn_ds="`head -n 10 $out_f | tail -n 1 | awk -F " " '{print $2}'`"

#dn_ds_main="`grep '${gene},' $f | awk -v b=$i -F ',' '{print $b}'`"

gene_main="`head -n 10 $f | tail -n 1 | awk -F ',' '{print $1}'`"
dn_ds_main="`head -n 10 $f | tail -n 1 | awk -v b=$[$i+3] -F ',' '{print $b}'`"


            echo $gene
            echo $gene_main
            echo $dn_ds
            echo ${dn_ds_main}



        if [ ${dn_ds} == ${dn_ds_main} ]
            then
                echo "tree_$j $gene $gene_main $dn_ds $dn_ds_main: YES"
echo $gene
echo $gene_main
echo $dn_ds
echo ${dn_ds_main}
            else
                echo "tree_$j $gene $gene_main $dn_ds $dn_ds_main: NO"
echo $gene
echo $gene_main
echo $dn_ds
echo ${dn_ds_main}
            fi

#else
#                echo "NO corresponding LCA_$LCA_name in tree_$j : associated column $i"
        fi


    done
}

sanity_check "${LCA_GORGO[*]}" "GORGO"
sanity_check "${LCA_PANTR[*]}" "PANTR"
sanity_check "${LCA_HUMAN[*]}" "HUMAN"
sanity_check "${LCA_NEA[*]}" "NEA"
sanity_check "${LCA_DEN[*]}" "DEN"

sanity_check "${LCA_PG[*]}" "PG"
sanity_check "${LCA_HNDP[*]}" "HNDP"
sanity_check "${LCA_HNDG[*]}" "HNDG"

sanity_check "${LCA_HN[*]}" "HN"
sanity_check "${LCA_ND[*]}" "ND"
sanity_check "${LCA_HD[*]}" "HD"

sanity_check "${LCA_HND[*]}" "HND"



