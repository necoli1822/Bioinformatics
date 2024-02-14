import os
from BCBio import GFF
from Bio import SeqIO

# https://biopython.org/wiki/GFF_Parsing# https://github.com/NBISweden/GAAS/blob/master/annotation/knowledge/gff_to_gtf.md
in_file = "your_file.gb"
out_file = "your_file.gff"
in_handle = open(in_file)
out_handle = open(out_file, "w")

GFF.write(SeqIO.parse(in_handle, "genbank"), out_handle)

in_handle.close()
out_handle.close()

# https://github.com/NBISweden/GAAS/blob/master/annotation/knowledge/gff_to_gtf.md
os.system('docker run --rm -v "$(pwd)":/mnt quay.io/biocontainers/agat:0.8.0--pl5262hdfd78af_0 agat_convert_sp_gff2gtf.pl --gff /mnt/your_file.gff -o /mnt/your_file.gtf')
