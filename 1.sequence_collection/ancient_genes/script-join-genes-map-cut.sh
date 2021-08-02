#!/bin/bash

#-----------------------------------------------------------------------------------
f_bedtools="/project/olga-phylo/brain-evo/software/bedtools/bedtools2/bin"
f_gatk="/project/olga-phylo/brain-evo/software/gatk-4.1.1.0"
human_chr="/project/olga-phylo/brain-evo/data/human-GRCh37"
#-----------------------------------------------------------------------------------
f_work="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/1.sequence_collection/ancient_genes"
f_bed_files="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/1.sequence_collection/ensemble_GRCH37/bed-files"
#-----------------------------------------------------------------------------------
chromosomes="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X"
dbs="den nea"
#-----------------------------------------------------------------------------------
minQ="30"
minDP="10"
tag="-19.09-minQ_${minQ}-minDP_${minDP}"
#-----------------------------------------------------------------------------------
for chr in $chromosomes
do
	#chr="22"
	file_bed="$f_bed_files/coding-gene-structure-chr${chr}.bed"
	ref_fasta="$human_chr/chr${chr}.fa"

	for db in $dbs
	do
		mkdir -p $f_work/genes${tag}/$db/

		# Do not change the below line
		vcf_complete_unfiltered="/project/olga-phylo/brain-evo/data/ensembl/gene-mod/vcf-complete/$db/vcf-chr${chr}-indels.recode.vcf"
		# New filtered vcf's
		vcf_complete_filtered="$f_work/vcf_complete_filtered/${db}/vcf-filtered-chr${chr}-minQ_${minQ}-minDP_${minDP}"
		
		# Filtering
		vcf="$vcf_complete_filtered"
                #vcftools --vcf $vcf_complete_unfiltered --minQ $minQ --minDP $minDP --recode --recode-INFO-all --out $vcf

		# map to the reference
		vcf="$f_work/vcf_complete_filtered/${db}/vcf-filtered-chr${chr}-minQ_${minQ}-minDP_${minDP}.recode.vcf"

		echo "mapping $db SNPs to reference chr$chr..."
                out_fasta="$f_work/genes${tag}/$db/mod-chr$chr-${db}.fa"

		#$f_gatk/gatk IndexFeatureFile --feature-file $vcf
		#$f_gatk/gatk FastaAlternateReferenceMaker --output $out_fasta --reference $ref_fasta --variant $vcf

		seq_name="`head -n 1 $out_fasta`"
		#sed -i -e "s/$seq_name/>$chr/" $out_fasta
		#rm $f_work/genes$tag/$db/mod-chr$chr-${db}.dict
		#rm $f_work/genes$tag/$db/mod-chr$chr-${db}.fa.fai

		file_fasta="$out_fasta"
		file_fasta_out="$f_work/genes$tag/$db/genes-chr$chr-${db}.fa"
		$f_bedtools/bedtools getfasta -fi $file_fasta -bed $file_bed -s -split -name -fo $file_fasta_out
#exit
	done
#exit
done

