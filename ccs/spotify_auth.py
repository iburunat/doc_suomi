import requests
import base64

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