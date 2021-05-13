library(ggplot2); library(dplyr); library(randomForest); 
library(foreign); library(caret); library(data.table); library(cluster); library(DescTools); 
library(lattice); library(magrittr);library(markovchain); library(tidyr)


# install.packages(c("ggplot2", "dplyr", "randomForest", "foreign", "caret", "data.table", "cluster", "DescTools", "lattice", "magrittr", "markovchain", "tidyr"))
###################################################
############ DATA PROCESSING UTILS ################
###################################################
#Functions
z <- function(x){ 
    return((x-mean(x))/sd(x))
    }

rounder <- function(x){  
    ifelse(x %% 1 == .5, sample(c(floor),1)[[1]](x), round(x))
    }

segment <- function(x, sections, labels){
        return(lsr::quantileCut(x, sections, labels = labels))
        }

minmax <- function(x, min, max) { return(scales::rescale(x, to=c(min,max))) }

count <- function(x){ 
    count = 0 
    for(i in x){ if(i == 1){count = count+1}} 
    return(count/length(x)) 
    }

entropy = function(probs){
    v = c()
    for(i in 1:length(probs)){
        v = c(v, -(probs[i]*log2(probs[i])) )
    }
    return(sum(v))
}

   transProb = function(x, tm){
        if(x[1] == "greater" & x[2] == "greater"){
            return(tm[1])}
        if(x[1] == "greater" & x[2] == "smaller"){
            return(tm[2])}
        if(x[1] == "smaller" & x[2] == "greater"){
            return(tm[3])}
        if(x[1] == "smaller" & x[2] == 'smaller'){
            return(tm[4])}
        if(x[1] == "start"   & x[2] == 'greater'){
            return(tm[5])}
        if(x[1] == "start"   & x[2] == 'smaller'){
            return(tm[6])}
        }

    likelyhood = function(x, tm){
        final = c("start")
        for(i in 1:(length(x)-1)){
            final[i+1] = transProb(x[i:length(x)], tm)
        }
        return(final)
    }

    matrix_extraction = 
        function(x){
            return(c(x[1, 1], x[1, 2], x[2, 1], x[2, 2], x[3, 1], x[3, 2]))
        }
    
    matrix_writer = function(x, path){
        name1 = c("greater", "greater", "smaller", "smaller", "start", "start")
        name2 = c("greater", "smaller", "greater", "smaller", "greater", "smaller")     
        final = data.frame(
            state1 = name1,
            state2 = name2,
            valence = matrix_extraction(x[[1]]),
            energy = matrix_extraction(x[[2]]),
            loudness = matrix_extraction(x[[3]]),
            tempo = matrix_extraction(x[[4]]))
        write.csv(final, paste(path, "/transition_matrices.csv", sep = ""))
    }
    
    
    
    tm_v = c(0.3205376, 0.6794624, 0.6677269, 0.3322731, 0.5336611, 0.4663389)
    tm_e = c(0.3118086, 0.6881914, 0.6616254, 0.3383746, 0.5075643, 0.4924357)
    tm_l = c(0.3223561, 0.6776439, 0.6515744, 0.3484256, 0.5279879, 0.4720121)
    tm_t = c(0.3328422, 0.6671578, 0.6619533, 0.3380467, 0.5075643, 0.4924357)



#################################################
############ Dissimilarity matrices #############
#################################################
# Optimization eval
special_shuffler = function(x){
    bottom = sample_n(x[2:nrow(x), ], nrow(x)-1)
    up = x[1, ]
    return( dplyr::bind_rows(up, bottom) )
}

direction_counter = function(x){
    acerto = 0
    for(i in 1: (length(x)-1) ){
        if( (x[i]+1) == x[i+1] ){
            acerto = acerto + 1  
        }
    }
    return(acerto)
}

match = function(x, y){
    count = 0
    for(i in 1:(length(x)-1)){
        if(  (x[i] == x[i+1]) && (y[i] == y[i+1]) ){
            count = count+1
        }
        if(  (x[i] != x[i+1]) && (y[i] != y[i+1]) ){
            count = count+1
        }
    }
    return (count/(length(x)-1))
}

#Random shuffle for tracks within albums. Keeps order within track, disrupts within album.
track_sb = 
    function(x){
        x %<>% 
            track_splitter()
        x = sample(x, length(x))
        x = bind_rows(x)
        return(x)
    }

dissim = function(x){ 
    ids = x$track_id
    x %<>%
        ungroup() %>%
        # select(c(`0`, `1`,`2`,`3`,`4`,`5`,`6`,`7`,`8`,`9`,`10`,`11`)) %>%
        select_if(is.numeric)
    i = x %>%
        daisy() %>% as.matrix() %>% data.frame()
    # i$track_id = ids
    return(i)
}

#receives dissim matrix and normalized based on within dissimilarity levels/
dissim_normalizer = function(album){
    album %>%
        group_by(track_id) %>%
        summarise_all(mean) %>%
        t() %>%
        data.frame() %>%
        mutate(track_id = c("track_id", album$track_id) ) -> x
    
    diag = function(x){
        d =  c()
        for(i in 1:length(x)){
            d[i] = x[i, i]
        }
        return(unlist(d))
    }
    
    rownames(x) = NULL
    colnames(x) =  as.matrix(unname(x[1, ]))
    x = x[2:nrow(x), ]
    x %>% 
        group_by(track_id) %>%
        mutate_if(is.factor, function(x){as.numeric(as.character(x))}) %>%
        summarise_all(mean) -> x
    
    x = tibble(track_id = x$track_id,
               d   = diag(x[, 2:ncol(x)]))
    
    plyr::join(album, x) -> x
    kernell = function(y){
        return(y-x$d)
    }
    
    x %>%
        mutate_if(is.numeric, kernell) -> x
    return(x)
}

