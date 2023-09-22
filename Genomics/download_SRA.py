#!/usr/bin/env python3

import sys, os
from Bio import Entrez, SeqIO
import xml.etree.ElementTree as ET
import requests
from urllib.parse import urlparse

# Entrez email
Entrez.email="n.e.coli.1822@gmail.com"

# Bioproject or SRA accession
project_id = sys.argv[1]

# esearch to retrieve sample accessions
project_handle = Entrez.esearch(db="SRA", term=project_id)
project_rec = Entrez.read(project_handle)
sample_acc = project_rec["IdList"]

# select file to download
print("Total {} accessions are found.".format(len(sample_acc)))
for count in range(len(sample_acc)):
	print("{}: {}".format(count, sample_acc[count]))
inp=input("What to download? ")

# xml save from loop
sample_id = sample_acc[int(inp)]
xml = ''
handle = Entrez.efetch(db="SRA", id=sample_id, retmode="text")
for i in handle:
	xml = xml + i.decode("UTF-8").strip()
xml_read = ET.fromstring(xml)

# assign read accession
url = xml_read[0][6][0][3][2][0].get('url')
srr_file = os.path.basename(urlparse(url).path)
print("Downloading {} now.".format(sample_id))
r = requests.get(url, allow_redirects=True)
open(srr_file, "wb").write(r.content)
print("{} is saved.".format(srr_file))
