#setwd("/home/pa/Documents/github/doc_suomi/data/treated_data")

#raw = fread("data.csv") %>% dplyr::select(!V1) %>%
#        group_by(album_id, name, track_number) %>%
#        summarise(valence = mean(valence), energy = mean(energy), 
#                  loudness = mean(loudness), tempo = mean(tempo)) %>%
#        mutate(album_length = NROW(track_number)) %>% ungroup() %>%
#        filter(album_length %in% c(6:16))

############### Base for work
#base = function(){
#        raw %<>% group_by(album_id) %>% filter(!album_id %in% c("2jxyIfyUY0yhPANWWrwnca", "4upuFjlQaEYaWyTWWaNBuq", "72vAPCga5Z8jT6NOxGrxpd")) %>%
#                mutate(section = segment(track_number)) %>%
#                dplyr::select(album_id, album_length, track_number, valence, energy, loudness, tempo, danceability, mode, key, name)
#        return(raw)
#}

#z_scored = function(){
#        raw %<>% group_by(album_id) %>%
#        dplyr::select(album_id, album_length, track_number, valence, energy, loudness, tempo) %>%
#        mutate(album_length = NROW(track_number), section = segment(track_number), 
#              valence = z(valence), energy = z(energy), 
#              loudness = z(loudness), tempo = z(tempo) ) %>%
#       group_by(track_number, album_id) %>%
#       arrange(album_id) %>% ungroup()
#       return(raw)
#}

#min_maxed = function(){
#        raw %<>% group_by(album_id) %>%
#        dplyr::select(album_id, album_length, track_number, valence, energy, loudness, tempo) %>%
#        mutate(section = segment(track_number), valence = minmax(valence),
#               energy = minmax(energy), loudness = minmax(loudness), tempo = minmax(tempo) ) %>%
#        group_by(track_number, album_id) %>%
#        arrange(album_id) %>% ungroup()
#        return(raw)
#}

############################# NEW API CALL ##########################################
#Applying filter to albums with missing tracks and album length
base = fread("/home/pa/Documents/github/doc_suomi/data/new_api_call/final/low_global.csv")

base %<>%
        group_by(album_id) %>%
        mutate(album_length = max(track_number)) %>%
        mutate(n_missing_tracks = sum(is.na(loudness_section))) %>%
        mutate(filter_by_length = album_length < 6 | album_length > 16,
               filter_by_missing = n_missing_tracks > 0) %>%
        arrange(album_id, track_number) %>%
        filter(filter_by_missing == FALSE) %>% 
        filter(filter_by_length == FALSE) %>%
        ungroup() %>% group_by(album_id, track_number) %>%
        mutate(mode_unique = length(unique(mode)) > 1) %>%
        ungroup() %>% group_by(album_id) %>%
        mutate(mode_unique = sum(mode_unique)) %>% 
        filter(mode_unique == 0) %>%
        filter(!album_id %in% c("1ZuKbzUU4Bx1NncAcWRb3Z", "45hgMhLf8GRZ3xUEy6tHCX",  "06hsxtm7Y1gDM5sNliCD5d", "3otkui6GGLYq0O1jD3obAo",
                                "36IMFWSc4Xvq5P49sWOgWn", "2tQqbSAlSD18lkXrRRMETF", "58HJaV7TTJcNOsXQEw5rOD", "0eFxkqkfawfVm1nnMvoGjm", 
                                "29IjcCBllsltvShSWJ40Ol", "0ZyWWWKiRMjXKj0MxKlfnm", "0fbRfalom1JIam05jqDzT3", "2QuYio1K1TNDyJhXKl81wV", 
                                "6xp5RY3QunFCppaLc2zbhH", "29IjcCBllsltvShSWJ40Ol", "1yM8iaMk4Slsqr94LabgN1", "4wbVjK19IjRtnAW1SMuvf3", 
                                "3WlN6A2y1EKdI74XPoqMHt", "4ALt0Is7qXcc0hcIN8suFB", "26TeqFz1sPbJT6VjAbBtzl", "0Bu8cHckHlYn0ZCLvL247y", 
                                "0QSSZDP9Vva4PRT0Dhw759", "5vBI4CfG3c3le21FeP7mCX", "7mUPDed1nkAmg5iNpAKs8m", "7gTbIl4KMgXCivUMLUqXE8", 
                                "79o7LzSfHajtJtli8WsYR2", "6Vdf25otVwddufZWvw6VL0", "6kwvp610NcFpWs521VfMpi", "6jxyESNrzaxPfEs63oIBzc",
                                "16URL1hzoWAJExITzmdzvO", "5o96OkZB5NUyb9URvEDeFT", "5S6piLR8OYNymGIApEC6k4",
                                "5Q9ziMaAwdG9azrfgir0cq", "5mUpTgKcEzfX6to5BReBdE", "5Eevxp2BCbWq25ZdiXRwYd",
                                "5bANLEjBOEPHkMaGTTuFjv", "4Z0l4cuznDAsB2DytEF6uy", "4YvY8BtNomELHU0cdO3kMW", 
                                "4y5v5D7cBVMlgmpW7UqpA1", "4rp1jclowkzH4QyGMg6xTx", "3Aptm7mgonwCtKEN83uDlH", 
                                "4faNbLVqwBF5jMXxJzCTk0", "2mOEPiBndqqHws6BL6iCPz", "2jWb86KojWDnjz4WHOlclL",
                                "1Kom1DjFgiVn5Mol6tciwN", "1jlhnWW4SIS0xsqarDQrUA", "1gJeZZJNXA9OImKj9mT6Uz",
                                "0g0tKXPiuAV63b6ZL25vRk", "0Bu8cHckHlYn0ZCLvL247y")) %>%

        group_by(album_id, track_id) %>%
        mutate(track_segment = seq(1, length(valence), 1))
