import biomart, pandas as pd

# building market connection
server = biomart.BiomartServer('http://www.ensembl.org/biomart')         
mart = server.datasets['hsapiens_gene_ensembl'] # adjust the value according to your species of interest.

# building attributes dataframe
attributes = mart.attributes
attributes_df = pd.DataFrame({ a:b for a, b in dict(attributes).items() },index=["Description"]).transpose()
attributes_df.index.name = "Attributes"

# attributes example
attributes = [ "ensembl_gene_id", "entrezgene_id", "hgnc_symbol", "entrezgene_description" ]
data = [ i for i in mart.search({'attributes': attributes}).raw.data.decode('ascii').split("\n") if i != "" ]
res_df = pd.DataFrame({ k.split("\t")[0]:k.split("\t")[1:]  for k in data },index=attributes[1:]).transpose()
