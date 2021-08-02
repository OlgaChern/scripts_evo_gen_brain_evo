#!/bin/bash
codeml="/project/olga-phylo/brain-evo/software/paml4.9i/bin/codeml"

#f_aln="/project/olga-phylo/brain-evo/data/final-analysis/alignments-q30-mod-used-for-dN-dS"
#f_model="/project/olga-phylo/brain-evo/data/final-analysis/tree_inference/models-qual_30"
#f_work="/project/olga-phylo/brain-evo/data/final-analysis/dn-ds"



f_aln="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/2.alignments/aln-qual_30-final"
f_model="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/2.alignments/model_selection-step_2/models-qual_30"
f_work="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/4.dN_dS/step_1-compute_dn_ds/RESULTS"
mkdir -p $f_work


list_main="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/3.tree_inference/step_2-check_if_one_of_9/list-for_model_selection-without_ident-with_pair_ident-info-topologies-dn_ds_list"
list="list-dn_ds-with-topology-info"

cp $list_main $list


num_all="2 3 4 5 10"
#num_all="2"


for NUM in $num_all
do
n=0
cat $list | while read -r line
do
	n=$[$n+1]
	echo "Preparing param file for n$n: $line"

	file="`echo "$line" | awk -F " " '{print $1}'`"
	tree="`echo "$line" | awk -F " " '{print $2}'`"
	tag="`echo "$line" | awk -F " " '{print $3}'`"

	line=$file

	if [ -d "$f_work/${tag}_${NUM}/$line/" ]
	then
		rm -r $f_work/${tag}_${NUM}/$line/
	fi

	mkdir -p $f_work/${tag}_${NUM}/$line

	oma_id="`echo "$file" | awk -F "-" '{print $4}'`"

	aln="$f_aln/${line}"



	## Getting intial model parameters
	model="$f_model/${line}.log"
	kappa="`grep "(kappa)" $model | awk -F ": " '{print $2}'`"
	omega="`grep "(omega)" $model | awk -F ": " '{print $2}'`"

	if [ $NUM -eq 2 ]
	then
		kappa=$kappa
		omega=$omega
	elif [ $NUM -eq 3 ]
	then
		kappa=2
		omega=1
	elif [ $NUM -eq 4 ]
	then
		kappa="1"
		omega="0.5"
	elif [ $NUM -eq 5 ]
	then
		kappa="0.5"
                omega="1"
	elif [ $NUM -eq 10 ]
        then
                kappa="0.5"
                omega="0.5"
	fi

	echo "kappa - `grep "(kappa)" $model`"
	echo "omega - `grep "(omega)" $model`"
	echo "`grep "Best-fit model:" $model`"

	# 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table
	# F, F1X4, F3X4, FU
	model_codon_freq="`grep "Best-fit model:" $model | awk -F " " '{print $3}'| awk -F "+" '{print $2}'`"
	if [ $model_codon_freq == "F3X4" ]
	then
		codon_freq="2"
	elif [ $model_codon_freq == "F1X4" ]
	then
		codon_freq="1"
	elif [ $model_codon_freq == "F" ]
	then
		codon_freq="3"
	else
		codon_freq="0"
	fi

	###########################################################
	############    PAML   ####################################
	###########################################################
	file_param="RESULTS/${tag}_${NUM}/$line/codeml.ctl"
	file_out="RESULTS/${tag}_${NUM}/${line}/out"
        ######## PREPARE param file ###############################
        echo "seqfile = $aln" >> $file_param
        echo "" >> $file_param
        echo "treefile = $tree" >> $file_param
        echo "outfile = $file_out" >> $file_param

        echo "noisy = 0     * 0,1,2,3,9: how much rubbish on the screen" >> $file_param
        echo "verbose = 0   * 1: detailed output, 0: concise output" >> $file_param
        echo "runmode = 0   * 0: user tree;  1: semi-automatic;  2: automatic
                            * 3: StepwiseAddition; (4,5):PerturbationNNI" >> $file_param
        echo "seqtype = 1   * 1:codons; 2:AAs; 3:codons-->AAs" >> $file_param

        echo "CodonFreq = $codon_freq   * 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table" >> $file_param
        echo "model = 1   * models for codons:
                          * 0:one, 1:b (free rate for each branch), 2:2 or more dN/dS ratios for branches" >> $file_param
        echo "fix_kappa = 0   * 1: kappa fixed, 0: kappa to be estimated" >> $file_param
        echo "kappa = $kappa   * initial or fixed kappa" >> $file_param
        echo "fix_omega = 0   * 1: omega or omega_1 fixed, 0: estimate" >> $file_param
        echo "omega = $omega   * initial or fixed omega, for codons or codon-transltd AAs" >> $file_param

        echo "getSE = 0   * 0: don't want them, 1: want S.E.s of estimates" >> $file_param
        echo "RateAncestor = 0   * (1/0): rates (alpha>0) or ancestral states (alpha=0)" >> $file_param

        echo "fix_blength = 0  * 0: ignore, -1: random, 1: initial, 2: fixed" >> $file_param
        echo "method = 0   * 0: simultaneous; 1: one branch at a time   " >> $file_param

        ###########################################################

	submit2sge -N ${tag}_$NUM-$n-$oma_id -q compute "$codeml $file_param"
#exit

done
done
