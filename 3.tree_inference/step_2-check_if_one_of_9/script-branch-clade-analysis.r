args<-commandArgs(trailingOnly=TRUE)
if(length(args)<2){
	print("Usage: Rscript --vanilla script-branch-clade-analysis.r treefile_to_analyse clade_out all_trees_results")
	quit()
}
print("STARTING analysis with R script")

library(ape)

#-------------------------------------------------
getSubtreeInfo=function(t,cl,out){

	#print("entered getSubtreeInfo")
	# Check if the clade is monophyletic
	check_cl=is.monophyletic(t,cl)
        # Get a subtree structure
        subt=keep.tip(t,cl)

        if(check_cl){
                write.tree(file=out,subt)
                subtree=readLines(out)
        }else{
                subtree="NonMon"
        }

	# Num of edges < 10^(-5) in subclade
	check_e_len=length(which(subt$edge.length[]<0.00001))

	# Check if H, N, D are < 10^(-5)
	x=t$edge.length[which.edge(t,"HUMAN")]
	y=t$edge.length[which.edge(t,"NEANDERTHAL")]
	z=t$edge.length[which.edge(t,"DENISOVAN")]
	
	check_H_len=ifelse(x<0.00001, TRUE, FALSE)
	check_N_len=ifelse(y<0.00001, TRUE, FALSE)
	check_D_len=ifelse(z<0.00001, TRUE, FALSE)

	check_external=c(check_H_len,check_N_len,check_D_len)

	# Create a list with all info
	clade_info=list("mon" = check_cl, "subtree" = subtree, "edges" = check_e_len, "external" = check_external)
	return(clade_info)
}
#-------------------------------------------------
#print("READING tree")
t=read.tree(args[1])
t_out=args[2]
file_out=args[3]


# Clades of interest
clade=list(
	"c1" = c("HUMAN","NEANDERTHAL","DENISOVAN"),
	"c2"  = c("HUMAN","NEANDERTHAL"),
	"c3"  = c("NEANDERTHAL","DENISOVAN"),
	"c4"  = c("HUMAN","DENISOVAN"),
	"c5" = c("GORGO","PANTR","HUMAN","NEANDERTHAL","DENISOVAN")
)

#print("Checking monophyly of the 5 clades")
check_clade=c(
	is.monophyletic(t,clade$c1),
	is.monophyletic(t,clade$c2),
	is.monophyletic(t,clade$c3),
	is.monophyletic(t,clade$c4),
	is.monophyletic(t,clade$c5)
)


subt_out_1=paste(t_out,"subtr_1",sep=".")
subt_out_2=paste(t_out,"subtr_2",sep=".")

#print("Getting subtree info")
subtree_info_1=getSubtreeInfo(t,clade$c1,subt_out_1)
subtree_info_2=getSubtreeInfo(t,clade$c5,subt_out_2)

edges_other=subtree_info_1$edges-length(which(subtree_info_1$external[]==TRUE))
check_e_len=length(which(t$edge.length[]<0.00001))
tree_newick=readLines(args[1])

#print("outputing results")

sink(file=file_out,append=TRUE)
cat(paste(
	args[1],
	"|",
	paste("cladeHND_",check_clade[1],sep=""),
	ifelse(check_clade[2],"HN",FALSE),
	ifelse(check_clade[3],"ND",FALSE),
	ifelse(check_clade[4],"HD",FALSE),
	subtree_info_1$subtree,
	paste("edgesHND_",subtree_info_1$edges,sep=""),
	paste("H+",subtree_info_1$external[1],sep=""),
	paste("N+",subtree_info_1$external[2],sep=""),
	paste("D+",subtree_info_1$external[3],sep=""),
	paste("other_",edges_other,sep=""),
	"|=====|",
	paste("cladeHNDPPG_",check_clade[5],sep=""),
	subtree_info_2$subtree,
	paste("edgesHNDPPG_",subtree_info_2$edges,sep=""),
	tree_newick,
	paste("edgesTREE_",check_e_len,sep=""),
	'\n',
sep=" "))


sink()
