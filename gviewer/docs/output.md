# OMICS-CATALOG: Output

This document describes the output produced by the workflow and the procedure to configure the catalog after running the pipeline. 
Let's take the exemple of the pipeline results with the test profile. You can see below what the dataset tree looks like before, while and after running the pipeline with the test profile.

## Pipeline output

Before running the pipeline, the dataset directory contains two majors sub-directory: 'custom' and 'test'

```bash
dataset/
├── custom
│   ├── catalog
│   └── genomes
└── test
```

When the pipeline is running, the first process will download data from [SeBiMER ftp](ftp://ftp.ifremer.fr/ifremer/dataref/bioinfo/sebimer/tools/OMICS-CATALOG/). In the 'genomes' subdirectory, you will find the reference sequence of the model organism Crassostrea gigas, from the ROSLIN Institue and a json file, which contains the metadata (lineage, version,...etc) which will be submitted in the catalog.
The 'genomes' subdirectory in the 'custom' directory is reserved to your data if you run the pipeline with the custom profile. Obviously, you are not forced to put your data here. But in this case, don't forget to change the paths in the [custom.config] (../conf/custom.config) file and please note that you must respect the tree structure /organism/version/ for the location of your omics data and databank.json file.

```bash
dataset/
├── custom
│   ├── catalog
│   └── genomes
└── test
    ├── catalog
    │   └── c_gigas.jpg
    └── genomes
        └── Crassostrea_gigas
            └── ROSLIN_v1
                ├── databank.json
                └── query.fna
```

After running the pipeline, several files have appeared. On the one hand, you can notice the presence of the indexed fna file (necessary for jbrowse2), and a 'jbrowse2' directory generated by the pipeline for setting up the jbrowse2 session. On the other hand, a csv file is generated in the 'catalog' directory. This csv file gathers the metadata read in the databank.json file, for the Keshif tool which implements the catalog.

```bash
dataset/
├── custom
│   ├── catalog
│   └── genomes
└── test
    ├── catalog
    │   ├── c_gigas.jpg
    │   └── Genomes.csv
    └── genomes
        └── Crassostrea_gigas
            └── ROSLIN_v1
                ├── databank.json
                ├── jbrowse2
                │   ├── config.json
                │   ├── query.fna -> ../query.fna
                │   └── query.fna.fai -> ../query.fna.fai
                ├── query.fna
                └── query.fna.fai
```

## Configure Keshif

The 'genomes' catalog is based on the Keshif data visualization tool, which is provided in the workflow. You don't have to install it. After running the pipeline, the only thing to do is to move the csv file to the main 'catalog' directory of the workflow. 

Moreover, if you want to add a picture of the organism in the catalog, you have to add it in the 'images' subdirectory of the main 'catalog' directory and to precise in the databank.json file the value "images/example.jpg" for the "IMAGE" key. 
Please note, if you have already added your genome to the catalog, you must run the pipeline a second time to update the csv file and thus the catalog. To this end, set the [catalog_only](usage.md#--catalog_only) option to true. 
