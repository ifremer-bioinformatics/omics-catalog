#!/usr/bin/env bash
###############################################################################
##                                                                           ##
## Purpose of script: get singularity images of omis-catalog dependancies    ##
##                                                                           ##
###############################################################################

args=("$@")
BASEDIR=${args[0]}
SING_IMAGES_OK=${args[1]}

container_dir="$BASEDIR/containers"

if [ ! -f "$container_dir/samtools-1.12.sif" ] && [ ! -f "$container_dir/bcftools-1.12.sif" ] && [ ! -f "$container_dir/genometools-1.6.1.sif" ] && [ ! -f "$container_dir/jbrowse2-1.0.2.sif" ]
then
     wget -r -nc -l1 -nH --cut-dirs=6 -A '*.sif' ftp://ftp.ifremer.fr/ifremer/dataref/bioinfo/sebimer/tools/OMICS-CATALOG/ -P $container_dir
fi

if [ -f "$container_dir/samtools-1.12.sif" ] && [ -f "$container_dir/bcftools-1.12.sif" ] && [ -f "$container_dir/genometools-1.6.1.sif" ] && [ -f "$container_dir/jbrowse2-1.0.2.sif" ] 
then
     touch $SING_IMAGES_OK
fi

