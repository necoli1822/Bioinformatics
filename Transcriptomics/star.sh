#!/usr/bin/env bash

declare -a runname=()

for id in ${runname[@]}; do
        trim1=trimmed/${id}_1.fastq.gz
        trim2=trimmed/${id}_2.fastq.gz
        out=star/${id}_

        STAR --genomeDir /home/USER/db/~ \
        --readFilesIn $trim1 $trim2 \
        --outFileNamePrefix $out \
        --readFilesCommand zcat \
        --runThreadN 24 \
        --genomeLoad NoSharedMemory \
        --twopassMode Basic \
        --sjdbGTFfile *.gtf \
        --sjdbScore 2 \
        --sjdbOverhang 150 \
        --limitSjdbInsertNsj 1000000 \
        --outFilterMultimapNmax 20 \
        --alignSJoverhangMin 8 \
        --alignSJDBoverhangMin 1 \
        --outFilterMismatchNmax 999 \
        --outFilterMismatchNoverReadLmax 0.04 \
        --alignIntronMin 20 \
        --alignIntronMax 1000000 \
        --alignMatesGapMax 1000000 \
        --outSAMunmapped Within \
        --outFilterType BySJout \
        --outSAMattributes NH HI AS NM MD \
        --outSAMtype BAM SortedByCoordinate \
        --quantMode TranscriptomeSAM GeneCounts \
        --quantTranscriptomeBan IndelSoftclipSingleend
done

rm -R star/*_STARgenome star/*_STARpass1