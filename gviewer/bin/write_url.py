#!/usr/bin/env python3

import json 
import os
import argparse
from collections import OrderedDict

def getArgs():
    parser = argparse.ArgumentParser(description="")
    parser.add_argument('-p',dest="path", type=str, help='')
    parser.add_argument('-u',dest="viewer_url", type=str, help='')

    args = parser.parse_args()

    return args

def load_json(jsonfile):
    with open(jsonfile) as json_data:
        databank = json.load(json_data, object_pairs_hook=OrderedDict)
    return databank


def write_url(path, viewer_url):
    databank_path=path+'/databank.json'
    d = load_json(databank_path)
    path = os.path.normpath(path)
    organism=path.split(os.sep)[-2]
    version=path.split(os.sep)[-1]
    url = {"JBROWSE": viewer_url+"/?config=DATA/"+organism+"/"+version+"/jbrowse2/config.json"}
    d["jbrowse"].update(url)
    new_d = OrderedDict()
    new_d["main"]=d["main"]
    new_d["jbrowse"]=d["jbrowse"]
    with open(databank_path, "w") as f:
        f.write(json.dumps(new_d, f, indent=2))
    

def parse(args):
    # 1 - Write url in databank.json
    write_url(args.path, args.viewer_url)
    
if __name__ == '__main__':
    args = getArgs()
    parse(args)
