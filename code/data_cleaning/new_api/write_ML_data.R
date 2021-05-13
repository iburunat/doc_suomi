setwd("/home/pa/Documents/github/doc_suomi/code")
source("utils.R")
source("data_cook.R")
cat(howto_data)

#Previous data:
#base = base_global()

#Producers
base = producers()

base = base %>%
        mutate(condition = "original")

random = data.table::copy(base)
random = random %>% 
  group_by(album_id) %>%
  sample_n(length(valence)) %>%
  mutate(condition = "random")

base = bind_rows(base, random); random = c()
base = data.frame(base)

base = base %>%
  filter(album_id != "2zUpKJnQgl3YMUJ4dqYo61") %>%
  group_by(album_id, condition) %>%
  mutate(valence_cat = greater(valence),
         energy_cat = greater(energy),
         loudness_cat = greater(loudness), 
         tempo_cat = greater(tempo))

#Train-test split
albums = unique(base$album_id)
train = sample(albums, round(length(albums)*0.80))
dt_train = base %>% filter(album_id %in% train)
dt_test = base %>% anti_join(dt_train, by = 'album_id')

matrix_train = dt_train %>% filter(condition == "original")

features = c("valence_cat", "energy_cat", "loudness_cat", "tempo_cat")
#Getting list for training
variables = c("valence", "energy", "loudness", "tempo")
for(i in 1:length(features)){
  splitted = split(matrix_train[features[i]], matrix_train["album_id"])
  splitted = lapply(splitted, function(x){x[[1]]})
  assign(variables[i], splitted)
}

#Creating Markov Objects
states = as.character(c("smaller", "greater", "start"))

variables = c("v", "e", "l", "t")
values = list(valence, energy, loudness, tempo)
for(i in 1:length(values)){
  tm = data.frame(markovchainFit(data = values[[i]])$estimate@transitionMatrix)
  tm = new("markovchain", states = states, transitionMatrix = matrix(data = as.vector(t(tm)), byrow = TRUE, nrow = nrow(tm)), name = variables[i])
  assign(variables[i], tm)            
}

######### Using transition matrices to describe data
mll2 = function(x){
  return = sum(log(x))/length(x)
}

dt_train = 
     dt_train %>%
      group_by(album_id, condition) %>%
      mutate(valence_cat = ll2(v, valence_cat),
             energy_cat = ll2(e, energy_cat),
             loudness_cat = ll2(l, loudness_cat),
             tempo_cat = ll2(t, tempo_cat)) %>%
  
      filter(valence_cat != 0) %>%
  
      mutate(valence_o = mll2(valence_cat), 
             energy_o = mll2(energy_cat),
             loudness_o = mll2(loudness_cat),
             tempo_o = mll2(tempo_cat))

dt_test =
  dt_test %>%
  group_by(album_id, condition) %>%
  mutate(valence_cat = ll2(v, valence_cat),
         energy_cat = ll2(e, energy_cat),
         loudness_cat = ll2(l, loudness_cat),
         tempo_cat = ll2(t, tempo_cat)) %>%
  
  filter(valence_cat != 0) %>%
  
  mutate(valence_o = mll2(valence_cat), 
         energy_o = mll2(energy_cat),
         loudness_o = mll2(loudness_cat),
         tempo_o = mll2(tempo_cat))

write.csv(dt_train, "/home/pa/Documents/github/doc_suomi/data/new_api_call/analysis/ML/train_producers.csv")
write.csv(dt_test, "/home/pa/Documents/github/doc_suomi/data/new_api_call/analysis/ML/test_producers.csv")


#Sanity check ---> OK
#train = fread("/home/pa/Documents/github/doc_suomi/data/new_api_call/analysis/ML/train.csv")
#test = fread("/home/pa/Documents/github/doc_suomi/data/new_api_call/analysis/ML/test.csv")






