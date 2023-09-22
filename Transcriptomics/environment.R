#!/usr/bin/env Rscript

# install BiocManager and biomaRt
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

if (!require("biomaRt", quietly = TRUE))
    BiocManager::install("biomaRt")

if (!require("pathview", quietly = TRUE))
    BiocManager::install("pathview")

if (!require("DESeq2", quietly = TRUE))
    BiocManager::install("DESeq2")