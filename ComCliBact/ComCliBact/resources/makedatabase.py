from Bio import Entrez, SeqIO
import os, sys, subprocess, requests, pandas as pd

# Method 1. using Entrez search

inTax = sys.argv[1]
subTax = inTax.replace(" ","+")

try:
    taxTerm = [ i.lstrip("+") for i in subTax.split(",") ]
    dbPath = sys.argv[2]
    Entrez.email=sys.argv[3]
except:
    print("Usage: makedatabase.py <taxonomy terms>")
    sys.exit(1)

searchTerm = " OR ".join(taxTerm)

try:
    ids = Entrez.read(Entrez.esearch(db="Taxonomy", term=searchTerm)).get('IdList')
except:
    print("Error: Could not connect to NCBI")
    sys.exit(1)

speciesDict = dict()
for i, j in zip(taxTerm, ids):
    speciesDict[i.replace("+"," ")] = j
    
for i in speciesDict.keys():
    os.mkdir(f"{dbPath}/{i}")


# Method 2. using GENOME_REPORTS

prokList = "genome_resports_prokaryotes.txt"
with open(prokList,"w") as f:
    f.write(requests.get("https://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/prokaryotes.txt", allow_redirects=True).text)

prok = pd.read_csv(prokList, sep="\t")
prok.rename(columns = {prok.columns[0]:'Name'}, inplace=True)
