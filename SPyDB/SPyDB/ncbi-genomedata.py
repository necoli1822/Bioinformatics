#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
from typing import List

from ncbi.datasets.openapi import ApiClient as DatasetsApiClient
from ncbi.datasets.openapi import ApiException as DatasetsApiException
from ncbi.datasets.openapi import GenomeApi as DatasetsGenomeApi
from ncbi.datasets.metadata.genome import get_assembly_metadata_by_bioproject_accessions

from ncbi.datasets.package import dataset

bioprojects: List[str] = [sys.argv[2]]
zipfile_name = str("{}.zip".format(sys.argv[3]))

# download command takes ncbi genome accessions so get accesions for taxname first
accessions = [asm_rec.assembly.assembly_accession for asm_rec in get_assembly_metadata_by_bioproject_accessions(bioprojects, returned_content='ASSM_ACC')]
if not accessions:
    sys.exit()
print(f'found {len(accessions)} genomes for bioprojects {bioprojects}: ', accessions)

# download an NCBI Datasets Genome Data Package given a list of NCBI Assembly accessions
with DatasetsApiClient() as api_client:
    genome_api = DatasetsGenomeApi(api_client)
    try:
        print('Begin download of genome data package ...')
        genome_ds_download = genome_api.download_assembly_package(
            accessions,
            include_annotation_type=['RNA_FASTA', 'PROT_FASTA'],
            _preload_content=False)

        with open(zipfile_name, 'wb') as f:
            f.write(genome_ds_download.data)
        print(f'Download completed -- see {zipfile_name}')
    except DatasetsApiException as e:
        sys.exit(f'Exception when calling download_assembly_package: {e}\n')


# open the package zip archive so we can retrieve files from it
package = dataset.AssemblyDataset(zipfile_name)