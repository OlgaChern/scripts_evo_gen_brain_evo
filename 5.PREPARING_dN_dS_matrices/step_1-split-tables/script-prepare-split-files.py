import os
import shutil



LCA_all={
"1": "MOUSE",
"2": "OTOGA",
"3": "CALJA",
"4": "MACMU",
"5": "NOMLE",
"14": "MOCMN_GPDNH",
"15": "MOCM_NGPDNH",
"16": "MOC_MNGPDNH",
"17": "MO_CMNGPDNH",
"HD": "MOCMNGPN_HD",
"HN": "MOCMNGPD_HN",
"HND": "MOCMNGP_HND",
"HNDG": "MOCMNP_HNDG",
"HNDP": "MOCMNG_HNDP",
"ND": "MOCMNGPH_ND",
"PG": "MOCMNDHN_PG"
}

sp=("DEN","GORGO","HUMAN","NEA","PANTR")

for i in LCA_all:
	src="LCA-"+i+"-all-trees"
	dst="split-"+LCA_all[i]+".csv"

	print(src,dst)
	#os.rename(src,dst)
	shutil.copy(src,dst)	
	
for i in sp:
	src="LCA-"+i+"-all-trees"
        dst="split-"+i+".csv"

	print(src,dst)
	shutil.copy(src,dst)