#min(base$track_length)
#unique(base$album_id[which(base$track_length < 3)])

    base_low = function(){
            base %>%
                    group_by(album_id) %>%
                    mutate(danceability = z(danceability), 
                           energy = z(energy), 
                           loudness = z(loudness), 
                           speechiness = z(speechiness), 
                           acousticness = z(acousticness), 
                           instrumentalness = z(instrumentalness), 
                           liveness = z(liveness),
                           valence = z(valence), 
                           tempo = z(tempo), 
                           loudness_section = z(loudness_section),
                           tempo_section = z(tempo_section), 
                           `0`  = z(`0`),
                           `1`  = z(`1`),
                           `2`  = z(`2`), 
                           `3`  = z(`3`), 
                           `4`  = z(`4`), 
                           `5`  = z(`5`),
                           `6`  = z(`6`), 
                           `7`  = z(`7`), 
                           `8`  = z(`8`), 
                           `9`  = z(`9`),
                           `10` = z(`10`), 
                           `11` = z(`11`)) -> b
            return(b)
    }
    
    
    base_low_edge = function(){
      b = base_low() 
      b %<>%
        group_by(album_id, track_id) %>%
        mutate(track_length = length(track_id)) %>%
        mutate(track_segment = c(seq(1, length(track_id), 1))) %>%
        ungroup()
        b %<>%
          filter(!album_id %in% unique(album_id[which(track_length < 3)])) %>%
          mutate(track_bin = segment(track_segment, 3, c("start", "middle", "end"))) %>% 
          group_by(album_id, track_id, track_bin) %>%
          summarise_if(is.numeric, mean)
        
      return(b)
    }
    
    
    base_global = function(){
            base_low() %>%
            group_by(album_id, track_number) %>%
            summarise(danceability = mean(danceability), 
                     energy = mean(energy), 
                     loudness = mean(loudness), 
                     speechiness = mean(speechiness),
                     acousticness = mean(acousticness),
                     instrumentalness = mean(instrumentalness), 
                     liveness = mean(liveness),
                     valence = mean(valence), 
                     tempo = mean(tempo), 
                     loudness_var = sd(loudness_section),
                     tempo_var = sd(tempo_section),
                     loudness_section_max = max(loudness_section),
                     tempo_section_max = max(tempo_section),
                     `0var`  = sd(`0`), 
                     `1var`  = sd(`1`),
                     `2var`  = sd(`2`), 
                     `3var`  = sd(`3`),
                     `4var`  = sd(`4`), 
                     `5var`  = sd(`5`),
                     `6var`  = sd(`6`), 
                     `7var`  = sd(`7`), 
                     `8var`  = sd(`8`), 
                     `9var`  = sd(`9`),
                     `10var` = sd(`10`), 
                     `11var` = sd(`11`),
                     `0`  = mean(`0`), 
                     `1`  = mean(`1`),
                     `2`  = mean(`2`), 
                     `3`  = mean(`3`),
                     `4`  = mean(`4`), 
                     `5`  = mean(`5`),
                     `6`  = mean(`6`), 
                     `7`  = mean(`7`), 
                     `8`  = mean(`8`), 
                     `9`  = mean(`9`),
                     `10` = mean(`10`), 
                     `11` = mean(`11`),
                     key = unique(key),
                     mode = unique(mode),
                     key_confidence_overall = mean(key_confidence_overall),
                     tempo_confidence_overall = mean(tempo_confidence_overall),
                     popularity = mean(popularity),
                     album_length = unique(album_length),
                     name = unique(album_name)) -> b
            return(b)
    }

########## Machine Learning
train = function(data){
    return(fread( paste("/home/pa/Documents/github/doc_suomi/data/new_api_call/analysis/ML/", data, ".csv", sep = "" ) ))
}

test = function(data){
    return(fread( paste("/home/pa/Documents/github/doc_suomi/data/new_api_call/analysis/ML/", data, ".csv", sep = "") ))
}
    
    
########### Producers
producers = function(){
  producers = fread("/home/pa/Documents/github/doc_suomi/data/new_api_call/producers/track_descriptors/final_global_producers.csv")
  producers = producers %>% 
    select(valence_x, energy_x, loudness_x, tempo_x, 
           album_id, track_number, producer_query)
  colnames(producers) = c('valence', 'energy', 'loudness', 'tempo', 
                          'album_id', 'track_number', 'producer_query')
  return(producers)
}

########### Base with PCA

base_pca = function(x){
  base = base_global() %>% ungroup()
  base %>% select(valence, energy, loudness, tempo) %>%
    prcomp() -> oi
  
  base$factor_1 = oi$x[,1]
  return(base)
}

howto_data = 
        paste("How to use datasets (Personal library)",
                " ",
                "call    base()             for real values", 
                "call    z_scored()         for normalized", 
                "call    min_maxed()        for normalized2", 
                "call    base_low()         for normalized low",
                "call    base_global()      for normalized global",
                "call    train()/test()     for ML tasks", sep = "\n")
