species="MOUSE OTOGA CALJA MACMU NOMLE PANTR GORGO HUMAN"
file_1="oma_downloads/eukaryotes.cdna.fa"

for sp in $species
do
	echo "Species: $sp"
	last="`grep "$sp" $file_1 | tail -n 1`"
	echo "last: $last"
	sed -n -e "/${sp}00001/,/$last/ p" $file_1 | sed -e '$d' > sequences/seq.$sp
	sed -n -e "/$last/,/>/ p" $file_1 | sed -e '$d' >> sequences/seq.$sp
done
