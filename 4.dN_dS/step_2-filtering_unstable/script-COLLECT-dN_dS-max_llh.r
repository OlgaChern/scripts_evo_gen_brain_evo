args=commandArgs(trailingOnly=TRUE)
#==============================================
dN=as.matrix(read.table(args[1]))
dS=as.matrix(read.table(args[2]))
llh=as.matrix(read.table(args[3]))
general_info=args[4]
#==============================================
ncol_w=ncol(dN)
#---------------------------------------
llh_max_v=which(llh[]==max(llh[]))
llh_max=ifelse(length(llh_max_v==1),llh_max_v,llh_max_v[1])
#---------------------------------------
dN_max_llh=array(0,ncol_w)
dS_max_llh=array(0,ncol_w)
#---------------------------------------

for(i in 1:ncol_w){
	dN_max_llh[i]=dN[llh_max,i]
	dS_max_llh[i]=dS[llh_max,i]
}
# ====================================================================================================
##Print info =========================================================================================
dN_out=paste(dN_max_llh,collapse=" ")
dS_out=paste(dS_max_llh,collapse=" ")
#print(dN_out)
#print(dS_out)
write(file=paste(args[1],"-dN_max_llh",sep=""),dN_out)
write(file=paste(args[2],"-dS_max_llh",sep=""),dS_out)
### JOINT info =======================================================================================
write(file=paste(general_info,"-dN_max_llh",sep=""),dN_out,append=TRUE)
write(file=paste(general_info,"-dS_max_llh",sep=""),dS_out,append=TRUE)


