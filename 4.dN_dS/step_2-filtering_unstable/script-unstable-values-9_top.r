args=commandArgs(trailingOnly=TRUE)
#==============================================
rescale_w<-function(w){
            w[which(w[]==-1)]=-0.01
            w[which(w[]==-2)]=-0.02
            w[which(w[]==-3)]=-0.03
            return(w)
}
#==============================================
aln=args[1]
e=as.matrix(read.table(args[2]))
w=as.matrix(read.table(args[3]))
llh=as.matrix(read.table(args[4]))

tree=args[5]
plot_out=args[6]
ident_tree=args[7]
ident_pair=args[8]
general_info=args[9]
#==============================================
f="/project/olga-phylo/brain-evo/data/final-analysis/tree_topologies/branch_correspondence/"
e_ids=read.table(paste(f,"branch_id-",tree,sep=""))
#print(e_ids)

if(ident_tree!="NA"){
	#print(args[7])
	#print(paste(f,"branch_id-",ident_tree,sep=""))
	#e_ids_9sp=read.table(paste(f,"branch_id-",ident_tree,sep=""))
	e_ids=read.table(paste(f,"branch_id-",ident_tree,sep=""))
	#print(e_ids)
}
#==============================================
ncol_w=ncol(w)

e_range=array(0,ncol_w)
w_range=array(0,ncol_w)
w_percent=array(0,ncol_w)

e_max_llh=array(0,ncol_w)
w_max_llh=array(0,ncol_w)

flag_unstable=array(FALSE,ncol_w)

w_out_un=array(0,ncol_w)
w_out_un_e=array(0,ncol_w)
#---------------------------------------
llh_max_v=which(llh[]==max(llh[]))
llh_max=ifelse(length(llh_max_v==1),llh_max_v,llh_max_v[1])
#---------------------------------------

t_w_percent=10
t_e_len=0.0001


for(i in 1:ncol_w){
	e_range[i]=round(max(e[,i])-min(e[,i]),6)
	w_range[i]=round(max(w[,i])-min(w[,i]),6)
	w_percent[i]=w_range[i]/max(w[,i])*100

	w_max_llh[i]=w[llh_max,i]
	e_max_llh[i]=e[llh_max,i]
	w_out_un[i]=w_max_llh[i]
	
	if(w_percent[i]>=t_w_percent){
		flag_unstable[i]="TRUE"
		w_out_un[i]=-1
	}

	 w_out_un_e[i]=w_out_un[i]
	 if(length(which(e[,i]<=t_e_len))>0 & w_out_un_e[i]!=-1){
	    w_out_un_e[i]=-2
	 }

	w_out_un_e[which(w_max_llh[]==0.0001 & w_out_un_e[]!=-1 & w_out_un_e[]!=-2)]=-3
	w_out_un_e[which(w_max_llh[]==999 & w_out_un_e[]!=-1 & w_out_un_e[]!=-2 & w_out_un_e[]!=-3)]=-4
}
num_unstable_w=length(which(flag_unstable[]=="TRUE"))
# ====================================================================================================
##PLOTS ==============================================================================================
my_col=c("black","firebrick","royalblue","yellowgreen","darkmagenta")
pdf(paste(plot_out,"-dN-dS-analysis.pdf",sep=""),w=8,h=10)

par(mfrow=c(4,1))
# omega values amog 5 runs
plot(e_ids[,1],w[1,],xaxt="n",xlab="clades",ylab="dN/dS values (5 runs)",main=paste(tree," | OMEGA values among 5 runs",sep=""),lwd=2,cex=2)
	axis(1, labels=e_ids[,2], at=e_ids[,1],cex.axis=0.5)
	abline(v=e_ids[which(e_ids[,3]==1),1])
	lines(e_ids[,1],w[1,],col=my_col[1],lty=1)

	for(i in 2:5){
		points(e_ids[,1],w[i,],col=my_col[1],lwd=2,cex=2)
		lines(e_ids[,1],w[i,],col=my_col[i],lty=i)
	}

x=which(w_out_un_e[]==-1) # unstable due to change in dN/dS among 5 runs
y=which(w_out_un_e[]==-2) # unstable due to short edges
#z=which(w_out_un_e[]==-3) # unstable due to identical sequences
points(e_ids[x,1],w[1,x],col="firebrick",pch=19,lwd=2,cex=2)
points(e_ids[y,1],w[1,y],col="royalblue",pch=19,lwd=2,cex=2)
#points(e_ids[z,1],w[1,z],col="darkmagenta",pch=19,lwd=2)

########### Write results ####################################################



# edge lengths among 5 runs
plot(e_ids[,1],e[1,],xaxt="n",xlab="clades",ylab="edge lengths (5 runs)",main=paste(tree," | Edge lengths among 5 runs",sep=""),lwd=2,cex=2)
        axis(1, labels=e_ids[,2], at=e_ids[,1],cex.axis=0.5)
        abline(v=e_ids[which(e_ids[,3]==1),1])

        for(i in 2:5){
                points(e_ids[,1],e[i,],col=my_col[i],lwd=2,cex=2)
        }
