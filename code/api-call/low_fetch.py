#%%
from api_methods import *
path = "/home/pa/Documents/github/doc_suomi/data/new_api_call"
# %%
glob = pd.read_csv(f"{path}/final/global.csv")
tracks = [i for i in glob['track_id']]
# %%
for i in range(106187, len(tracks)):
    low_analysis(tracks[i]).to_csv(f"{path}/low_tracks/{i}.csv")
    print("finished", i/len(tracks), "%")
# %%