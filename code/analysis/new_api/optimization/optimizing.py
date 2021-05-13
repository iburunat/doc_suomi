#%%
from opt_sa import *
import pandas as pd
path = "/home/pa/Documents/github/doc_suomi/data/new_api_call/analysis/"
#%% Importing data

test = pd.read_csv(f"{path}/ML/test.csv")
test = splitter(test, "album_id")
test = [swap(i, 5)[0] for i in test]

t = pd.read_csv(f"{path}/ML/transition_matrices.csv")
#%% #Empirical transition matrices
tm_v = t['valence'].tolist()
tm_e = t['energy'].tolist()
tm_l = t['loudness'].tolist()
tm_t = t['tempo'].tolist()

tm = [tm_v, tm_e, tm_l, tm_t]
# %%
# resultados = []
historicos = []
count = 0
for k in range(917, len(test)):
    r, h, _, _ = opt(test[k],
                   likelyhood = likelyhood,
                   tm = tm,
                   swap = swap,
                   Temperature= 5,
                   outer = 300,
                   cooling = 0.2,
                   n = 10) 
    # resultados.append(r)
    r.to_csv(f"/home/pa/Documents/github/doc_suomi/data/new_api_call/analysis/optimization/re_ordered/{k}.csv")
    # historicos.append([h[0], maior])
    count = count+1
    print("----------------------------------------------------------")
    print("----------------------------------------------------------")
    print("Album ", count, "/", len(test[k]), "| fomos de ", h[0], "para ", likelyhood(r, tm))
    print("----------------------------------------------------------")
    print("----------------------------------------------------------")
# %%
# final = pd.concat(resultados)

#%%
final.to_csv("reordered.csv")
















#%%
final.to_csv("reordered.csv")

#%% ########### EVAL
dt = pd.read_csv("/home/pa/Documents/github/doc_suomi/data/optimization/reordered.csv")
gt = pd.read_csv("/home/pa/Documents/github/doc_suomi/data/optimization/data_discrete.csv")

variables = ["album_id", "track_number", "valence", "energy", "loudness", "tempo"]

gt = gt[variables]
gt = splitter(gt, "album_id")
gt = gt[round(len(gt)*0.8) : len(gt)]

gt = pd.concat(gt)

#%%
gt.to_csv("original.csv")






#%%
print(result)
plt.plot(history)
plt.show()
plt.plot(temp)
plt.show()
print(result)

# %%


