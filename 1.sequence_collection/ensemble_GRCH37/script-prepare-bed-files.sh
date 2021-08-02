#!/bin/bash

file_oma="list-human-entrezGeneIDs-10077-new-TABLE-entrez-enseml-oma-by-ENSEMBL_GENE-mod-delete-repeated"
f_data_ensembl="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/1.sequence_collection/ensemble_GRCH37/files_gene_structure"
f_output_bed="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/1.sequence_collection/ensemble_GRCH37/bed-files"
f_structure_info="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/1.sequence_collection/ensemble_GRCH37/structure-per-gene-transcript"

# This file should be created from uniq values (for gene transcript) of file_data_ensembl_2
# File with the followwing format:
# chr	gene_id	transcript_id	strand
file_data_ensembl_1="$f_data_ensembl/data-ensembl-coding-gene-transcript-info"


# The info for this file should be downloaded from ensembl.org:
# File with the following format:
# chr	gene_id	transcript_id	strand	CDS_len	Genomic_coding_start	Genomic_coding_end
file_data_ensembl_2="$f_data_ensembl/data-ensembl-coding-gene-structure"

# check, if file exists
if [ -e $file_data_ensembl_1 ]
then
	echo "file_data_ensembl_1 exists"
else
	echo "creating file <data-ensembl-coding-gene-transcript-info> from <data-ensembl-coding-gene-structure>"
	awk '{FS="\t";OFS="\t"} {print $1,$2,$3,$4,$5}' $file_data_ensembl_2 | uniq | sed "/Chromosome/d"> $file_data_ensembl_2
	# you also have to filter transcripts without CDS. You can check it simply via "CDS Length" info
	cat $file_data_ensembl_2 | while read -r line
	do
		check="`echo "$line" | awk -F '\t' '{print $5}' | wc -L | awk -F " " '{print $1}'`"
		if [ $check -gt 0 ]
		then
			echo "$line" >> $file_data_ensembl_1
		fi
	done
	# Moreover, choose only those transcripts mentioned in OMA. This will be our rule to choose among homologs
	# you can do it by comparing CDS lengths of transcript with sequence lengths of conding sequences from OMA	
fi


# Bed output file. Contains structure information about all genes/transcripts
#file_bed="$f_output_bed/coding-gene-structure.bed"
rm $f_output_bed/*
#if [ -e $file_bed ]
#then
#	rm $file_bed
#fi

echo "Preparing bed file..."
cat $file_data_ensembl_1 | while read -r line
do
	echo "line: $line"
	chr="`echo "$line" | awk -F '\t' '{print $1}'`"
	file_bed="$f_output_bed/coding-gene-structure-chr${chr}.bed"

	gene="`echo "$line" | awk -F '\t' '{print $2}'`"
	transcript="`echo "$line" | awk -F '\t' '{print $3}'`"
	strand="`echo "$line" | awk -F '\t' '{print $4}'`"
	if [ $strand -eq 1 ]
	then
		strand="+"
	else
		strand="-"
	fi

	file_out_structure="$f_structure_info/structure-$gene-$transcript"
	# already done, otherwise, comment out the line below
	#grep "$transcript" $file_data_ensembl_2 > $file_out_structure

	echo "STRUCTURE file: $file_out_structure"
	blockCount="`awk -F '\t' '{print $6}' $file_out_structure | sed '/^$/d' | wc -l | awk -F " " '{print $1}'`"

	echo "blockCounts: $blockCount"
	if [ $blockCount -gt 0 ]
	then
		oma_id="NA"
		entrez="NA"
		check_oma="`grep "${gene}" $file_oma | grep "${transcript}" | wc -l | awk -F " " '{print $1}'`"
		if [ $check_oma -gt 0 ]
		then
			oma_id="`grep "${gene}" $file_oma | grep "${transcript}" | awk -F "|" '{print $3}'`"	
			entrez="`grep "${gene}" $file_oma | grep "${transcript}" | awk -F "|" '{print $2}'`"
		fi
	
		chromStart="`awk -F '\t' '{print $6}' $file_out_structure | sed '/^$/d' | sort -n | head -n 1`"
		chromStart=$[$chromStart-1]
		chromEnd="`awk -F '\t' '{print $7}' $file_out_structure | sed '/^$/d' | sort -n | tail -n 1`"
		chromEnd=$[$chromEnd-1]

		gen_cod_start=(`awk -F '\t' '{print $6}' $file_out_structure | sed '/^$/d' | sort -n | xargs -n $blockCount`)
		gen_cod_end=(`awk -F '\t' '{print $7}' $file_out_structure | sed '/^$/d' | sort -n | xargs -n $blockCount`)

		c=0
		len=()
		start_pos=()

		while [ $c -lt $blockCount ]
		do
			end_bp="${gen_cod_end[$c]}"
			start_bp="${gen_cod_start[$c]}"
			value=$[$end_bp - $start_bp + 1]
			len=(${len[*]} $value)

			value=$[$start_bp - $chromStart - 1]
			start_pos=(${start_pos[*]} $value)

			#echo "count $c"
			#echo "	- blockSizes: ${len[*]}"
			#echo "	- blockStart: ${start_pos[*]}"
			c=$[$c+1]
		done

		blockSizes="`echo "${len[*]}" | sed "s/ /,/g"`"
		blockStarts="`echo "${start_pos[*]}" | sed "s/ /,/g"`"
	
		if [ $blockCount -eq 1 ]
		then
			chromEnd=$[$chromEnd+1]
		fi

		# print an info line into bed file
		echo "$chr	$chromStart	$chromEnd	${gene}_${transcript}_${oma_id}_${entrez}	0	$strand	$chromStart	$chromStart	(0,0,0)	$blockCount	$blockSizes	$blockStarts" >> $file_bed
		echo "$chr      $chromStart     $chromEnd       ${gene}_${transcript}_${oma_id}_${entrez}       0       $strand $chromStart     $chromStart     (0,0,0) $blockCount     $blockSizes     $blockStarts"
	fi
done
