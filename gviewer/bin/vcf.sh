#!/usr/bin/env bash
###############################################################################
##                                                                           ##
## Purpose of script: Sort, compress and index vcf file                      ##
##                                                                           ##
###############################################################################

# var settings
args=("$@")
QUERY=${args[0]}

#Sort-Zip-Index
bcftools sort $QUERY >${QUERY%%.*}.sort.vcf
bgzip ${QUERY%%.*}.sort.vcf
bcftools index --tbi ${QUERY%%.*}.sort.vcf.gz

chmod a+rx ${QUERY%%.*}.sort.vcf.gz*


