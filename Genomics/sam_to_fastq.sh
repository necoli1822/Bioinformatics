#!/usr/bin/env bash

cat $1 | grep -v ^@ | awk 'NR%2==1 {print "@"$1"\n"$10"\n+\n"$11}' > ${1%.sam}_1.fastq
cat $1 | grep -v ^@ | awk 'NR%2==0 {print "@"$1"\n"$10"\n+\n"$11}' > ${1%.sam}_2.fastq
