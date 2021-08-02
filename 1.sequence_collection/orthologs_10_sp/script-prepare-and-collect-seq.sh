#!/bin/bash

f_work="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/1.sequence_collection/orthologs_10_sp"
f_oma_seq="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/1.sequence_collection/oma/oma_groups_LISTs"
file_oma_orthologs="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/1.sequence_collection/initial_lists/list-human-entrezGeneIDs-10077-new-TABLE-entrez-oma-ensembl"

file_info_ensembl="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/1.sequence_collection/ensemble_GRCH37/bed-files/info-chr-genes-mapped"

summary_0="summary_0-no-ancient-hominid-seq"
summary_1="summary_1-sanity-check-seq-length-19.09-minQ_30-minDP_10"
summary_2="summary_2-submitted_prank"


if [ -e $summary_0 ]
then
	rm $summary_0
fi
if [ -e $summary_1 ]
then
        rm $summary_1
fi
if [ -e $summary_2 ]
then
        rm $summary_2
fi



n=0
cat $file_oma_orthologs | while read -r line
do
	n=$[$n+1]
	entrez="`echo "$line" | awk -F "|" '{print $2}'`"
	ensembl_gene="`echo "$line" | awk -F "|" '{print $4}'`"
	echo "================================================="
	echo "$ensembl_gene"
	echo "n: $n"
	echo "================================================="
	HUMAN="`echo "$line" | awk -F "|" '{print $3}'`"

	file_oma_seq="$f_oma_seq/oma_gr-$entrez-$HUMAN-*-seq"

	check_ancient=""
	chr=""
	check_ancient="`grep "$ensembl_gene" $file_info_ensembl | wc -l | awk -F " " '{print $1}'`"
	if [ $check_ancient -eq 0 ]
	then
		echo "NOTFOUND: $ensembl_gene in $file_info_ensembl"
		echo "this gene is not mapped for ancient hominids! exiting..."
		echo "NOTFOUND: $ensembl_gene in $file_info_ensembl" >> $summary_0
	else
		file_1="$f_work/seq_fasta_files_10sp/oma_orthologs-$entrez-$ensembl_gene-$HUMAN-seq"
		cp $file_oma_seq $file_1

		# get chromosome number
		chr="`grep "$ensembl_gene" $file_info_ensembl |head -n 1 | awk -F " " '{print $1}'`"
		for db in den nea
		do
			echo "collecting sequence for $db: ${db}_$HUMAN"
			file_ancient="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/1.sequence_collection/ancient_genes/genes-19.09-minQ_30-minDP_10/$db/genes-chr$chr-${db}.fa"

			#check_if_LAST
			chr_gene_order_info="gene_order_info/gene_order_${chr}_${db}_info-19.09-minQ_30-minDP_10"
			mkdir -p gene_order_info
                        if [ -e $chr_gene_order_info ]
                        then
                                echo "already collected gene order in genes-chr$chr-${db}.fa"
                        else
                                grep ">" $file_ancient > $chr_gene_order_info
                        fi

                        last="`tail -n 1 $chr_gene_order_info`"
			# you screwed up the names, the gene is ok, but the transcript and oma_ids are wrong in the ancient genes files
                        seq_name="`grep "$HUMAN" $file_ancient`"
			

                        echo "collecting sequence for $db: ${db}_$HUMAN"
                        if [ "$last" == "$seq_name" ]
                        then
                                echo "IS_LAST $seq_name in genes-chr$chr-${db}.fa"
                                #echo "---------------------------------------------------"
                                sed -n -e "/$HUMAN/,/>/ p" $file_ancient | sed "s/>/>$db /g" >> $file_1
                                #sed -n -e "/$HUMAN/,/>/ p" $file_ancient | sed "s/>/>$db /g"
                        else
                                echo "NOT_LAST $seq_name in genes-chr$chr-${db}.fa"
                                #echo "---------------------------------------------------"
                                sed -n -e "/$HUMAN/,/>/ p" $file_ancient | sed "s/>/>$db /g" | sed -e '$d'>> $file_1
                                #sed -n -e "/$HUMAN/,/>/ p" $file_ancient | sed "s/>/>$db /g" | sed -e '$d'
                        fi
		done


		# SANITY CHECK IF DEN/NEA SEQUENCES ARE OF THE SAME LENGTH as HUMAN if not, check, what is wrong
		human_len="`sed -n -e "/> HUMAN/,/>den/ p" $file_1 |  sed -e '$d'|sed '1d' | tr --delete '\n' | wc -L | awk -F " " '{print $1}'`"
        	den_len="`grep -A 1 ">den" $file_1 | wc -L | awk -F " " '{print $1}'`"
        	nea_len="`grep -A 1 ">nea" $file_1 | wc -L | awk -F " " '{print $1}'`"

        	check=$[$human_len - $den_len]
		check_aln="NO"
        	if [ $check -gt 0 ]
        	then
			SANITY="FAIL"
        	elif [ $check -eq 0 ]
        	then
			check_aln="YES"
			SANITY="MATCH"
        	else
			SANITY="WEIRD"
        	fi

		echo "$file_1|$human_len|$den_len|$nea_len|$SANITY" >> $summary_1

		# Prepare alignments
		if [ $check_aln == "YES" ]
		then
			echo "The lengths of sequences are good. Preparing alignment with PRANK..."
			echo "$file_1" >> $summary_2
			qsub -N g$n-$HUMAN-prank -v fileMY="$file_1" -V /project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/2.alignments/script-prepare-aln-prank.sh
		fi
	fi
done
