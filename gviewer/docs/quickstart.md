# OMICS-CATALOG: Quickstart guide

To follow the quickstart guide, make sure the [prerequisites](usage.md#pre-requisites-before-running-the-pipeline) are met.

## Input file requirements

### Reference sequence file

The reference sequence file must be in FASTA or FNA format, and located in the genome version directory.

### databank.json file 

The databank.json file must be completed and located in the genome version directory with omics-data.

## Process parameters

The `custom.config` file control each process and it's parameters, **so it's very important to fulfill this file very carefully**. Otherwise, it's can lead to computational errors or misinterpretation of biological results.

In this section, we will describe the most important parameters for each process.

```projectName```: the name of the model organism, **without space, tabulation or accented characters**. It must be the same name as the directory.

```version```: the version of the genome, **without space, tabulation or accented characters**. It must be the same name as the version directory, where your omics-data is located.

```genomesdir```: the path which leads to all the organisms of your catalog. The default path is /dataset/custom/genomes.

```outdir```: the path which leads to the version directory. The default path is /genomesdir/*projectName*/*version*.

```fasta```: the full path to your reference sequence file.

If you want to add others omics-data (bam, vcf, gff/gff3) in addition to the reference sequence file, use the different arguments describe [here](gviewer/docs/usage.md#omics-data-type).




