import pandas as pd, scanpy as cp, scipy as sp
h = cp.read_10x_h5("file.h5")
mat = pd.DataFrame.sparse.from_spmatrix(h.X)
mat.columns = h.var['gene_ids'].index
mat.index = h.obs.index
mat.to_csv("out.csv")
