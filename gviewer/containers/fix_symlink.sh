#!/usr/bin/env bash
###############################################################################
##                                                                           ##
## Purpose of script: fix jbrowse2 symlink                                   ##
##                                                                           ##
###############################################################################

# var settings
args=("$@")
DIR=${args[0]}
FILE=${args[1]}
INDEX_FILE=${args[2]}


cd ${DIR}/jbrowse2

rm ${FILE} ${INDEX_FILE}
ln -s ../${FILE} .
ln -s ../${INDEX_FILE} .
