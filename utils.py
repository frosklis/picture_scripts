import numpy as np
import os


def var2int(x):
    """Converts x to an int, np.nan otherwise"""
    try:
        return int(x)
    except:
        return np.nan


def listfiles(folder):
    """Equivalent of 'find .'"""
    for root, folders, files in os.walk(folder):
        for filename in files:
            yield os.path.join(root, filename)
