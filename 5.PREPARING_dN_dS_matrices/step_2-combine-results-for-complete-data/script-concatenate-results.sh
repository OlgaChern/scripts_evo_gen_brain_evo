#!/bin/bash

f_main="/project/olga-phylo/brain-evo/data/09.sept.2019-entrez_29180/5.PREPARING_dN_dS_matrices"

for d in dN dS
do

f_1st=$f_main/step_1-split-tables/tables_for_all_6222_genes/part_1/$d
f_2nd=$f_main/step_1-split-tables/tables_for_all_6222_genes/part_2/$d
f_work=$f_main/step_2-combine-results-for-complete-data


for i in $f_1st/split-*
do
	#echo "$i"
	name="`echo "$i" | awk -F "/" '{print $12}'`"
	cp $i $f_work/$name
	cat $f_2nd/$name >> $f_work/$name
	echo "$name"
	name_mod="`echo "$name" | sed "s/split/split-$d/g"`"
	mv $f_work/$name $f_work/$name_mod
done


for i in $f_1st/results-*
do
	#echo "$i"
	name="`echo "$i" | awk -F "results-d" '{print "results-d" $2}'`"
	cp $i $f_work/$name
        cat $f_2nd/$name >> $f_work/$name
	echo "$name"
done

done



for i in $f_work/split-*; do sed -i "s/ /,/g" $i; done
for i in $f_work/results-*; do sed -i 's/\t/,/g' $i; done
