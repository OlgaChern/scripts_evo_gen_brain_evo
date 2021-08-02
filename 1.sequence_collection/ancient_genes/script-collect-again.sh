#!//bin/bash


f_files="/project/olga-phylo/brain-evo/data/oma/oma/human-1-to-1-orthologs/lists_of_orthologs_per_gene-FINAL"
file_info_ensembl="/project/olga-phylo/brain-evo/data/ensembl/gene-info-GRCh37/coding-sequences/ensembl-data/info-chr-genes-mapped"

# FINAL:
# 1_exon, also includes last in the file
files="FINAL-list-aln-280-with-problems-1_exon-list"
# last gene, not properly collected in the first stage
files="FINAL-list-aln-14-with-problems-LAST-gene-list-UNIQ"


n=0

cat $files | while read -r line
do
	n=$[$n+1]
	echo "======================================================================================"
	echo "$n: $line"
	echo "======================================================================================"
	file="$f_files/$line"
	# collect all sequences except for den/nea, collect den/nea from original file
	if [ -e $file-mod ]
	then
		echo "file_mod with all sequences except for D/N exists"
	else
		sed -n -e "/> MOUSE/,/>den/ p" $file |  sed -e '$d' > $file-mod
	fi
	cp $file-mod $file

	ensembl_gene="`echo "$line" | awk -F "-" '{print $3}'`"
	HUMAN="`echo "$line" | awk -F "-" '{print $4}'`"

	# get chromosome number
        check="`grep "$ensembl_gene" $file_info_ensembl | wc -l | awk -F " " '{print $1}'`"
        if [ $check -eq 0 ]
        then
                echo "NOTFOUND: $ensembl_gene in $file_info_ensembl"
                echo "this gene is not mapped for ancient hominids! exiting..."
		rm  $file
        else
                chr="`grep "$ensembl_gene" $file_info_ensembl |head -n 1 | awk -F " " '{print $1}'`"

		echo "$chr $ensembl_gene $HUMAN"
                for db in den nea
                do
			echo "==================================================="
			chr_gene_order_info="gene_order_info/gene_order_${chr}_${db}_info-in_NOT-failed"
			# Problematic due to 1 exon
			#file_ancient="/project/olga-phylo/brain-evo/data/ensembl/gene-mod/genes-failed-genes-FINAL/$db/genes-chr$chr-${db}.fa"
			# Problematic due to being LAST in the file
			file_ancient="/project/olga-phylo/brain-evo/data/ensembl/gene-mod/genes-15.05/$db/genes-chr$chr-${db}.fa"

                	if [ -e $chr_gene_order_info ]
                	then
				echo "already collected gene order in genes-chr$chr-${db}.fa"
                	else
                        	grep ">" $file_ancient > $chr_gene_order_info
                	fi

			last="`tail -n 1 $chr_gene_order_info`"
			seq_name="`grep "$HUMAN" $file_ancient`"
			
			echo "---------------------------------------------------"
			echo "SEQ_LAST: $last"
			echo "SEQ_query:$seq_name"
			echo "---------------------------------------------------"
		
			echo "collecting sequence for $db: ${db}_$HUMAN"
			if [ "$last" == "$seq_name" ]
			then
                        	echo "IS_LAST $seq_name in genes-chr$chr-${db}.fa"
				echo "---------------------------------------------------"
				sed -n -e "/$HUMAN/,/>/ p" $file_ancient | sed "s/>/>$db /g" >> $file
				sed -n -e "/$HUMAN/,/>/ p" $file_ancient | sed "s/>/>$db /g"
			else
				echo "NOT_LAST $seq_name in genes-chr$chr-${db}.fa"
				echo "---------------------------------------------------"
				sed -n -e "/$HUMAN/,/>/ p" $file_ancient | sed "s/>/>$db /g" | sed -e '$d'>> $file
				sed -n -e "/$HUMAN/,/>/ p" $file_ancient | sed "s/>/>$db /g" | sed -e '$d'
			fi
                done
        fi
        
        # Prepare alignments
	qsub -N g$n-$HUMAN-prank -v fileMY="$file" -V /project/olga-phylo/brain-evo/data/final-analysis/script-prepare-aln-prank.sh
done

