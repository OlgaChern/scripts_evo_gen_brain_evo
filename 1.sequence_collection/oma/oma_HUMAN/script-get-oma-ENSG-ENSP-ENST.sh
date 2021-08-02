#!/bin/bash


#list="oma_ids-HUMAN-all-30709"
list=part_1-oma_id-7577
list=correct-splice-variants
file_oma_ensembl="oma-ensembl-HUMAN.txt"
file_oma_groups="oma-groups-HUMAN.txt"

if [ -e $list-TABLE ]
then
	rm $list-TABLE
fi

if [ -e $list-ERROR ]
then
        rm $list-ERROR
fi

n=0
m="`wc -l $list | awk -F " " '{print $1}'`"
cat $list | while read -r line
do
	n=$[$n+1]

	check_1="`grep "$line" $file_oma_ensembl | wc -l | awk -F " " '{print $1}'`"
	check_2="`grep "$line" $file_oma_groups | awk -F " " '{print $1}' | wc -l | awk -F " " '{print $1}'`"

	if [ "$check_1" -eq 3 ] && [ "$check_2" -eq 1 ]
	then 
		ENSG="`grep "$line" $file_oma_ensembl | awk -F " " '{print $2}' | grep "ENSG"`"
		ENSP="`grep "$line" $file_oma_ensembl | awk -F " " '{print $2}' | grep "ENSP"`"
		ENST="`grep "$line" $file_oma_ensembl | awk -F " " '{print $2}' | grep "ENST"`"

		oma_gr="`grep "$line" $file_oma_groups | awk -F " " '{print $1}'`"

		echo "$ENSG $ENST $ENSP | $line | oma_group $oma_gr" >> $list-TABLE
		echo "checking $n out of $m|$ENSG $ENST $ENSP | $line | oma_group $oma_gr"
	else
		echo "ERROR: $line|$check_1|$check_2" >> $list-ERROR
		echo "checking $n out of $m|ERROR: $line|$check_1|$check_2"
	fi
#exit
done
