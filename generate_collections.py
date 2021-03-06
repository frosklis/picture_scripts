#!/bin/python
"""Generates symlinks of collections"""
import sys
import os
import yaml
import pandas as pd
from pandasql import sqldf
import numpy as np
import shutil
from multiprocessing import Pool
from utils import var2int

_this_path = os.path.realpath(__file__)
INPUT_FOLDER = _this_path + "../jpeg"
OUTPUT_FOLDER = _this_path + "../colecciones"
#OUTPUT_FOLDER = "/srv/dropbox/Dropbox/Espacio familiar/Fotos/colecciones"


def create_symlink(row, folder):
    """Creates the symlink

    This is actually tricky because I want the symlinks to be understood by dropbox, meaning they can't not point to absolute folders but rather to relative folders
    """
    print(os.getcwd())
    depth = len(folder.split('/'))

    input = os.path.realpath(
        "%s/%s" % (row['directory'], row['filename'])
    )
    symlink = "../" * (depth+1) + "jpeg/" + input.split('jpeg/')[1]
    destination = row['filename']
    print("%s -> %s" % (destination, symlink))
    # os.symlink(symlink, destination)
    shutil.copy(symlink, destination)


def generate_collection(spec):
    """Generates a single collection"""

    name = spec['name'] if 'name' in spec else spec['folder']
    print("Generating {name} in folder {folder}".format(
        name=name, folder=spec['folder']))

    query = "select directory, file from jpeg where {condition}".format(
        condition=spec['rule'])
    selected = sqldf(query, globals())

    output_folder = "%s/%s" % (OUTPUT_FOLDER, spec['folder'])
    for f in os.listdir(output_folder):
        os.remove(os.path.join(output_folder, f))

    os.makedirs(output_folder, exist_ok=True)
    os.chdir(output_folder)

    print("Creating symlinks")

    selected.apply(lambda r: create_symlink(r, spec['folder']), axis=1)


def generate_collections(spec):
    """Generates collections out of a yaml specification"""
    collections = yaml.load(spec, Loader=yaml.FullLoader)

    with Pool(8) as p:
        p.map(generate_collection, collections)


if __name__ == '__main__':
    print("Generating collections from scratch.")
    columns = "-Rating -GPSlatitude -GPSlongitude -datetimeoriginal -directory -filename -title -description -derivedfrom -filemodifydate -subject -hierarchicalsubject -Make -Model -Lens -LensID -ImageWidth -ImageHeight -Aperture -ExposureTime -ISO".lower().split()
    columns = [c[1:] for c in columns]
    jpeg = pd.read_csv(
        '/srv/dropbox/Dropbox/Espacio familiar/Fotos/scripts/data/jpeg_exif.tsv', sep='\t', names=columns)
    jpeg.rating = jpeg.rating.apply(var2int)
    with open(sys.argv[1]) as spec:
        generate_collections(spec)
