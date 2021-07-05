#!/usr/bin/env bash
###############################################################################
##                                                                           ##
## Purpose of script: Index fasta file                                       ##
##                                                                           ##
###############################################################################

# var settings 
args=("$@")
QUERY=${args[0]}


#Index
samtools faidx $QUERY
chmod a+rx ${QUERY}.fai



