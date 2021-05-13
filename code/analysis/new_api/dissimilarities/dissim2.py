#%%
from scipy.spatial.distance import pdist, squareform
from PIL import Image 
import os
import seaborn as sns
import matplotlib.pylab as plt
import numpy as np
import pandas as pd
import librosa
import scipy
from librosa import display
#%%
def dissim(x, metric):
    x = np.array(x).reshape(-1, 1)
    dm = scipy.spatial.distance.pdist(x, metric=metric)
    return pd.DataFrame(squareform(dm))

def heatmap2d(arr: np.ndarray):
    plt.imshow(arr, cmap='viridis')
    plt.colorbar()
    plt.show()

#receives data frame, width and length of the output
def nearest(data, w, l):
    data = np.array(data, dtype=np.double)
    convert = Image.fromarray(np.array(data, dtype=np.double)).resize((w, l), Image.NEAREST)
    return np.array(convert)

def bilinear(data, w, l):
    data = np.array(data, dtype=np.double)
    convert = Image.fromarray(np.array(data, dtype=np.double)).resize((w, l), Image.BILINEAR)
    return np.array(convert)


#%%
path = "/home/pa/Documents/github/doc_suomi/data/new_api_call/analysis/dissimilarities/images/"
arr = os.listdir(path)
files = ["".join([path, i]) for i in arr]
data = [pd.read_csv(k).drop(columns = ["track_id", "condition"]) for k in files[1:1000]]
data = [bilinear(i, 200, 200) for i in data]

#%%
data = [librosa.segment.recurrence_matrix(i, mode='affinity', self=True) for i in data]
data = [librosa.segment.path_enhance(i, 50, window='hann', n_filters=1) for i in data]

def sum_matrix(x):
    if len(x) == 2:
        return (x[0]+x[1])
    return (x[0]+x[1]) + mean_matrix(x[1:])

# %%
m = mean_matrix(data)/len(data)

heatmap2d(pd.DataFrame(m).iloc[20:100, 20:100])
# %%
