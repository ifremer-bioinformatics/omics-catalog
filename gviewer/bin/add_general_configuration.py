#!/usr/bin/env python
import argparse
import binascii
import datetime
import hashlib
import json


def add_general_configuration(config_path):
        """
            Add some general configuration to the config.json file
        """

        # config_path = os.path.join(config_json)
        
        with open(config_path, 'r') as config_file:
            config_json = json.load(config_file)

        config_data = {}

        config_data['theme'] = {
            "palette": {
                "primary": { "main": '#084B8A'},
                "secondary": { "main":'#0B173B' },
                "tertiary": { "main": '#9F81F7' },
                "quaternary": { "main": '#FE9A2E' },
            },
            "typography": { "fontSize":  10 },
        }

        config_json['configuration'].update(config_data)

        with open(config_path, 'w') as config_file:
            json.dump(config_json, config_file, indent=2)



if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="", epilog="")

    parser.add_argument('--config_file', help='config.json')
   
    args = parser.parse_args()

 
    add_general_configuration(args.config_file)




