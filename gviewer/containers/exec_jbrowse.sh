#!/usr/bin/env bash
###############################################################################
##                                                                           ##
## Purpose of script: Run JBrowse2                                           ##
##                                                                           ##
###############################################################################


args=("$@")
DATA_DIRECTORY=${args[0]}
FILE=${args[1]}


cd ${DATA_DIRECTORY}/jbrowse2

if [[ ${FILE#*.} = bam ]]
then
	file_type=BAM
elif [[ ${FILE##*.} = vcf ]]
then
	file_type=VCF
else 
	file_type=GFF
fi

if [[ $FILE = *.fasta || $FILE = *.fna ]]
then
	jbrowse add-assembly ${DATA_DIRECTORY}/${FILE} --target ${DATA_DIRECTORY}/jbrowse2 --load symlink --overwrite
	jbrowse set-default-session --name ${FILE%%.*} --view LinearGenomeView --target ${DATA_DIRECTORY}/jbrowse2
else 
	jbrowse add-track ${DATA_DIRECTORY}/${FILE} --target ${DATA_DIRECTORY}/jbrowse2 --category=${file_type} --load symlink --overwrite
fi