# unstable %
plot(e_ids[,1],w_percent,col="firebrick",xaxt="n",xlab="clades",ylab="change of dN/dS values in %",
  main=paste(tree," | Stability of omega (change between max and min in %)",sep=""),lwd=2,cex=2)
	axis(1, labels=e_ids[,2], at=e_ids[,1],cex.axis=0.5)
        abline(h=c(1),v=e_ids[which(e_ids[,3]==1),1])

# correlation between unstable and short branches
plot(
    e_max_llh[which(flag_unstable[]=="FALSE")],
    w_max_llh[which(flag_unstable[]=="FALSE" )],
    xlab="edge lengths",
    ylab="dN/dS values",
    main=paste(tree," | Correlation between unstable dN/dS and short branches",sep=""),
    xlim=c(min(e_max_llh),max(e_max_llh)),
    ylim=c(min(w_max_llh),max(w_max_llh)),cex=2
)
	abline(v=c(0.00001,0.0001),col="firebrick")
	points(e_max_llh[which(flag_unstable[]=="TRUE")],w_max_llh[which(flag_unstable[]=="TRUE")],col="firebrick",pch=19,cex=2)
	
	x=(max(e_max_llh)-min(e_max_llh))/2
        y=(max(w_max_llh)-min(w_max_llh))/2
        text(x,y,paste("Number of unstable omega estimates ",num_unstable_w,sep=""))
	
	
# unstable differences max-min
#plot(e_ids[,1],un_omega,xaxt="n",xlab="clades",ylab="adsolute differences max-min (5 runs)",main="CONSENSUS tree")
#        axis(1, labels=e_ids[,2], at=e_ids[,1])
#	abline(v=e_ids[which(e_ids[,3]==1),1])

dev.off()
## ==============================================================================================


#############################################################################
#if(ident_tree!="NA"){
#        ## GET CORRESPONDENCE WITH 10 species TREE
#                w_ident_out_un=array(-3,ncol_w)
#                w_ident_out_un_e=array(-3,ncol_w)
#                for(i in 1:ncol_w_ident){
#                    j=e_ids_9sp[i,4]
#                    w_ident_out_un[j]=w_out_un[i]
#                    w_ident_out_un_e[j]=w_out_un_e[i]
#                }
#}

##Print info =========================================================================================
write(file=paste(args[3],"-masked-un",sep=""),paste(w_out_un,collapse=" "))
write(file=paste(args[3],"-masked-un+e_short",sep=""),paste(w_out_un_e,collapse=" "))
write(file=paste(args[3],"-max_llh",sep=""),paste(w_max_llh,collapse=" "))
write(file=paste(args[2],"-max_llh",sep=""),paste(e_max_llh,collapse=" "))
write(file=paste(args[2],"-e_range",sep=""),paste(e_range,collapse=" "))
write(file=paste(args[3],"-w_range",sep=""),paste(w_range,collapse=" "))
write(file=paste(args[3],"-w_percent",sep=""),paste(w_percent,collapse=" "))
write(file=paste(args[3],"-flag_unstable",sep=""),paste(flag_unstable,collapse=" "))





### JOINT info =======================================================================================
write(file=paste(general_info,"-masked-un",sep=""),paste(w_out_un,collapse=" "),append=TRUE)
write(file=paste(general_info,"-masked-un+e_short",sep=""),paste(w_out_un_e,collapse=" "),append=TRUE)
write(file=paste(general_info,"-w_percent",sep=""),paste(w_percent,collapse=" "),append=TRUE)
write(file=paste(general_info,"-w_max_llh",sep=""),paste(w_max_llh,collapse=" "),append=TRUE)
write(file=paste(general_info,"-e_max_llh",sep=""),paste(e_max_llh,collapse=" "),append=TRUE)


num_0=length(which(w_out_un_e[]==-3))
num_999=length(which(w_out_un_e[]==-4))
num_e=length(which(w_out_un_e[]==-2))
num_dn_ds=length(which(w_out_un_e[]==-1))
num_good=ncol_w-num_0-num_999-num_e-num_dn_ds

num_e_w=length(which(w_out_un_e[]==-2 & w_out_un[]==-1))
num_e_short_0=length(which(w_out_un_e[]==-3 & e_max_llh[]<=0.01))
num_e_short_999=length(which(w_out_un_e[]==-4 & e_max_llh[]<=0.01))

write(file=paste(general_info,"-split-of-values",sep=""),paste(num_good,num_e,num_dn_ds,num_0,num_999,num_e_w,num_e_short_0,num_e_short_999,sep=" "),append=TRUE)


