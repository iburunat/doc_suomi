#%%
import pandas as pd
from api_methods import *
import os
path = "/home/pa/Documents/github/doc_suomi/data/new_api_call/producers/"
file = "query_producers.csv"

def query_album(album_name, artist_name):
    oi = requests.get(f"https://api.spotify.com/v1/search?q=album:{album_name}%20artist:{artist_name}&type=album", headers = header).json()
    return oi

def info(d, index):
    a = d['albums'][index]
    yi = d['year'][index]-2
    yf = d['year'][index]+1
    art = d['artist'][index]
    return query_album(a, art)

def spaceReplace(s):
    strArr = list(s)
    for i, c in enumerate(strArr):
        if c == ' ': strArr[i] = '%20'
    return "".join(strArr).lower()

data = pd.read_csv(f"{path}{file}")

data['albums'] = data['albums'].apply(spaceReplace)
data['artist'] = data['artist'].apply(spaceReplace)
# %%
t = [info(data, i) for i in range(len(data['albums']))]
# %%
albums = []
for i in range(len(t)):
    try:
        a = pd.DataFrame(t[i]['albums']['items'])[['id', 'name']]
        a['artist_query'] = data['artist'][i]
        a['album_query'] = data['albums'][i]
        a['producer_query'] = data['producer'][i]
        albums.append(a)
    except:
        a = [{'id': 'faltou', 'name':'faltou', 'artist_query': data['artist'][i], 'album_query': data['albums'][i], 'producer_query': data['producer'][i]}]
        a = pd.DataFrame(a)
        albums.append(a)
# %%
albums = pd.concat(albums)
albums = albums.loc[albums['album_query'] == albums['name'].apply(spaceReplace)]

# %%
# albums.drop_duplicates(subset=['name'], inplace = True)
albums = albums.reset_index().drop(columns = 'index')
# %%
albums.to_csv("/home/pa/Documents/github/doc_suomi/data/new_api_call/producers/ids_query_results.csv")
