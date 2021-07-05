#!/usr/bin/env bash
###############################################################################
##                                                                           ##
## Purpose of script: Sort, compress and index gff (or gtf) file             ##
##                                                                           ##
###############################################################################

# var settings
args=("$@")
QUERY=${args[0]}


if [[ ${QUERY#*.} = gtf  ]]
then 
	mv ${QUERY} ${QUERY%.*}.gff
	QUERY=${QUERY%.*}.gff
fi

#Sort-Zip-Index
sort -k1,1 -k4,4n $QUERY > ${QUERY%.*}.sort.gff
bgzip ${QUERY%.*}.sort.gff
tabix -p gff ${QUERY%.*}.sort.gff.gz 

chmod a+rx ${QUERY%.*}.sort.gff.gz*

