#!/usr/bin/env Rscript

# load biomaRt
library(biomaRt)

# load dataset
gen = read.delim("gencode.v33.annotation_transcripts.txt", header=TRUE, sep="\t")

# make mart object
ensembl = useEnsembl(biomart = "genes", dataset = "hsapiens_gene_ensembl")
invisible(genes.tbl = getBM(attributes = c("ensembl_gene_id_version", "ensembl_transcript_id_version", "hgnc_symbol", "entrezgene_id", "description"), filters="ensembl_transcript_id_version", values=gen$TranscriptID, mart=ensembl, verbose=FALSE))

# merge table
merge.tbl = merge(x=gen, y=genes.tbl, by.x="TranscriptID", by.y="ensembl_transcript_id_version", all.x=TRUE, all.y=FALSE)

# save the result table
write.csv(merge.tbl, "merged_gencode_transcripts.csv")