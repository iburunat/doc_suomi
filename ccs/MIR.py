#%%
import numpy as np
import pandas as pd
from api_methods import *
#%%
path = "./data/"
file = "ccsData.csv"
data = pd.read_csv(path+file)

# No need to remove participants who didn't indicate a track
# Query will automatically indicate failure in these cases
# data = data.loc[data['Artist'].notna()]
# data = data.loc[data['Track'].notna()]

# %%
#Running query for spotify's IDs
result = pd.concat([to_spotify_id(i, j, header) for i, j in zip(data['Artist'], data['Track'])])
result = result.reset_index().drop(columns = "index")
result = result.merge(data, left_index = True, right_index = True)
#backing_up
result.to_csv("./data/backup_data_id.csv")

# %%
np.sum(result['id'] == 'fail') # There are 502 non-found tracks
#%%
result = result[result['id'] != 'fail'] #filtering failed API requests
result.reindex()

# %%
# description = pd.DataFrame(audio_analysis(result['id']))
description = description.drop_duplicates(subset = 'id')
# %%
result = result.merge(description, on = 'id', how = 'left')

# %%
result.to_csv("./data/dataDescriptors.csv")
# %%
