#!/usr/bin/env bash


JBROWSE2_WORKFLOW=/home1/datahome/galaxy/omics-catalog/gviewer

cd $JBROWSE2_WORKFLOW
qsub gbrowser.pbs

