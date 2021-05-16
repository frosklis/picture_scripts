#!/bin/python

"""Synchronize changes in picture folders
"""

import pandas as pd
import numpy as np
from utils import var2int, listfiles
import os


_this_path = os.path.dirname(os.path.realpath(__file__))
# JPEG_FOLDER = "/srv/dropbox/Dropbox/Espacio familiar/Fotos/jpeg"
JPEG_FOLDER = _this_path + "/../jpeg/"
COLLECTIONS_FOLDER = _this_path + "/../colecciones/"
RAW_FOLDER = _this_path + "/../negativos/"
DATA_FOLDER = _this_path + "/../scripts/data/"


def read_data():
    """Returns a dictionary of lists of dataframes with keys raw and jpeg"""
    columns = "-Rating -GPSlatitude -GPSlongitude -datetimeoriginal -directory -filename -title -description -derivedfrom -filemodifydate -subject -hierarchicalsubject -Make -Model -Lens -LensID -ImageWidth -ImageHeight -Aperture -ExposureTime -ISO".lower().split()
    columns = [c[1:] for c in columns]

    dataframes = {}
    # Create the data
    for subset in ["raw", "jpeg"]:
        df_1 = pd.read_csv('%s/%s_exif.tsv' %
                           (DATA_FOLDER, subset), sep='\t', names=columns)
        df_2 = pd.read_csv('%s/%s_exif_new.tsv' %
                           (DATA_FOLDER, subset), sep='\t', names=columns)
        df_1.rating = df_1.rating.apply(var2int)
        df_2.rating = df_2.rating.apply(var2int)
        dataframes[subset] = [df_1, df_2]

    return dataframes


def get_jpeg_name(x):
    extension = x.split('.')[-1].lower()
    if extension in ['avi', 'mp4', 'mov', 'psd', 'txt', 'heic', '3gp']:
        new_extension = '.%s' % extension
    else:
        new_extension='.jpg'
    return x.split('.')[0] + new_extension
def get_filetype(x):
    # extension = x.split('.')[-1]
    return x.split('.')[-1].lower()


def process_file(r):
    commands = []
    if r['action_raw'] == 'delete' or r['filename_raw'] != r['filename_raw']:
        commands += ['rm -f "%s%s"*' % (JPEG_FOLDER, r['full_jpeg_name'])]
    elif r['action_raw'] == 'new':
        commands += ['rm -f "%s%s"*' % (JPEG_FOLDER, r['full_jpeg_name'])]
        if r['filename_raw'].endswith('.xmp'):
            commands += ['darktable-cli "{raw_folder}/{raw_file}" "{raw_root}{xmp}" "{jpeg_root}/{jpeg}" --core -t 8 --configdir "{configdir}" --conf plugins/imageio/format/jpeg/quality=90'.format(
            raw_root=RAW_FOLDER, raw_folder=RAW_FOLDER+r['directory_raw'],
                jpeg_root=JPEG_FOLDER,
                jpeg=r['full_jpeg_name'],
                xmp=r['full_filename'],
                raw_file=r['derivedfrom_raw'],
                configdir=DATA_FOLDER
            )]
        else:
            commands += ['cp "{raw_folder}/{raw_file}" "{jpeg_root}/{jpeg}"'.format(
            raw_root=RAW_FOLDER, raw_folder=RAW_FOLDER+r['directory_raw'],
                jpeg_root=JPEG_FOLDER,
                jpeg=r['full_jpeg_name'],
                raw_file=r['derivedfrom_raw']
            )]

    elif r['action_jpeg'] == 'update_metadata':
        commands += ['# what to do? "{raw_folder}/{raw_file}" "{raw_root}{xmp}" "{jpeg_root}/{jpeg}"'.format(
            raw_root=RAW_FOLDER, raw_folder=RAW_FOLDER+r['directory_raw'],
                jpeg_root=JPEG_FOLDER,
                jpeg=r['full_jpeg_name'],
                xmp=r['full_filename'],
                raw_file=r['derivedfrom_raw']
            )]

    return "\n".join(commands)


def sync():
    """Synchronizes all the changes"""
    print("reading data...")
    data = read_data()


    # Set the default action
    data['raw'][1]['action'] = 'new'
    data['jpeg'][1]['action'] = 'update_metadata'

    raw = pd.concat(data['raw'])
    raw['jpeg_name'] = raw.filename.apply(get_jpeg_name)
    raw['full_filename'] = raw.apply(lambda r: (r['directory'][2:] if r['directory'].startswith('./') else r['directory'][22:])
                                    + '/' + r['filename'], axis=1)
    raw['full_jpeg_name'] = raw.apply(lambda r:
                                    (r['directory'][2:] if r['directory'].startswith('./') else r['directory'][22:])
                                    + '/' + get_jpeg_name(r['filename']), axis=1)
    jpeg = pd.concat(data['jpeg'])
    jpeg['full_jpeg_name'] = jpeg.apply(lambda r:
                                        (r['directory'][2:] if r['directory'].startswith('./') else r['directory'][17:])
                                        + '/' + get_jpeg_name(r['filename']), axis=1)

    print ("Comparing new files with existing files")

    existing_files = set([f[22:] for f in listfiles('/home/fotos/negativos/')])
    raw_files = set(raw['full_filename'])
    to_delete = raw_files - existing_files


    print("Preparing operations...")

    raw['derivedfrom'] = raw['derivedfrom'].fillna(raw['filename'])
    raw_columns = ['make','model','lens', 'lensid', 'aperture', 'exposuretime', 'iso']
    filled = raw.groupby(['directory', 'derivedfrom'])[raw_columns].ffill()
    raw_xmp = raw.copy()
    raw_xmp.loc[:, raw_columns] = filled
    raw_xmp = raw_xmp.groupby(['full_jpeg_name']).last().reset_index()


    merged = pd.merge(raw_xmp, jpeg, on='full_jpeg_name', suffixes=('_raw', '_jpeg'), how='outer')


    commands = merged.apply(process_file, axis=1)

    with open(_this_path + '/autogenerated_commands.sh', 'w') as f:
        f.write("\n".join(commands[commands != '']))
    print("Commands file written")

if __name__ == "__main__":
    print("Sync folder script by Claudio Noguera")
    sync()
