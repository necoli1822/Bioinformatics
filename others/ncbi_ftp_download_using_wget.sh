#!/bin/bash

# add -A "{extension}" for example, "_genomic.gbff.gz" to restrict downloading files
# do not remove the slash at the end of the link!
wget -r -e robots=off -nH -np -R "index.html*" --cut-dirs=6 https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/000/000/
