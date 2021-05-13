setwd("/home/pa/Documents/github/doc_suomi/code")
source("utils.R")
source("data_cook.R")
cat(howto_data)
require("stringdist")

stringsimilarity = function(item, lista, FUN){
  sim = c()
  for(i in 1:(length(lista) - 1)){
    sim[i] = FUN(item, lista[i])    
  }
  return(sim)
}

similar = function(x){
  final = c()
  for(i in 1:length(x)){
    final = c(final, list(stringsimilarity(item = x[i], lista = x[i:length(x)], FUN = stringsim)))      
  }
  return(final)
}

verifier = function(x){
  item_par = c()
  for(i in 1:length(x)){
    pares = which(x[[i]] >= 0.8) + (i-1)
    item_par = c(item_par, list(pares))
  }
  return(item_par)
}

calc_out = function(x){
  t = similar(x)
  t = verifier(t)
  return(t)
}

base = base_global()
final = 
  base %>% filter(track_number == 1) %>%
  ungroup() %>%
  arrange(name)

similarity_list = calc_out(final$name)
final$similarity = similarity_list

#Tagging names
final %<>%
    #select(album_id, similarity) %>%
    mutate(similarity_filter = lapply(similarity, function(x){length(x) > 1}))

ha = c()
for(i in 1:length(final$similarity)){
  replicas_index = final$similarity[[i]]
  ha[[i]] = paste(final$name[replicas_index], collapse = "###")
}

final$nomes_similarity = ha

final %>% 
  filter(similarity_filter == TRUE) %>%
  select(album_id, nomes_similarity, similarity) %>% View()
  
final[c(3753, 3763), ]$album_length


base %>% filter(track_number == 6) %>% 
  arrange(energy) -> oi

similarities = stringsimilarity(oi2$valence, all.equal)
pares = sort(c((which(similarities == TRUE) +1), which(similarities == TRUE)))
oi[pares, ] %>% select(valence, album_id, name) %>% View()