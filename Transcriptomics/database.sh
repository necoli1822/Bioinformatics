#!/usr/bin/env bash

: '
materials to read: What reference or database to use?
http://genomespot.blogspot.com/2015/06/mapping-ngs-data-which-genome-version.html
'

# NCBI database
ncbi_fas="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_genomic.fna.gz"
ncbi_gtf="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_genomic.gtf.gz"

# Ensembl database
ensembl_fas="https://ftp.ensembl.org/pub/release-108/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa.gz"
ensembl_gtf="https://ftp.ensembl.org/pub/release-108/gtf/homo_sapiens/Homo_sapiens.GRCh38.108.gtf.gz"

# GENCODE database
gencode_fas="http://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/latest_release/GRCh38.primary_assembly.genome.fa.gz"
gencode_gtf="http://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/latest_release/gencode.v42.annotation.gtf.gz"

# For alignment-free methods such as kallisto or salmon, rna sequences are required.
ncbi_rna="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_rna.fna.gz"
gencode_rna="http://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/latest_release/gencode.v42.transcripts.fa.gz"

# make db directory
if [ ! -d $2 ]
then
    mkdir $2
else
    # donwloading
    case $1 in
        "ncbi"|"NCBI")
        axel ${ncbi_fas}
        axel ${ncbi_gtf}
        ;;
        "ensembl"|"ENSEMBL")
        axel ${ensembl_fas}
        axel ${ensembl_gtf}
        ;;
        "gencode"|"GENCODE")
        axel ${gencode_fas}
        axel ${gencode_gtf}
        ;;
    esac
fi