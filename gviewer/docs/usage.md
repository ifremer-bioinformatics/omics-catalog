# OMICS-CATALOG: Usage

## Table of contents
* [Introduction](#introduction)
* [Install the pipeline](#install-the-pipeline)
  * [Local installation](#local-installation)
  * [Adding your own system config](#adding-your-own-system-config)
* [Pre-requisites before running the pipeline](#pre-requisites-before-running-the-pipeline)
  * [Install JBrowse2 on a web server](#install-jbrowse2-on-a-web-server)
  * [Configure JBrowse2](#configure-jbrowse2)
  * [Supply metadata](#supply-metadata)
* [Running the pipeline](#running-the-pipeline)
  * [Updating the pipeline](#updating-the-pipeline)
  * [Reproducibility](#reproducibility)
* [Configure Keshif](#configure-keshif)
* [Mandatory arguments](#mandatory-arguments)
  * [`-profile`](#-profile)
  * [`--projectName`](#--projectName)
  * [`--version`](#--version)
* [Generic arguments](#generic-arguments)
  * [`--genomesdir`](#--genomesdir)
  * [`--outdir`](#--outdir)
  * [`--catalogdir`](#--catalogdir)
  * [`--logdir`](#--logdir)
* [Running only the catalog](#running-only-the-catalog) 
  * [`--catalog_only`](#--catalog_only)
* [Omics data type](#omics-data-type)
  * [`--fasta`](#--fasta)
  * [`--bam`](#--bam)
  * [`--vcf`](#--vcf)
  * [`--gff`](#--gff)
* [Job resources](#job-resources)
* [Other command line parameters](#other-command-line-parameters)
  * [`--email`](#--email)
  * [`--email_on_fail`](#--email_on_fail)
  * [`-name`](#-name)
  * [`-resume`](#-resume)
  * [`-c`](#-c)
  * [`--max_memory`](#--max_memory)
  * [`--max_time`](#--max_time)
  * [`--max_cpus`](#--max_cpus)
  * [`--plaintext_email`](#--plaintext_email)
  * [`--monochrome_logs`](#--monochrome_logs)

## Introduction

Nextflow handles job submissions on SLURM or other environments, and supervises running the jobs. Thus the Nextflow process must run until the pipeline is finished. We recommend that you put the process running in the background through `screen` / `tmux` or similar tool. Alternatively you can run nextflow within a cluster job submitted your job scheduler.

It is recommended to limit the Nextflow Java virtual machines memory. We recommend adding the following line to your environment (typically in `~/.bashrc` or `~./bash_profile`):

```bash
NXF_OPTS='-Xms1g -Xmx4g'
```

## Install the pipeline

### Local installation

Make sure that on your system either install [Nextflow](https://www.nextflow.io/) as well as [Singularity](https://www.sylabs.io/guides/3.0/user-guide/) allowing full reproducibility.

How to install omics-catalog:

```bash
git clone https://gitlab.ifremer.fr/bioinfo/omics-catalog
```

### Adding your own system config

To use this workflow on a computing cluster, it is necessary to provide a configuration file for your system. For some institutes, this one already exists and is referenced on [nf-core/configs](https://github.com/nf-core/configs#documentation). If so, you can simply download your institute custom config file and simply use `-c <institute_config_file>` in the launch command.

If your institute does not have a referenced config file, you can create it using files from [other infrastructure](https://github.com/nf-core/configs/tree/master/docs).

To correctly run the pipeline and make it functional, you must specify the parameters below, in the 'profiles' section of the configuration file:

```bash
profiles {
	singularity {
	    singularity.runOptions = '-B $params.outdir:/opt/jbrowse2/$params.projectName/$params.version'
	}	
	test {
        includeConfig 'path/to/omics-catalog/gviewer/conf/test.config'
    }
	custom {
        includeConfig 'path/to/omics-catalog/gviewer/conf/custom.config'
    }
```

## Pre-requisites before running the pipeline

### Install JBrowse2 on a web server

To install JBrowse2, see the documentation [here](https://jbrowse.org/jb2/docs/quickstart_web/#pre-requisites). Whether you used the JBrowse2 CLI or downloaded manually, you should have a 'jbrowse2' installation directory where you downloaded JBrowse2.

### Configure JBrowse2

As explained [here](https://jbrowse.org/jb2/docs/quickstart_web/#running-jbrowse-2), JBrowse2 requires a web server to run. We recommand you to configure your web server to serve the html page of the jbrowse2 installation directory through the name 'viewer-instance.fr'. But if you want to use an other name for the html page, don't forget to change the 'viewer_url' variable in the [custom.config](../conf/custom.config) file.

Then, to access the jbrowse2 session through the catalog, you must link the 'genomes' directory to the JBrowse2 installation directory. To do this, use the command below in the JBrowse2 installation directory:

```bash
ln -s /path/to/omics-catalog/gviewer/dataset/custom/genomes DATA
```

This, will create a symbolic link, named 'DATA', from the 'genomes' directory to the jbrowse2 installation directory. After running the pipeline, your data must be available in a jbrowse2 session through the url: https://viewer-instance.fr/?config=DATA/projectName/version/jbrowse2/config.json. This url will be automatically associated to the catalog.

### Supply metadata

The organism's metadata presented in the catalog (lineage, version, submitter, etc.) are provided in the [databank.json](databank.json) file. Before running the pipeline, you must therefore fulfill this file. 

Please note that : 
 
 • The 'JBROWSE' and 'GENENOTEBOOK' keys must stay empty. 

 • The 'IMAGE' key is used to add a picture of the organism in the catalog. The key value must be the name of a 'jpg' image, located in the 'images' directory of the 'catalog' directory.Thus, the name of the jpg image must be precedeed by 'images/' (e.g : "images/example.jpg"). 

 • The 'NCBI' key is used to provide the ncbi url, to access the full report of the organism.

 • Key values ​​must be in quotes, and the line must end with a comma (except for the last key). Make sure the structure of the json file is correct before running the pipeline, otherwise it will crash.
 
 • The databank.json file must be located is the genome version directory, with the omics-data.

## Running the pipeline

The most simple command for running the pipeline is as follows:

```bash
nextflow run main.nf -profile test,singularity -c <institute_config_file>
```

This will launch the pipeline with the `test` configuration profile using `singularity`. See below for more information about profiles.

Note that the pipeline will create the following files in your working directory:

```bash
work            # Directory containing the nextflow working files
.nextflow_log   # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

### Updating the pipeline

When you run the above command, Nextflow automatically runs the pipeline code from your git clone - even if the pipeline has been updated since. To make sure that you're running the latest version of the pipeline, make sure that you regularly update the version of the pipeline:

```bash
cd omics-catalog
git pull
```

### Reproducibility

It's a good idea to specify a pipeline version when running the pipeline on your data. This ensures that a specific version of the pipeline code and software are used when you run your pipeline. If you keep using the same tag, you'll be running the same version of the pipeline, even if there have been changes to the code since.

First, go to the [OMICS-CATALOG releases page](https://gitlab.ifremer.fr/bioinfo/omics-catalog/-/releases) and find the latest version number (eg. `v1.0.0`). Then, you can configure your local omics-catalog installation to use your desired version as follows:

```bash
cd omics-catalog
git checkout v1.0.0
```

## Configure Keshif

See [output.md](output.md) to configure the catalog after running the pipeline. 

## Mandatory arguments

### `-profile`

Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments. Note that multiple profiles can be loaded, for example: `-profile test,singularity`.

If `-profile` is not specified at all the pipeline will be run locally and expects all software to be installed and available on the `PATH`.

* `singularity`
  * A generic configuration profile to be used with [Singularity](http://singularity.lbl.gov/)
  * Pulls software from DockerHub: [`OMICS-CATALOG`](https://hub.docker.com/u/sebimer)

Profiles are also available to configure the workflow and can be combined with execution profiles listed above.

* `test`
  * A profile with a complete configuration for automated testing
  * Includes test dataset so needs no other parameters
* `custom`
  * A profile to complete according to your dataset and experiment

### `--projetcName`

Name of the organism you want to add to the catalog. It must be the name of the directory where the genome version(s) of this organism are and the associated omics data. (e.g: Crassostrea_gigas)

### `--version`

Name of the genome version. You can add the name of submitter in addition to the version (e.g: ROSLIN_v1 )

## Generic arguments 

### `--genomesdir`

Path to the 'genomes' directory, where each organism will be located. (default = /dataset/custom/genomes) 

### `--outdir`

Path to the data directory where the omics data are located. This path must lead to the organism version directory. (default = /dataset/custom/genomes/${projectName}/${version}) 

### `--catalogdir`

Path to the 'catalog' directory, where the Genomes.csv file will be generated. (default = /dataset/custom/catalog)

### `--logdir`

Path to the directory where the log files will be publised. (default = /work)

## Running only the catalog 

### `--catalog_only`

Set to true or false to implement only the catalog. It can be used to update the catalog if you have modified the databank.json after running the pipeline a first time.(default = false)
Please note that you must provide 'projectName' and 'version' with this argument. 

## Omics data type

### `--fasta`

Path to the reference sequence of the organism. The file must be in FASTA or FNA format.

### `--bam`

Path to the alignement file of the organism. The file must be in BAM format.

### `--vcf`

Path to the variant calling file of the organism. The file must be in VCF format.

### `--gff`

Path to the annotation file of the organism. The file must be in GFF format.
If the file is in GFF3 format, use --gff3.

Please note that the first time you run the pipeline on your data, the path to the reference sequence file is required. In case you run the pipeline a second time to add new omics data for in jbrowse2 for the same organism, you need to provide only the path of the new files, in addition to the projectName and version arguments.

## Job resources

Each step in the pipeline has a default set of requirements for number of CPUs, memory and time. For most of the steps in the pipeline, if the job exits with an error code of `143` (exceeded requested resources) it will automatically resubmit with higher requests (2 x original, then 3 x original). If it still fails after three times then the pipeline is stopped.

# Other command line parameters

### `--email`

Set this parameter to your e-mail address to get a summary e-mail with details of the run sent to you when the workflow exits.

### `--email_on_fail`

Same as --email, except only send mail if the workflow is not successful.

### `-name`

Name for the pipeline run. If not specified, Nextflow will automatically generate a random mnemonic.

### `-resume`

Specify this when restarting a pipeline. Nextflow will used cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously.

You can also supply a run name to resume a specific run: `-resume [run-name]`. Use the `nextflow log` command to show previous run names.

**NB:** Single hyphen (core Nextflow option)

### `-c`

Specify the path to a specific config file (this is a core NextFlow command).

**NB:** Single hyphen (core Nextflow option)

Note - you can use this to override pipeline defaults.

### `--max_memory`

Use to set a top-limit for the default memory requirement for each process.
Should be a string in the format integer-unit. eg. `--max_memory '8.GB'`

### `--max_time`

Use to set a top-limit for the default time requirement for each process.
Should be a string in the format integer-unit. eg. `--max_time '2.h'`

### `--max_cpus`

Use to set a top-limit for the default CPU requirement for each process.
Should be a string in the format integer-unit. eg. `--max_cpus 1`

### `--plaintext_email`

Set to receive plain-text e-mails instead of HTML formatted.

### `--monochrome_logs`

Set to disable colourful command line output and live life in monochrome.
