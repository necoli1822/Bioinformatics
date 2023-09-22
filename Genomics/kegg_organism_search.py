from bioservices.kegg import KEGG
from re import search

k = KEGG()

def kegg_organism_search(key):
	organism_list = [ i.split("\t") for i in k.list("organism").split("\n") if search(key,i) ]
	return organism_list

# example
kegg_organism_search("coli")
