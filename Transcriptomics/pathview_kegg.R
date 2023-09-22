libs = c("pathview","gage","gageData")
invisible(suppressMessages(lapply(libs, library, quietly = TRUE, character.only = TRUE)))
args = commandArgs(trailingOnly=TRUE)

# for example, args <- c("merged_df.tbl","log2fc_time24_CMIT_low","entrezgene_id","./pathview","T")
# args[1] as the file path containing foldchange data
# args[2] as the column name containing entrezgene_id
# args[3] as the column name containing log2FoldChange
# args[4] as the directory to save the basic files
# args[5] as the boolean value for same.dir option in gage function

res = read.delim(args[1],header=T,row.names=1) # using the first column as the row names
data(kegg.sets.hs) # str(kegg.sets.hs) to check the list

fc = res[,eval(args[2])]
names(fc) = res[,eval(args[3])]
fc <- fc[!is.na(fc)]

# GAGE (Generally Applicable Gene-set Enrichment) analysis to sort the genes/transcripts into gsea categories

# Adjust gsets codes according to your favour. For example sets.hs for human, sets.mm for mouse.
# same.dir - True to divide up- and down-regulated, or False to contain both results in "greater" column
keggres = gage(fc, gsets=kegg.sets.hs, same.dir=as.logical(args[5]))

# To get five upregulated
keggres_greater = rownames(as.table(na.omit(keggres$greater)))
# To get five downregulated
if (as.logical(args[5])){
keggres_less = rownames(as.table(na.omit(keggres$less)))
}

# Get pathway ids
ids_greater = substr(keggres_greater, start=1, stop=8)
if (as.logical(args[5])){
ids_less = substr(keggres_less, start=1, stop=8)
}

# Define plotting function
plot_pathway = function(pid)pathview(gene.data=fc, pathway.id=pid, species="hsa", kegg.dir=args[4], new.signature=FALSE, out.suffix=args[2]) # edit species code accordingly for your species of interest - you can find them on KEGG website.

# This function will download and draw pathways in "ids_greater" and save as image.
if (length(unique(c(ids_greater,ids_less))) > 10){
	for (i in unique(c(ids_greater,ids_less)[1:10])){
		try(suppressWarnings(suppressMessages(plot_pathway(i))), silent=T)
	}
} else if (length(unique(c(ids_greater,ids_less))) <= 10){
	for (i in unique(c(ids_greater,ids_less))){
		try(suppressWarnings(suppressMessages(plot_pathway(i))), silent=T)
	}
} else{
print(unique(c(ids_greater,ids_less)))
}
