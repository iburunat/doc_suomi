#%%
import pandas as pd
from api_methods import *
import os
path = "/home/pa/Documents/github/doc_suomi/data/new_api_call/producers/"
file = "ids_query_results.csv"
# %%
base = pd.read_csv(f"{path}{file}")
track_ids = [tracks_albums(base['id'][i]) for i in range(len(base['album_query']))]
track_ids = pd.concat(track_ids)
track_ids.reset_index(inplace = True)
#%%
base = base.merge(track_ids, left_on = "id", right_on = "album_id", how = "right")
#%%
for i in range(len(track_ids['track_id'])):
    try:
        a = pd.DataFrame(audio_analysis(track_ids['track_id'][i]))
        a['album_id'] = track_ids['album_id'][i]
        a['track_number'] = track_ids['track_number'][i]
        a.to_csv(f"{path}track_descriptors/tracks_{i}.csv")
        print(f"terminou a track{i} do album {track_ids['album_id'][i]}")
    except:
        print(f"falhou no {i}")

#%%
global_analysis = audio_analysis(track_ids['track_id'])
global_analysis = pd.DataFrame(global_analysis)

# %%
base = base.merge(global_analysis, left_on = 'track_id', right_on = 'id', how = 'outer')

#
base.to_csv(f"{path}final_global_producers.csv")
# %%
