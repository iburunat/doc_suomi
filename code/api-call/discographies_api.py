#%%
import requests
import json
import time
import pandas as pd

key = "sLpcvhgsdWvtMYjYyBPP" 
secret = "VMLBoBYBkvLyAoHTNDJAaIMKQVsipuIz"

def labels(page, label):
    return requests.get(f"https://api.discogs.com/labels/{label}/releases?page={page}&per_page=1000&key={key}&secret={secret}").json()


def query(label_id):
    col = []
    for i in range(1000):
        time.sleep(2)
        try:
            col.append(pd.DataFrame(labels(i, label_id)['releases']))
        except:
            print(f"terminou na página {i}. Fechando label")
            return pd.concat(col)

path = "/home/pa/Documents/github/doc_suomi/data/new_api_call/discog_query/records"
#%%
# ecm = query(6785)
# ecm.to_csv(f"{path}/ecm.csv")

# verve = query(5041)
# verve.to_csv(f"{path}/verve.csv")

# warner = query(1000)
# warner.to_csv(f"{path}/warner.csv")

# biscoito = query(139780)
# biscoito.to_csv(f"{path}/biscoito.csv")

# acid = query(997)
# acid.to_csv(f"{path}/acid_jazz.csv")

# capital = query(654)
# capital.to_csv(f"{path}/capital.csv")

# house = query(791299)
# house.to_csv(f"{path}/house.csv")

# geffen = query(821)
# geffen.to_csv(f"{path}/geffen.csv")

# sony = query(29073)
# sony.to_csv(f"{path}/sony.csv")

# columbia = query(1866)
# columbia.to_csv(f"{path}/columbia.csv")

# rca = query(895)
# rca.to_csv(f"{path}/rca.csv")

# epic = query(1005)
# epic.to_csv(f"{path}/epic.csv")

# 8377 #Island Records 365
# 362 #Artista
# 750 #Virgin
# 681 #Atlantic
# 5131 #Sub Pop Records
# 1104810 #Polygram Entertainment
# 38017 #Republic Records
# 38986 #Spinefarm Records
# 276180 #Universal Music Enterprises
# 1733806 #Universal Music Group Nashville
# 217492 #Universal Music Latin Entertainment
# 92175 #Universal Music Publishing Group





# # %%
# with open('producer_json.txt', 'w') as outfile:
#     json.dump(ecm, outfile)
# %%
