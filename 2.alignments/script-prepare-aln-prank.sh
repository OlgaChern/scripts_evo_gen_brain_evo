#!/bin/bash

#$ -q compute
#$ -cwd
#$ -j yes
#$ -l compute

f_prank="/project/olga-phylo/brain-evo/software/prank_wasabi/wasabi/binaries/prank"
unset MAFFT_BINARIES
file="$fileMY"
echo "#############################################################"
echo "Running PRANK on ${file}"
$f_prank/prank -d=${file} -f=paml -DNA -codon -showtree -o=${file}

aln="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/2.alignments/alignments-q30"
mv ${file}.* $aln
echo "#############################################################"
