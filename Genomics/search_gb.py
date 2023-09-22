import sys
from Bio import SeqIO
from Bio import SeqFeature

genbank_file=sys.argv[1]
pos_file=sys.argv[2]

gb=SeqIO.read(genbank_file,"gb")
pos_list = [ p.strip() for p in open(pos_file,"r") ]

for pos in pos_list:
    for f in gb.features:
        if f.type == "CDS":
            if int(f.location.start) <= int(pos) and int(pos) <= int(f.location.end):
                print("SNP\t{}\tCoding\t{}".format(pos,f.qualifiers["product"]))
            else:
                pass
    if f.type != "CDS" and f.type != "gene":
        print("SNP\t{}\tNon-coding\t-".format(pos))


#Type of mutation
#Position
#Coding
#Mutation
#Function
#Virulence
#resistance
