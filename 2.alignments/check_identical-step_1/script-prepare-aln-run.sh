#!/bin/bash

iqtree_file="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/iqtree"

f_work="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/2.alignments/"
f_aln="$f_work/alignments-q30"

species="MOUSE OTOGA CALJA MACMU NOMLE PANTR GORGO HUMAN"
species_sp="den nea"

tag=2227

f_check_ident="$f_work/check_identical-step_1/"
ident_all="$f_check_ident/list-aln-with-identical-seq-$tag"
ident_pair="$f_check_ident/list-aln-with-identical-seq-1_pair-$tag"
ident_many="$f_check_ident/list-aln-with-identical-seq-many-$tag"

if [ -e $ident_all ]
then
	rm $ident_all
fi

if [ -e $ident_pair ]
then
	rm $ident_pair
fi

if [ -e $ident_many ]
then
        rm $ident_many
fi


f_aln_new="$f_work/aln-qual_30"
mkdir -p $f_aln_new
mkdir -p $f_work/check_identical-step_1/check_ident/
mkdir -p $f_work/model_selection-step_2/models-qual_30/
mkdir -p $f_work/aln-qual_30-ident-pair/

f_aln_final="$f_work/aln-qual_30-final"
mkdir -p $f_aln_final

n=0

# create a list of alignments to be analysed (those, which have completed prank alignments)
list="$f_work/list-aln-2227"
ls $f_aln | grep "phy" > $list
#-----------------------------------------------------------------------------------------
cat $list | while read -r line
do
	aln="$f_aln/$line"
	HUMAN="`echo "$aln" | awk -F "oma_orthologs" '{print $2}'| awk -F "-" '{print $4}'`"

	n=$[$n+1]
	file_name="oma_`echo $aln | awk -F "oma_" '{print $2}'`"
	echo "preparing $n : $file_name"

	file="$f_aln_new/$file_name"
        cp $aln $file

	sed -i '1d' $file
	sp_den="`grep "den_" $file`"
	sed -i "s/$sp_den/>DENISOVAN/" $file
	sp_nea="`grep "nea_" $file`"
	sed -i "s/$sp_nea/>NEANDERTHAL/" $file

	for sp in $species
	do
		old_name="`grep "_$sp" $file`"
		sed -i "s/$old_name/>$sp/" $file
	done

	# identify best fit model
	#file_out="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/2.alignments/model_selection-step_2/models-qual_30/$file_name"

	# check identical sequences
	file_ident_check="$f_work/check_identical-step_1/check_ident/$file_name"
	$iqtree_file -m JC -n 0 -s $file -pre $file_ident_check -quiet
	check="`grep "identical to" ${file_ident_check}.log | wc -l | awk -F " " '{print $1}'`"
	if [ $check -gt 0 ]
	then
		echo "======================================="
		echo "$file_name has identical sequences"
		echo "`grep "is identical to" ${file_ident_check}.log`"
		echo "$file_name" >> $ident_all
		echo "end_of_NOTE =========================="
		# only a pair of identical sequences
		if [ $check -eq 1 ]
		then
			echo "identical PAIR"
			ident_sp_1="`grep "is identical to" ${file_ident_check}.log | awk -F " " '{print $2}'`" 
			ident_sp_2="`grep "is identical to" ${file_ident_check}.log | awk -F " " '{print $6}'`"
			
			echo "$file_name|`echo "$ident_sp_1 $ident_sp_2" | xargs -n 1 | sort | xargs -n 2`" >> $ident_pair
			h="`echo "$ident_sp_1 $ident_sp_2" | grep "HUMAN" | wc -l | awk -F " " '{print $1}'`"
			if [ $h -eq 1 ]
			then
				echo "HUMAN in identical PAIR"
				ident_rm="`echo "$ident_sp_1 $ident_sp_2" |xargs -n 1 | sed "/HUMAN/d"`"
			else
				h="`echo "$ident_sp_1 $ident_sp_2" | grep "NEANDERTHAL" | wc -l | awk -F " " '{print $1}'`"
				if [ $h -eq 1 ]
                        	then
					echo "NEANDERTHAL in identical PAIR"
                                	ident_rm="`echo "$ident_sp_1 $ident_sp_2" |xargs -n 1 | sed "/NEANDERTHAL/d"`"
                        	else
					echo "SOMEthing else in identical PAIR"
					ident_rm=$ident_sp_1
				fi
			fi
			aln_ident="$f_work/aln-qual_30-ident-pair/$file_name"
			script_ident="$f_work/check_identical-step_1/script-remove-1-ident-sp.sh"
			$script_ident $ident_rm $file $aln_ident
			file=$aln_ident
			#submit2sge -N g$n-m-$HUMAN-1-pair -q compute "/project/olga-phylo/brain-evo/data/final-analysis/tree_inference/iqtree -s $file -st CODON -m TESTONLY -pre $file_out -redo"
			#/project/olga-phylo/brain-evo/data/final-analysis/tree_inference/iqtree -s $file -st CODON -m TESTONLY -pre $file_out -redo
			cp $file $f_aln_final
		else
			echo "$file_name" >> $ident_many
		fi
	else
		cp $file $f_aln_final
		#submit2sge -N g$n-m-$HUMAN -q compute "/project/olga-phylo/brain-evo/data/final-analysis/tree_inference/iqtree -s $file -st CODON -m TESTONLY -pre $file_out -redo"
		#/project/olga-phylo/brain-evo/data/final-analysis/tree_inference/iqtree -s $file -st CODON -m TESTONLY -pre $file_out -redo
	fi
done
