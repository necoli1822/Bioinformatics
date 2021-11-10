[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)


# SPyDB
Simplypyed DEG Analysis for Bacteria

## Author
[Torsten Seemann](https://twitter.com/torstenseemann)

## Synopsis

Snippy finds SNPs between a haploid reference genome and your NGS sequence
reads.  It will find both substitutions (snps) and insertions/deletions
(indels).  It will use as many CPUs as you can give it on a single computer
(tested to 64 cores).  It is designed with speed in mind, and produces a
consistent set of output files in a single folder.  It can then take a set
of Snippy results using the same reference and generate a core SNP alignment
(and ultimately a phylogenomic tree).

## Quick Start
```
% snippy --cpus 16 --outdir mysnps --ref Listeria.gbk --R1 FDA_R1.fastq.gz --R2 FDA_R2.fastq.gz
<cut>
Walltime used: 3 min, 42 sec
Results folder: mysnps
Done.

% ls mysnps
snps.vcf snps.bed snps.gff snps.csv snps.tab snps.html 
snps.bam snps.txt reference/ ...

% head -5 mysnps/snps.tab
CHROM  POS     TYPE    REF   ALT    EVIDENCE        FTYPE STRAND NT_POS AA_POS LOCUS_TAG GENE PRODUCT EFFECT
chr      5958  snp     A     G      G:44 A:0        CDS   +      41/600 13/200 ECO_0001  dnaA replication protein DnaA missense_variant c.548A>C p.Lys183Thr
chr     35524  snp     G     T      T:73 G:1 C:1    tRNA  -   
chr     45722  ins     ATT   ATTT   ATTT:43 ATT:1   CDS   -                    ECO_0045  gyrA DNA gyrase
chr    100541  del     CAAA  CAA    CAA:38 CAAA:1   CDS   +                    ECO_0179      hypothetical protein
plas      619  complex GATC  AATA   GATC:28 AATA:0  
plas     3221  mnp     GA    CT     CT:39 CT:0      CDS   +                    ECO_p012  rep  hypothetical protein

% snippy-core --prefix core mysnps1 mysnps2 mysnps3 mysnps4 
Loaded 4 SNP tables.
Found 2814 core SNPs from 96615 SNPs.

% ls core.*
core.aln core.tab core.tab core.txt core.vcf
```

# Installation

## Conda
Install [Bioconda](https://bioconda.github.io/user/install.html) then:
```
conda install -c conda-forge -c bioconda -c defaults snippy
```