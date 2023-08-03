import json
import os

from importlib import resources
import yaml
from yaml import load, dump
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper


def the_dir():
    return dir(yaml)

if __name__ == "__main__":
    # print(the_dir())
    with open(os.path.join(os.path.dirname(__file__), 'serverless.yml')) as yf:
        ymlpy = yaml.load(yf, Loader=yaml.FullLoader)
        ymlasjson = json.dumps(ymlpy, sort_keys=True, indent=2)
        print(ymlasjson)
