setwd("/home/pa/Documents/github/doc_suomi/code")
source("utils.R")
source("data_cook.R")
cat(howto_data)

glob = base_global()



dt = glob %>%
  group_by(album_id) %>%
  mutate(valence = greater(valence),
         energy = greater(energy),
         loudness = greater(loudness),
         tempo = greater(tempo))