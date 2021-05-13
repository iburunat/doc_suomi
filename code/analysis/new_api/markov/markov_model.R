setwd("/home/pa/Documents/github/doc_suomi/code")
source("utils.R")
source("data_cook.R")
cat(howto_data)

base = base_global() %>% select(album_id, valence, energy, loudness, tempo)
#base = producers() %>% 
#        select(album_id, valence, energy, loudness, tempo) %>%
#        group_by(album_id) %>% mutate(album_length = length(valence)) %>%
#        filter(album_length > 5)

final = c()
for(run in 1:10){

    albums = unique(base$album_id)
    train = sample(albums, round(length(albums)*0.80))
    dt_train = base %>% filter(album_id %in% train)
    dt_test = base %>% anti_join(dt_train, by = 'album_id')
    dr_test = data.table::copy(dt_test)
   
    #Train conversion
    dt_train = dt_train %>% 
        group_by(album_id) %>%
        mutate_if(is.numeric, greater) %>%
        filter(valence != 'start')
    
    #Random conversion
    dr_test = dr_test %>% 
        group_by(album_id) %>%
        sample_n(length(valence)) %>%
        mutate_if(is.numeric, greater) %>%
        filter(valence != 'start')
    
    #Test conversion
    dt_test = dt_test %>% 
        group_by(album_id) %>%
        mutate_if(is.numeric, greater) %>%
        filter(valence != 'start')
    
    features = c("valence", "energy", "loudness", "tempo")
    #Getting list for training
    variables = c("valence", "energy", "loudness", "tempo")
    for(i in 1:length(features)){
        splitted = split(dt_train[features[i]], dt_train["album_id"])
        splitted = lapply(splitted, function(x){x[[1]]})
        assign(variables[i], splitted)
    }
    
    #Getting TrueSequences for for testing
    variables = c("valence_t", "energy_t", "loudness_t", "tempo_t")
    for(i in 1:length(features)){
        splitted = split(dt_test[features[i]], dt_test["album_id"])
        splitted = lapply(splitted, function(x){x[[1]]})
        assign(variables[i], splitted)            
    }

    #Getting RandomSequences for testing
    variables = c("rv", "re", "rl", "rt")
    for(i in 1:length(features)){
        splitted = split(dr_test[features[i]], dr_test["album_id"])
        splitted = lapply(splitted, function(x){x[[1]]})
        assign(variables[i], splitted)            
    }
    
    #Creating Markov Objects
    states = as.character(c("smaller", "greater"))
    
    variables = c("v", "e", "l", "t", "rvm", "rem", "rlm", "rtm")
    values = list(valence, energy, loudness, tempo, rv, re, rl, rt)
    for(i in 1:length(values)){
        tm = data.frame(markovchainFit(data = values[[i]])$estimate@transitionMatrix)
        tm = new("markovchain", states = states, transitionMatrix = matrix(data = as.vector(t(tm)), byrow = TRUE, nrow = nrow(tm)), name = variables[i])
        assign(variables[i], tm)            
    }

    #Displaying results
    result = tibble(True_valence     = unlist(lapply(valence_t, function(x){mll(v, x)})),
                    True_energy      = unlist(lapply(energy_t, function(x){mll(e, x)})),
                    True_loudness    = unlist(lapply(loudness_t, function(x){mll(l, x)})),
                    True_tempo       = unlist(lapply(tempo_t, function(x){mll(t, x)})),
                    
                    Random_valence     = unlist(lapply(rv, function(x){return(mll(v, x))})),
                    Random_energy      = unlist(lapply(re, function(x){return(mll(e, x))})),
                    Random_loudness    = unlist(lapply(rl, function(x){return(mll(l, x))})),
                    Random_tempo       = unlist(lapply(rt, function(x){return(mll(t, x))})),
                    
               #     RandomM_valence     = unlist(lapply(valence_t, function(x){return(mll(rvm, x))})),
            #        RandomM_energy      = unlist(lapply(energy_t, function(x){return(mll(rem, x))})),
             #       RandomM_loudness    = unlist(lapply(loudness_t, function(x){return(mll(rlm, x))})),
             #       RandomM_tempo       = unlist(lapply(tempo_t, function(x){return(mll(rtm, x))})),
                    
        )
    
    result %>% 
        melt() %>% 
        tidyr::separate(variable, c("condition", "feature"), "_") %>%
        group_by(condition, feature) %>%
        summarise(likelihood = mean(value),
                stder = sd(value)/sqrt(length(value))) -> result

     final[[run]] = result
}


oi %>% View()

#Writting data for optimization
path = "/home/pa/Documents/github/doc_suomi/data/new_api_call/analysis/"
#train-test split
write.csv(bind_rows(dt_train), paste(path, "/ML/train.csv", sep = ""))
write.csv(bind_rows(dt_test), paste(path, "/ML/test.csv", sep = ""))

#Transition matrices
matrices = list(v@transitionMatrix, e@transitionMatrix, l@transitionMatrix, t@transitionMatrix)
matrix_writer(matrices, path)

oi = bind_rows(final)
oi %>%
    ggplot(aes(x=likelihood, fill = condition)) +
#        facet_wrap(~feature)+
        geom_density(alpha = 0.8)

oi %>%
    group_by(condition) %>%
    summarise(likelihood = mean(likelihood), stder = mean(stder)) %>%
    ungroup() %>%
    ggplot(aes(x = condition, y = likelihood, color = condition, fill = condition))+
        #facet_wrap(~feature)+
        geom_violin(aes(x = condition, y = likelihood, group = condition, color = condition), trim = FALSE, data = oi, alpha = 0.8)+
        geom_point(color = "black")+
        #geom_boxplot(position = position_dodge(0.2))
        geom_errorbar(aes(ymin = likelihood-stder, ymax = likelihood+stder), width = 0.15, color = 'black')

lm(likelihood~condition*feature, data = oi) %>%
    anova()

oi %>% filter(condition == 'True') %>% select(likelihood) %>% c()   -> emp
oi %>% filter(condition == 'Random') %>% select(likelihood) %>% c() -> rand
t.test(emp$likelihood, rand$likelihood, paired = TRUE)


library(effsize)
cohen.d(emp$likelihood, rand$likelihood, paired = TRUE)

#Empirical matrices
print("Valence"); v@transitionMatrix; 
print("Energy"); e@transitionMatrix; 
print("Loudness"); l@transitionMatrix; 
print("Tempo"); t@transitionMatrix


library(xtable)
xtable(data.frame(v@transitionMatrix))



#Random matrices
print("Random Valence"); rvm; 
print("Random Energy"); rem; 
print("Random Loudness"); rlm; 
print("Random Tempo"); rtm

levelplot((v@transitionMatrix - rvm@transitionMatrix)[1:2, 1:2], col.regions = colorRampPalette(c("red", "black"))(100))
levelplot((e@transitionMatrix - rem@transitionMatrix)[1:2, 1:2], col.regions = colorRampPalette(c("red", "black"))(100))

v