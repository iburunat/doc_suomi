#%%
from api_methods import *
import os
path = "/home/pa/Documents/github/doc_suomi/data/new_api_call/discographies/"

#%%
# Running query 
genres = ["bebop", "bossa", "edm", "axe", 
          "rock", "pop", "reggae", "country", 
          "jazz", "cool", "folk", "indie", 
          "mpb", "forro", "sertanejo", "tango", 
          "free", "swing", "neurofunk", "american", 
          "latin", "fusion", "ragtime", "bolero", 
          "zouk", "cumbia", "metal", "reggaeton", "polo",
          "celtic", "ska", "fado", "timba", "grunge", 
          "sludge", "mariachi"]

all_genres = [query_genre(i) for i in genres]
pd.concat(all_genres).to_csv("/home/pa/Documents/github/doc_suomi/data/new_api_call/genre_api.csv", index = False)

#%%
for i in all_genres:
    for k in i['id']:
        try:
            describing_tracks(k)
        except:
            print("artist failed")
    print("Finished genre. Requesting new token...")
    #renews API token 
    resp = requests.post(url, headers = req_header, data = payload)
    token = resp.json()
    print("Done with request. New token added...")
    header = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": f"Bearer {token['access_token']}"
    }

# %%
