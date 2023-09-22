import sys, io, re, requests, itertools, pandas as pd

PCDL_head = "# Compound database\t\t\t\t\n#\t\t\t\t\n#\t\t\t\t\n# This is a compound formula database file used by Agilent MassHunter applications.\t\t\t\t\n# Copy to a different file if you wish to make changes to database contents\t\t\t\t\n# You can set the version (below) to any string value. \t\t\t\t\n# We recommend changing it when you update the database contents.\t\t\t\t\n#\t\t\t\t\n#\t\t\t\t\n# Version: the most recent-one\t\t\t\t\n#\t\t\t\t\n#\t\t\t\t\n#\t\t\t\t\n# WARNING: User should not change the format of this file.\t\t\t\t\n#\t\t\t\t\n# Each record in this file contins 5 columns described in the last comment in this comment block.\t\t\t\t\n# Retention time and Description are optional.\t\t\t\t\n# Each record should be kept on an individual line.\t\t\t\t\n# Fields are separated by comma.  Use quotes around a field that contains a comma.\t\t\t\t\n#\t\t\t\t\n# The first two lines have to be comments which start with the '#' character.\t\t\t\t\n# First line is 'Agilent TOF Formula data store'\t\t\t\t\n# Second line is 'Version:' followed by a version number\t\t\t\t\n#\t\t\t\t\n# Additionally\t comments (such as these) may be inserted on individual\t\t\t\n# lines by specifying a '#' character at the beginning of the line\t\t\t\t\n#\t\t\t\t\n#\t\t\t\t\n### Formula\t Retention Time\t Mass\t Compound name\t Description\n# Formula\t RT\t Mass\t Cpd\t Comments\n"

PCDL_header = pd.read_csv(io.StringIO(PCDL_head),sep="\t",names=["Formula","RT","Mass","Cpd","Comments"])

def chunks(lst, n):
	for i in range(0, len(lst), n):
		yield lst[i:i + n]


pathways = re.findall(f"{sys.argv[1]}"+r"[0-9]{5}",requests.get("https://rest.kegg.jp/list/pathway/"+f"{sys.argv[1]}").text)

pathways = sorted(list(set(pathways)))

df = pd.read_csv(sys.argv[2], sep="\t", index_col=0)

modules, compounds = list(), list()

for i in chunks(pathways,10):
	modules.append(re.findall(f"{sys.argv[1]}"+"_M[0-9]{5}", requests.get(f"https://rest.kegg.jp/get/{'+'.join(i)}").text))

modules = [ i.replace(f"{sys.argv[1]}_","") for i in sorted(list(set(sum(modules,[])))) ]

for k in chunks(modules, 10):
	compounds.append(re.findall("C[0-9]{5}",requests.get(f"https://rest.kegg.jp/get/{'+'.join(k)}").text))

compounds = sorted(list(set(sum(compounds, []))))

df = df.loc[compounds]
df['RT'] = ""
df['KEGG'] = df.index
df = df[["Formula", "RT", "Mass" ,"Cpd", "KEGG"]]
df.columns = ["Formula", "RT", "Mass" ,"Cpd", "Comments"]
cdf = pd.concat([PCDL_header,df],axis=0)
cdf.to_excel(sys.argv[3], header=False, index=False)
