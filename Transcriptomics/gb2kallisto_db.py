import sys
from Bio import SeqIO, SeqRecord

gb = sys.argv[1]
out = sys.argv[2]

gb = [ i for i in SeqIO.parse(gb, 'gb') ]
gene = { i.id:[] for i in gb }
res = []

for i in gb:
    for j in i.features:
        if j.type == "gene":
            if j.strand > 0:
                res.append( SeqRecord.SeqRecord(i.seq[j.location.start:j.location.end], id=j.qualifiers['locus_tag'][0]) )
            elif j.strand < 0:
                res.append( SeqRecord.SeqRecord(i.seq[j.location.start:j.location.end].reverse_complement(), id=j.qualifiers['locus_tag'][0]) )

for i in res:
    i.description = ""

SeqIO.write(res, open(sys.argv[2], "w"), "fasta")