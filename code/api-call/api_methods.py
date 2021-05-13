import requests
import json
import base64
import pandas as pd
import matplotlib as mt
from random import sample

#Requesting access to the spotify web API
client_id = '16fd6188f83242288e8af5e299bc66dd'
client_secret = '6abc3f8f1a714265a17ad6423066ec43'

auth_header_b64 = base64.b64encode(f'{client_id}:{client_secret}'.encode('ascii'))
auth_header = auth_header_b64.decode('ascii')

req_header =  {'Authorization' : f'Basic {auth_header}'}
payload = {"grant_type": "client_credentials"}
url = "https://accounts.spotify.com/api/token"
resp = requests.post(url, headers = req_header, data = payload)
token = resp.json()

#Defining header with access token
header = {
"Accept": "application/json",
"Content-Type": "application/json",
"Authorization": f"Bearer {token['access_token']}"
}

#Get up to 10 ablbums from artist and return data frame with list of album ids and names
def albums(artist):
    oi = requests.get(f"https://api.spotify.com/v1/artists/{artist}/albums?limit=10", headers = header)
    oi = pd.DataFrame(oi.json()['items'])
    oi = oi[oi['album_group'] == 'album'] #exclude single tracks
    try:
        oi['artist_name'] = oi['artists'][0][0]['name'] #Fetching artist's name
    except: 
        oi['artist_name'] = "no_name"
    oi = oi[['id', 'name', 'release_date', 'artist_name']]
    return oi

#Function to get all tracks from one album
def tracks_albums(album_id):
    varb = requests.get(f"https://api.spotify.com/v1/albums/{album_id}/tracks?limit=50", headers = header)
    raw = pd.DataFrame(varb.json()['items'])
    varb = raw[['track_number']]
    varb['track_id'] = raw['id']
    #Guardando o nome do album:
    varb['album_id'] = album_id
    return varb

#Fetch list of album tracks
def album_to_track(id_artista):
    album_dos_artistas = albums(id_artista)
    tracks = map(tracks_albums, album_dos_artistas['id'])
    oi = map(lambda dt : dt.merge(album_dos_artistas, left_on = 'album_id', right_on = 'id'), tracks)
    return pd.concat(oi).drop(columns = ['id'])

#Getting global audio analysis for a single track
def audio_analysis(tracks):
    oi = [requests.get(f"https://api.spotify.com/v1/audio-features/{i}", headers = header).json() for i in tracks]
    return oi

def low_analysis(track):
    raw = requests.get(f"https://api.spotify.com/v1/audio-analysis/{track}", headers = header).json()
    d = pd.DataFrame(raw['segments'])
    dd = pd.DataFrame(raw['sections'])
    splitter = lambda x: pd.Series([int(i) for i in x])
    dd = dd.merge(d['timbre'].apply(splitter), left_index = True, right_index = True)
    dd['track_id'] = track
    overall = pd.DataFrame(raw['track'], index = [1])[["end_of_fade_in", "start_of_fade_out", "tempo_confidence", "time_signature_confidence", "key_confidence", "mode_confidence"]]
    overall = overall.rename(columns = {"tempo_confidence": "tempo_confidence_overall", "time_signature_confidence":"time_signature_confidence_overall", "key_confidence":"key_confidence_overall", "mode_confidence": "mode_confidence_overall"})
    overall['track_id'] = track
    return dd.merge(overall, right_on = "track_id", left_on = "track_id")


def describing_tracks(artist):
    try:
        tracks = audio_analysis(tracks_artists['track_id'])
        tracks = pd.DataFrame(tracks)
        oi = tracks.merge(tracks_artists, left_on = "id", right_on = 'track_id').drop(columns = ['id'])
        oi.drop(columns = ['analysis_url', 'track_href', 'uri'])
        oi.to_csv(f"/home/pa/Documents/github/doc_suomi/data/new_api_call/{artist}.csv", index = False)
        print("Finished artist")
    except:
        print("failed artist")
#####################################################
################### QUERY METHODS ###################
#####################################################

#Define query
def query_genre(genre):
    oi = requests.get(f"https://api.spotify.com/v1/search?q=genre:{genre}&type=artist&limit=50", headers = header).json()
    oi = pd.DataFrame(oi['artists']['items'])[['popularity', "name", "id", "genres"]]
    oi['genre_defined_by_query'] = genre
    return oi

#returns list of dataframes containing an artist's discography + global audio analysis
def get_albums_from_query(query_result):
    artists = list(query_result['id']) #List of artist's ids
    analysis = [describing_tracks(i) for i in artists]
    return analysis
#%%
def query_album(album_name, inicio, fim, artist_name):
    # oi = requests.get(f"https://api.spotify.com/v1/search?q=album:{album_name}%20year:{inicio}-{fim}%20artist:{artist_name}&type=album", headers = header).json()
    return f"https://api.spotify.com/v1/search?q=album:{album_name}%20year:{inicio}-{fim}%20artist:{artist_name}&type=album"
    return oi
# %%
