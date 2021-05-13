setwd("/home/pa/Documents/github/doc_suomi/code")
source("utils.R")
source("data_cook.R")
cat(howto_data)

path = "/home/pa/Documents/github/doc_suomi/data/new_api_call/analysis"

glob = base_global()
glob = glob %>%
     group_by(album_id) %>%
     mutate(valence = greater(valence),
            energy = greater(energy),
            loudness = greater(loudness),
            tempo = greater(tempo))
