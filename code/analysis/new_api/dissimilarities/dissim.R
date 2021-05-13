setwd("/home/pa/Documents/github/doc_suomi/code")
source("utils.R")
source("data_cook.R")

path = "/home/pa/Documents/github/doc_suomi/data/new_api_call/producers/track_descriptors/"
file = "final_global_producers.csv"

base = producers()
base = album_splitter(base)

original = c()
for(i in 1:length(base)){
  d = data.frame(dissim(base[[i]]))
  # d$condition = "original"
  original[[i]] = d
  # name = paste("/home/pa/Documents/github/doc_suomi/data/new_api_call/analysis/dissimilarities/images/", i, ".csv", sep = "")
  # write.csv(d, file = name, row.names = FALSE)
}

random = c()
for(i in 1:length(base)){
  # d = track_sb(base[[i]]) #for low
  d = sample_n(base[[i]], nrow(base[[i]]))
  d = dissim(d)
  # d$condition = "random"
  random[[i]] =  d
  random[[i]] = d
  # name = paste("/home/pa/Documents/github/doc_suomi/data/new_api_call/analysis/dissimilarities/images/", 5217+i, ".csv", sep = "")
  # write.csv(d, file = name, row.names = FALSE)
}

dissim_visu(original[[2]])



m = lapply(m, dissim_normalizer)
rm = lapply(rm, dissim_normalizer)

i = 15
dissim_visu(m[[i]])
dissim_visu(rm[[i]])