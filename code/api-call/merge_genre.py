#%%
import os
import pandas as pd

path = "/home/pa/Documents/github/doc_suomi/data/new_api_call/discographies/"
#%%
arr = os.listdir(path)
list_discographies = pd.concat([pd.read_csv(f"{path}{f}") for f in arr])
genre = pd.read_csv("/home/pa/Documents/github/doc_suomi/data/new_api_call/genre_api.csv")

list_discographies = list_discographies.rename(columns={"name": "album_name"})
genre = genre.rename(columns={"name": "artist_name"})
genre.drop_duplicates(subset = "artist_name", keep=False,inplace=True)

merged = list_discographies.merge(genre[['artist_name', 'popularity', 'genres', 'id']], on = "artist_name", how = "outer")
merged = merged[merged['valence'].notna()]
# %%
merged.to_csv("/home/pa/Documents/github/doc_suomi/data/new_api_call/raw_api_result.csv", index = False)
# %%
