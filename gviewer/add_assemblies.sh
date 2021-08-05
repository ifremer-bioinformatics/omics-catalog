#!/usr/bin/env bash

###############################################################################
##                                                                           ##
## Purpose of script: Run OMICS-CATALOG pipeline on assemblies               ##
##                                                                           ##
###############################################################################


# var settings
args=("$@")
GENOME=${args[0]}
VERSION=${args[1]}

# Omics data directory
OUTDIR=/home/ref-bioinfo-public/ifremer/sebimer/genomes/organism-banks/$GENOME/$VERSION
echo $OUTDIR

cd $HOME/omics-catalog/gviewer
LIST=$(ls $OUTDIR)
echo $LIST

for FILE in $LIST
do
	echo $FILE 
        if [[ $FILE = *.fasta ]]
        then
		ONE=$(qsub -W depend=afterany:$ONE -v "GENOME=$GENOME, VERSION=$VERSION, FASTA_FILE=$FILE" gbrowser2.pbs)
	fi 
done

