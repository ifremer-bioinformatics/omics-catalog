#!/usr/bin/env bash
###############################################################################
##                                                                           ##
## Purpose of script: get test data for testing omics-catalog                ##
##                                                                           ##
###############################################################################

args=("$@")
BASEDIR=${args[0]}
QUERY=${args[1]}

datadir="$BASEDIR/dataset/test"

if [ ! -d "$datadir" ] || ([ -d "$datadir" ] && [ ! "$(ls -A $datadir)" ])
then 
     mkdir -p $datadir
     wget -r -nc -nH --cut-dirs=6 ftp://ftp.ifremer.fr/ifremer/dataref/bioinfo/sebimer/sequence-set/OMICS-CATALOG/ -P $datadir
fi

if [ -f "$datadir/genomes/Crassostrea_gigas/ROSLIN_v1/query.fna" ]
then
   ln -s $datadir/genomes/Crassostrea_gigas/ROSLIN_v1/query.fna $QUERY
fi