dissim_visu = function(x){
    x %>%
        #select(!track_id) %>%
        # select(!c(track_id, d)) %>%
        select_if(is.numeric) %>%
        as.matrix() %>%
        levelplot(col.regions = colorRampPalette(c("red", "black"))(100))
}


greater = function(x){
    final = c('start')
    for(i in 1:(length(x)-1)){ 
        if(x[i+1] > x[i]){
            final = c(final, 'greater')            
        } else{
            final = c(final, 'smaller')
        }
    }
    return(final)
}



greater2 = function(x){
    final = c()
    for(i in seq(2, length(x)-1, 2)){
        if(x[i+1] > x[i]){
            final = c(final, 'greater')            
        }
        if(x[i+1] < x[i]){
            final = c(final, 'smaller')
        }
        if(x[i+1] == x[i]){
            final = c(final, 'same')
        }
    }
    return(final)
}


album_splitter = function(data){
    data %<>% split(data$album_id) 
    return(data)
}
track_splitter = function(data){
    data %<>% split(data$track_id) 
    return(data)
}

#element-wise matrix calculator
matrix_parser <- function(matrix_list, FUN){
    return(apply(simplify2array(matrix_list), 1:2, function(x){FUN(x)}))
}


# arr: array com transições; mo: empirically derived markov object, returns log likelihood of arr
ll = function(mo, arr){ t <- log(transitionProbability(mo, arr[1], arr[2]))
                        return( if( length(arr) == 2 ) t else t + ll(mo, arr[2:length(arr)]) )}

ll2 = function(mo, arr){
    album = c()
    for(i in 1:(length(arr))-1){
        album[i] = transitionProbability(mo, arr[i], arr[i+1])
    }
    return(c(0, album))
}


# get the mean likelihood of playlist
mll = function(mo, arr){ return (ll(mo, arr)/length(arr)) }

bi = function(x){
    f = c() 
        for(i in 1:(length(x)-2)){
            f = c(f, paste(x[i], x[i+1], sep = "-"), x[i+2])            
        }
    return(f)
}


##################

#LSTM setup
# model = keras_model_sequential() %>% 
#     layer_lstm(
#         units = 124,
#         batch_input_shape = c(1, 1, 8),
#         dropout = 0.2,
#         recurrent_dropout = 0.5,
#         return_sequences = TRUE,
#         stateful = TRUE
#   ) %>%

#    layer_dense(units=16, activation="linear") %>%
#    layer_lstm(units = 8,return_sequences = TRUE, stateful = FALSE) %>%
#    layer_dense(units=1, activation="linear")
 
# model %>% compile(
#    loss = "mse",
#    optimizer =  "adam", 
#    metrics = list("mean_absolute_error")
#  )

# # Function receives data and returns fitted model
# lstm = function(var_interest, var_pred, model, treino, teste){
#         nfeatures = ncol(treino[, pred_vars])
#         y.treino = array(treino[, var_interest], dim = c(nrow(treino), 1, 1))
#         x.treino = array(treino[, var_pred], dim = c(nrow(treino), 1, 8))
#         y.teste =  array(teste[, var_interest], dim = c(1, 1, nrow(teste)))
#         x.teste =  array(teste[, var_pred], dim = c(1, nfeatures, nrow(teste)))
    
#     model %>% fit(x.treino, 
#                   y.treino, 
#                   epochs = 100,verbose = 0)
#     return(model)
# }

# model_eval = function(model_fitted, x.teste, y.teste){
#     pre = predict(model_fitted, x.teste)
#     return(Metrics::rmse(pre, y.teste))    
# }

##################

# #### data LSTM
# inter = fread("interpolated/nn_interpol.csv")
# colnames(inter) <- c("index", "valence", "energy", "loudness", "tempo", "album_id", "track_number")

# lstm_data = inter %>% group_by(album_id) %>%
#             mutate(position = segment(track_number)) %>%
#             group_by(album_id, position) %>%
#             mutate(track_number = seq(1, NROW(track_number), 1), 
#                    position = as.factor(position)) %>% ungroup() %>%
#             mutate(valence = minmax(valence), energy = minmax(energy), 
#                    loudness = minmax(loudness), tempo = minmax(tempo), 
#                    track_number = minmax(track_number)) %>% ungroup() %>% group_by(album_id) %>%
#             mutate(valence_next = shift(valence, -1), energy_next = shift(energy, -1), 
#                    loudness_next = shift(loudness, -1), tempo_next = shift(tempo, -1)) %>%
#             ungroup() %>% na.omit() %>%
#             mutate(position = as.factor(position)) %>%
#             fastDummies::dummy_cols(select_columns = "position", remove_selected_columns = TRUE)

# #Train test split
# treino_lstm = treino_teste(lstm_data)$train
# teste_lstm = treino_teste(lstm_data)$test

# treino_lstm = apply(as.matrix(lstm_data), 2, as.numeric)
# teste_lstm = apply(as.matrix(lstm_data), 2, as.numeric)

r2 = function(var_interest, pred_vars, model, data){
        pred = predict(model, data[, pred_vars])
        true = data[, var_interest]
    
        rss <- sum((pred - true) ^ 2)
        tss <- sum((true - mean(true)) ^ 2)
    
        r2 = 1-rss/tss
    
    return(r2)
}
setwd("/home/pa/Documents/github/doc_suomi/code")