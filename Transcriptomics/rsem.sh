#!/usr/bin/env bash

declare -a runname=($(seq -f "%02g" 51 54))

for id in ${runname[@]}; do
        bam=star/${id}_Aligned.toTranscriptome.out.bam
        out=rsem/${id}
        log=rsem/${id}.log

        rsem-calculate-expression -p 24 --paired-end --alignments \
        --estimate-rspd \
        --calc-ci \
        --no-bam-output \
        --strandedness reverse \
        $bam /home/arprl6113/working/SJK/rsem_db ${out} > $log
done
