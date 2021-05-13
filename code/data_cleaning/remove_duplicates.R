setwd("/home/pa/Documents/github/doc_suomi/code")
source("utils.R")
source("data_cook.R")

#Duplicates by name
base = fread("/home/pa/Documents/github/doc_suomi/data/new_api_call/raw_api_result.csv") %>%
       mutate(album_name = tolower(album_name))
ar = base %>% filter(track_number == 1)

deluxe     = ar[grepl("Deluxe", ar$album_name, ignore.case = TRUE), ]$album_id
ao_vivo    = ar[grepl("ao vivo", ar$album_name, ignore.case = TRUE), ]$album_id
remastered = ar[grepl("remaster", ar$album_name, ignore.case = TRUE), ]$album_id
live       = ar[grepl("live", ar$album_name, ignore.case = TRUE), ]$album_id
special    = ar[grepl("special edition", ar$album_name, ignore.case = TRUE), ]$album_id
out        = unique(c(deluxe, ao_vivo, live, special, remastered))

base %<>% filter(!album_id %in% out)
base %>% 
    filter(track_number == 1) %>%
    distinct(album_name, .keep_all = TRUE) %>% 
    select(album_id) -> uniques

uniques = unname(unlist(uniques))
base %<>% filter(album_id %in% uniques)


# Replicates based on feature similarity and album name's edit distance
oi = function(x){
            final = c()
            for(i in 1:(length(x)-1)){
                final[i] = (x[i+1] - x[i])
            }
            return(c(final, 'nada'))
        }

base %>%
    group_by(album_id) %>%
    summarise(overall = sum(valence, energy, loudness, tempo), 
              name = unique(album_name)) %>%
    arrange(overall, name) %>%
    mutate(dif = oi(overall)) %>%
    mutate(edistance = adist_c(name)) %>% 
    filter(dif == 0) %>%
    select(album_id) -> zero_differences

zero_differences = unname(unlist(zero_differences))
base %<>% filter(!album_id %in% zero_differences)

base %>% write.csv("/home/pa/Documents/github/doc_suomi/data/new_api_call/final/global.csv")