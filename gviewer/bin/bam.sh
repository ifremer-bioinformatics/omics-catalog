#!/usr/bin/env bash
###############################################################################
##                                                                           ##
## Purpose of script: Index bam file                                         ##
##                                                                           ##
###############################################################################

# var settings
args=("$@")
QUERY=${args[0]}


#Index
samtools index $QUERY
chmod a+rx ${QUERY}.bai
