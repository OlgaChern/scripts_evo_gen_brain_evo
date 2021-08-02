#!/bin/bash


file="list-human-entrezGeneIDs-10077-new-TABLE-entrez-enseml-oma-ALL-INFO-by-ENSEMBL_GENE"
file_out="$file-with_OMAgr"

cat $file | sed "/OMAgrNA/d" > $file_out

num="`wc -l $file-with_OMAgr | awk -F " " '{print $1}'`"
mv $file_out $file_out-$num
file="$file_out-$num"


num_genes="`awk -F "|" '{print $2}' $file | sort | uniq | wc -l | awk -F " " '{print $1}'`"
echo "The number of different genes|transcripts with OMA groups: $num_genes|$num"



file_out="$file-sp_NUM_8"
grep "sp_NUM_8" $file > $file_out
num="`wc -l $file | awk -F " " '{print $1}'`"
echo "The number of orthologs/transcripts with complete dataset (i.e. 8 species) is $num"


# genes with more than one homolog from OMA

awk -F "|" '{print $2}' list-human-entrezGeneIDs-10077-new-TABLE-entrez-enseml-oma-ALL-INFO-by-ENSEMBL_GENE-with_OMAgr-7658 | sort | uniq -c | sed "/ 1 /d"
