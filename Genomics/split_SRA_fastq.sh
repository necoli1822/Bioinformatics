# split the interleaved single fastq file downloaded from NCBI SRA web
awk 'NR==1{split(FILENAME,a,"."); base=a[1]; r1=base"_R1.fastq"; r2=base"_R2.fastq"} NR%8==1||NR%8==2||NR%8==3||NR%8==4 {print > r1} NR%8==5||NR%8==6||NR%8==7||NR%8==0 {print > r2}' $1
