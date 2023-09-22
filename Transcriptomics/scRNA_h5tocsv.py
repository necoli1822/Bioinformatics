import sys
import collections
import scipy.sparse as sp_sparse
import tables
import pandas as pd
import numpy as np

CountMatrix = collections.namedtuple('CountMatrix', ['feature_ref', 'barcodes', 'matrix'])

def get_matrix_from_h5(filename):
    with tables.open_file(filename, 'r') as f:
        mat_group = f.get_node(f.root, 'matrix')
        barcodes = f.get_node(mat_group, 'barcodes').read()
        data = getattr(mat_group, 'data').read()
        indices = getattr(mat_group, 'indices').read()
        indptr = getattr(mat_group, 'indptr').read()
        shape = getattr(mat_group, 'shape').read()
        matrix = sp_sparse.csc_matrix((data, indices, indptr), shape=shape)

        feature_ref = {}
        feature_group = f.get_node(mat_group, 'features')
        feature_ids = getattr(feature_group, 'id').read()
        feature_names = getattr(feature_group, 'name').read()
        feature_types = getattr(feature_group, 'feature_type').read()
        feature_ref['id'] = feature_ids
        feature_ref['name'] = feature_names
        feature_ref['feature_type'] = feature_types
        tag_keys = getattr(feature_group, '_all_tag_keys').read()
        for key in tag_keys:
            key = key.decode("utf-8")
            feature_ref[key] = getattr(feature_group, key).read()

        return CountMatrix(feature_ref, barcodes, matrix)

filtered_matrix_h5 = sys.argv[1]
filtered_feature_bc_matrix = get_matrix_from_h5(filtered_matrix_h5)

df1 = pd.DataFrame([filtered_feature_bc_matrix.feature_ref['name'].astype(str), filtered_feature_bc_matrix.feature_ref['feature_type'].astype(str), filtered_feature_bc_matrix.feature_ref['genome'].astype(str)])
df2 = pd.DataFrame(filtered_feature_bc_matrix.matrix.toarray().transpose())
res = pd.concat([df1, df2])

res.index = np.arange(len(res.index))
tres = res.transpose()
tres.to_csv(filtered_matrix_h5.replace(".h5",".csv"),index=False,header=False)
print(filtered_matrix_h5.replace(".h5",".csv")+" is saved.")
