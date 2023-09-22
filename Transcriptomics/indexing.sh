#!/usr/bin/env bash

# STAR indexing
STAR --runMode genomeGenerate --runThreadN 24 --genomeDir DIR --genomeFastaFiles *.genome.fa --sjdbGTFfile *.gtf --sjdbOverhang 150

# RSEM indexing
rsem-prepare-reference -p 24 --gtf *.gtf *.genome.fa rsem_db