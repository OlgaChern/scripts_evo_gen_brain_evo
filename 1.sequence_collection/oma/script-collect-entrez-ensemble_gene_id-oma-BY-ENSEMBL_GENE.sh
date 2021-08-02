#!/bin/bash

mkdir -p oma_groups_LISTs

species="MOUSE OTOGA CALJA MACMU NOMLE PANTR GORGO HUMAN"

file_ensembl_entrez="mart_export-20787-Ensembl_GENE-Entrez-chr-1-22_X.txt-mod"
file_oma_ensembl="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/1.sequence_collection/oma/oma_HUMAN/oma-ensembl-HUMAN.txt"
file_oma_entrez="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/1.sequence_collection/oma/oma_HUMAN/oma-entrez-HUMAN.txt"
file_oma_groups="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/1.sequence_collection/oma/oma_HUMAN/oma-groups-HUMAN.txt"

#cat $file_oma_entrez | sed "s/;//g" | sed "s/ /=/g" | awk -F " " '{print $1 "=" $2 "="}'> ${file_oma_entrez}-MOD



file_entrez_human_brain="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/1.sequence_collection/initial_lists/list-human-entrezGeneIDs-10077-new"
#file_entrez_human_brain="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/1.sequence_collection/initial_lists/list-human-entrezGeneIDs-10710-sort"

#file_entrez_human_brain="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/1.sequence_collection/initial_lists/list-entrez-20787"




file_out="$file_entrez_human_brain-TABLE-entrez-enseml-oma"

if [ -e $file_out-by-ENSEMBL_GENE ]
then
	rm $file_out-by-ENSEMBL_GENE
	rm $file_out-ALL-INFO-by-ENSEMBL_GENE
fi

if [ -e $file_entrez_human_brain-oma_id-NF-by-ENSEMBL_GENE ]
then
	rm $file_entrez_human_brain-oma_id-NF-by-ENSEMBL_GENE
fi

if [ -e $file_entrez_human_brain-NF-in-ENSEMBL_ENTREZ-table ]
then
	rm $file_entrez_human_brain-NF-in-ENSEMBL_ENTREZ-table
fi


file_1="$file_entrez_human_brain"

m="`wc -l $file_1 | awk -F " " '{print $1}'`"
g=1
cat $file_1 | while read -r line
do
	echo "ENTREZ $g out of $m: $line"
	entrez="$line"
	g=$[$g+1]


	echo "getting ensembl genes.."
	genes_num="`grep ",${line}," $file_ensembl_entrez |wc -l | awk -F " " '{print $1}'`"


if [ $genes_num -gt 0 ]
then

	ensembl_genes="`grep ",${line}," $file_ensembl_entrez | awk -F "," '{print $1}' | xargs -n $genes_num`"


found="NO"
for ensembl_gene in $ensembl_genes
do
	echo "$ensembl_gene"

	oma_ids_num="`grep "$ensembl_gene" ${file_oma_ensembl} | wc -l |awk -F " " '{print $1}'`"

if [ $oma_ids_num -gt 0 ]
then

	oma_ids="`grep "$ensembl_gene" ${file_oma_ensembl} | awk -F " " '{print $1}' |  xargs -n $oma_ids_num`"

	#echo "ENTREZ $g: $line | $oma_ids"
found="YES"

 for oma_id in $oma_ids
 do 
	echo "getting ensembl_info.."
	ensembl_info="ensembl_NF"
	check="`grep "$oma_id" $file_oma_ensembl | wc -l | awk -F " " '{print $1}'`"
	if [ $check -gt 0 ]
	then
		ensembl_info="`grep "$oma_id" $file_oma_ensembl | awk -F " " '{print $2}'| xargs -n $check`"
		#echo "Ensembl FOUND: $oma_id|$ensembl_info"
	#else
		#echo "Ensembl NOT_FOUND: $oma_id"
	fi
	
	echo "|$entrez|$oma_id|$ensembl_info" >> $file_out-by-ENSEMBL_GENE


	echo "getting oma_group.."
	check_gr="`grep "$oma_id" $file_oma_groups |wc -l | awk -F " " '{print $1}'`"

	oma_gr="NA"
	oma_gr_sp_num="NA"
	oma_gr_sp="NA"

	if [ $check_gr -gt 0 ]
	then
	
		oma_gr="`grep "$oma_id" $file_oma_groups | awk -F " " '{print $1}'`"
		out_oma_gr="oma_groups_LISTs/oma_gr-$entrez-$oma_id-OMAgr$oma_gr"
		grep "$oma_id" $file_oma_groups | xargs -n 1 > $out_oma_gr-GROUP
				

		#rm $out_oma_gr-LIST
		#rm $out_oma_gr-seq

		oma_gr_sp=""
		echo "getting orthologs.."
		for sp in $species
		do
        		c="`grep "$sp" $out_oma_gr-GROUP | wc -l | awk -F " " '{print $1}'`"
        		if [ $c -eq "1" ]
        		then
                		sp_seq="`grep "$sp" $out_oma_gr-GROUP`"
				echo "$sp_seq" >> $out_oma_gr-LIST
				oma_gr_sp="$oma_gr_sp $sp_seq"

        		elif [ $c -eq "0" ]
        		then
                		#echo "$out_oma_gr-GROUP no ortholog for $sp"
				oma_gr_sp="$oma_gr_sp ${sp}_NA"

        		else
                		echo "$out_oma_gr-GROUP - $c - many orthologs for $sp?"
        		fi
		done

		#oma_gr_sp="`cat $out_oma_gr-LIST | xargs -n 10`"
		oma_gr_sp_num="`wc -l $out_oma_gr-LIST| awk -F " " '{print $1}'`"

		if [ $oma_gr_sp_num -eq 8 ]
		then
			echo "getting collecting orthologs.."
			for sp in $species
                	do
				seq_id="`grep "$sp" $out_oma_gr-LIST`"
				#echo "collecting sequence for $sp: $seq_id"
				sed -n -e "/$seq_id/,/>/ p" sequences/seq.$sp | sed -e '$d' >> $out_oma_gr-seq
			done
		fi


	#else
		#echo "OMA_group is NOT_FOUND for |$entrez|$oma_id|$ensembl_info"
	fi
		echo "|$entrez|$oma_id|$ensembl_info|OMAgr$oma_gr|sp_NUM_$oma_gr_sp_num|$oma_gr_sp" >> $file_out-ALL-INFO-by-ENSEMBL_GENE

done

#else
	#echo "NOT_FOUND oma_id for $g entrez: $entrez"
#	echo "$entrez" >> $file_entrez_human_brain-oma_id-by-ENSEMBL_GENE-NF
fi

done
	if [ $found == "NO" ]
	then
		echo "$entrez" >> $file_entrez_human_brain-oma_id-NF-by-ENSEMBL_GENE
	fi

else
	echo "$entrez" >> $file_entrez_human_brain-NF-in-ENSEMBL_ENTREZ-table
fi
#exit
done
