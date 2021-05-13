#%%
import os
import pandas as pd

path = "/home/pa/Documents/github/doc_suomi/data/new_api_call"
glob = pd.read_csv(f"{path}/final/global.csv")
#%%
# Reading all low-level data
arr = os.listdir(f"{path}/low_tracks")
low_list = [pd.read_csv(f"{path}/low_tracks/{i}") for i in arr]
low_list = pd.concat(low_list)

# Renaming duplicated column names
low_list = low_list.rename(columns={"loudness": "loudness_section", 
                                    "tempo": "tempo_section", 
                                    "mode": "mode_section",
                                    "time_signature": "time_signature_section",
                                    "time_signature_confidence": "time_signature_confidence_section",
                                    "mode_confidence": "mode_confidence_section",                                    "key": "key_section",
                                    "key_confidence": "key_confidence_section",
                                    "tempo_confidence": "tempo_confidence_section"
                                    })
# %%
# Merging data frames
# Tracks without low level information are kept, but will show NAs
merged = glob.merge(low_list, on = "track_id", how = "outer")
merged.to_csv(f"{path}/final/low_global.csv", index = False)
