#!/usr/bin/env python3

import os
import json
import re
import argparse

def getArgs():
    parser = argparse.ArgumentParser(description="")
    parser.add_argument('-p',dest="datapath",type=str,default="/home/ref-bioinfo/ifremer/sebimer/organism-banks",help='')
    parser.add_argument('-o',dest="csvname",type=str,default="Genomes.csv",help='')

    args = parser.parse_args()

    return args

def walk_level(directory, depth = 2):
    # If depth is negative, just walk
    # Unsed in the project
    if depth < 0:
        for root, dirs, files in os.walk(directory):
            yield root, dirs, files
    # path.count works because is a file has a "/" it will show up in the list as a ":"
    else:
        path = directory.rstrip(os.path.sep)
        num_sep = path.count(os.path.sep)
        for root, dirs, files in os.walk(path):
            yield root, dirs, files
            num_sep_this = root.count(os.path.sep)
            if num_sep + depth <= num_sep_this:
                del dirs[:]

def load_json(jsonfile):
    with open(jsonfile) as json_data:
        databank = json.load(json_data)
    return databank

def reads_write(csvname, directories):
    # Open output csv for databank infos
    d_csv = open(csvname, 'w')
    d_csv.write('Name,CommonName,Submitter,Bioproject,Biosample,Accession,Version,Level,TaxID,Lineage,Superkingdom,Phylum,Class,Order,Family,Genus,Species,JBrowse,Genenotebook,NCBI,Image,Owner\n')
    # Retrive all databank.json
    for root, dirs, files in directories:
        if 'databank.json' in files:
            d = load_json(os.path.join(root, 'databank.json'))
            if 'jbrowse' in d :
                m = d['jbrowse']
                for k, v in m.items():
                    if k=='LINEAGE':
                        lineage=re.split(r';', v)
                        #print(lineage)
                m['SUPERKINGDOM']=lineage[0]
                m['PHYLUM']=lineage[1]
                m['CLASS']=lineage[2]
                m['ORDER']=lineage[3]
                m['FAMILY']=lineage[4]
                m['GENUS']=lineage[5]
                m['SPECIES']=lineage[6]
                d_csv.write( '"{0}","{1}","{2}","{3}","{4}","{5}","{6}","{7}","{8}","{9}","{10}","{11}","{12}","{13}","{14}","{15}","{16}","{17}","{18}","{19}","{20}","{21}"\n'.format(m['SCIENTIFIC_NAME'],m['COMMON_NAME'],m['SUBMITTER'],m['BIOPROJECT'],m['BIOSAMPLE'],m['ACCESSION'],m['VERSION'],m['LEVEL'],m['TAXID'],m['LINEAGE'],m['SUPERKINGDOM'],m['PHYLUM'],m['CLASS'],m['ORDER'],m['FAMILY'],m['GENUS'],m['SPECIES'],m['JBROWSE'],m['GENENOTEBOOK'],m['NCBI'],m['IMAGE'],m['OWNER']))
    # Close files
    d_csv.close()

def parse(args):
    # 1 - Digging genomes directory and explore all levels of depth
    directories = walk_level(args.datapath, -1)
    # 2 - Parse json and write csv
    reads_write(args.csvname, directories)

if __name__ == '__main__':
    args = getArgs()
    parse(args)
