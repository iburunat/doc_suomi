#%%
from youtube_dl import YoutubeDL
import requests
from spotify_auth import *
import pandas as pd
#%%
# Download audio from youtube. 
def youtube_to_audio(link: str, format: str):
    ydl_opts = { 'format': 'bestaudio/best',
                 'postprocessors': [{
                    'key': 'FFmpegExtractAudio',
                    'preferredcodec': format,}],}
    with YoutubeDL(ydl_opts) as ydl:
        ydl.download([link])

def string_formatter(s: str):
    strArr = list(s)
    for i, c in enumerate(strArr):
        if c == ' ': strArr[i] = '%20'
    return "".join(strArr).lower()

#Get respective spotify IDs for each song
def to_spotify_id(artist: str, track: str, header: dict):
    try:
        artist = string_formatter(artist)
        track = string_formatter(track)
        query = f"https://api.spotify.com/v1/search?q=track:{track}%20artist:{artist}&type=track&limit=1"
        obj = requests.get(query, headers = header).json()
        return pd.DataFrame(obj['tracks']['items'])[['href', 'id', 'popularity']]
    except:
        return pd.DataFrame({'href': ["fail"], "id": ["fail"], "popularity": ["fail"]})

def audio_analysis(tracks: list):
    track_description = [requests.get(f"https://api.spotify.com/v1/audio-features/{i}", headers = header).json() for i in tracks]
    return track_description
# %%

to_spotify_id("Joao Bosco", "jade", header)
# %%
