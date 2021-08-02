args=commandArgs(trailingOnly=TRUE)
#==============================================
rescale_w<-function(w){
            w[which(w[]==-1)]=-0.01
            w[which(w[]==-2)]=-0.02
            w[which(w[]==-3)]=-0.03
	    w[which(w[]==-4)]=-0.04
            return(w)
}
#==============================================
#$branch_id $file-e_max_llh  $f-masked-un  $file-masked-un+e_short  $file-split-of-values  $file-w_max_llh  $file-w_percent

e_ids=read.table(args[1])
e_max_llh=read.table(args[2])
w_max_llh=read.table(args[6])
w_percent=read.table(args[7])


w_out_un=read.table(args[3])
w_out_un_e=read.table(args[4])
#w_out_un_e=rescale_w(w_out_un_e)

split=read.table(args[5])
tree_id=args[8]
#==============================================
ncol_w=ncol(w_max_llh)

plot_out=args[4]

#print(e_ids)
#print(w_out_un_e)


##PLOTS ==============================================================================================
for(i in 1:nrow(e_ids)){


	pdf(paste(paste(plot_out,"hist-selection-w",e_ids[i,1],e_ids[i,2],sep="-"),".pdf",sep=""),w=6,h=8)
		par(mfrow=c(2,1))
	# plot_1
		#my_breaks=c(seq(-5,10,1),seq(10,1010,100))
		#hist(w_out_un_e[,e_ids[i,1]],breaks=seq(-5,1000,1),main=paste(tree_id," | Distribution of dN/dS for branch | ",e_ids[i,1]," | ",e_ids[i,2],sep=""),xlab="dN/dS")
		#hist(w_out_un_e[which(w_out_un_e[,e_ids[i,1]]<=10),e_ids[i,1]],col="royalblue",breaks=seq(-5,10,1),main=paste(tree_id," | Distribution of dN/dS for branch | ",e_ids[i,1]," | ",e_ids[i,2],sep=""),xlab="dN/dS")
		#abline(v=c(1),col="firebrick")
		plot(w_max_llh[,e_ids[i,1]],w_percent[,e_ids[i,1]],main=paste(tree_id," | dN/dS vs. change in % for branch | ",e_ids[i,1]," | ",e_ids[i,2],sep=""),xlab="dN/dS",ylab="changes in % among 5 runs",col="yellowgreen")
		abline(h=c(10))
		



		c=which(w_out_un_e[,e_ids[i,1]]==-4)
		points(w_max_llh[c,e_ids[i,1]],w_percent[c,e_ids[i,1]],col="black")
		c=which(w_out_un_e[,e_ids[i,1]]==-3)
                points(w_max_llh[c,e_ids[i,1]],w_percent[c,e_ids[i,1]],col="darkmagenta")
		c=which(w_out_un_e[,e_ids[i,1]]==-1)
                points(w_max_llh[c,e_ids[i,1]],w_percent[c,e_ids[i,1]],col="firebrick")
		c=which(w_out_un_e[,e_ids[i,1]]==-2)
                points(w_max_llh[c,e_ids[i,1]],w_percent[c,e_ids[i,1]],col="royalblue")
		

		y=which(w_out_un_e[,e_ids[i,1]]<=10 & w_out_un_e[,e_ids[i,1]]>=0)
		hist(w_out_un_e[y,e_ids[i,1]],col="royalblue",breaks=seq(0,10,0.1),main=paste(tree_id," | Distribution of dN/dS for branch | ",e_ids[i,1]," | ",e_ids[i,2],sep=""),xlab="dN/dS")
		abline(v=c(1))
		#hist(w_out_un_e[,e_ids[i,1]],breaks=seq(-5,1000,1),main=paste(tree_id," | Distribution of dN/dS for branch | ",e_ids[i,1]," | ",e_ids[i,2],sep=""),xlab="dN/dS")



		#hist(w_out_un_e[,e_ids[i,1]],breaks=c(seq(-5,10,1),seq(10,1010,100)),main=paste(tree_id," | Distribution of dN/dS for branch | ",e_ids[i,1]," | ",e_ids[i,2],sep=""),xlab="dN/dS")
	# plot_2
		 #hist(w_percent[,e_ids[i,1]],breaks=seq(0,100,1),main=paste(tree_id," | Stability of dN/dS | ",e_ids[i,1]," | ",e_ids[i,2],sep=""),xlab="change of dN/dS in %")
	# plot_3
		#plot(e_max_llh[,e_ids[i,1]],w_percent[,e_ids[i,1]],main=paste(tree_id," | Edge length vs. change (in %) of dN/dS | ",e_ids[i,1]," | ",e_ids[i,2],sep=""))
	dev.off()
}

pdf(paste(paste(plot_out,"Reliability-per-branch",sep="-"),".pdf",sep=""),w=12,h=10)
par(mfrow=c(4,5))
my_col=c("yellowgreen","firebrick","royalblue","darkmagenta","black")
for(i in 1:nrow(e_ids)){
	w_un=length(w_out_un_e[which(w_out_un_e[,e_ids[i,1]]==-1),e_ids[i,1]])
	e_short=length(w_out_un_e[which(w_out_un_e[,e_ids[i,1]]==-2),e_ids[i,1]])
	w_0=length(w_out_un_e[which(w_out_un_e[,e_ids[i,1]]==-3),e_ids[i,1]])
	w_999=length(w_out_un_e[which(w_out_un_e[,e_ids[i,1]]==-4),e_ids[i,1]])
	w_good=nrow(w_out_un_e)-w_un-e_short-w_0-w_999
	barplot(c(w_good,w_un,e_short,w_0,w_999),col=my_col,main=paste(tree_id,e_ids[i,1],e_ids[i,2],sep="|"))
}
dev.off()

#h=c()
#for(i in 1:ncol_w){
#	h=c(h,w_percent[,i])
#}


#pdf()

#plot()

#dev.off()
