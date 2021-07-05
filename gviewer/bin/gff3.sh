#!/usr/bin/env bash
###############################################################################
##                                                                           ##
## Purpose of script: Sort, compress and index gff3 file                     ##
##                                                                           ##
###############################################################################

# var settings
args=("$@")
QUERY=${args[0]}

#Sort
gt gff3 -sortlines -tidy -retainids $QUERY > ${QUERY%.*}.sort.gff3
 
#Zip-Index
bgzip ${QUERY%.*}.sort.gff3
tabix -p gff ${QUERY%.*}.sort.gff3.gz

chmod a+rx ${QUERY%.*}.sort.gff3.gz*
