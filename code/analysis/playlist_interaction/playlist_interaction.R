setwd("/home/pa/Documents/github/doc_suomi/code")
source("utils.R")

# downloads <- c("https://os.zhdk.cloud.switch.ch/swift/v1/crowdai-public/spotify-sequential-skip-prediction-challenge/split-files/training_set_0.tar.gz", 
       #"https://os.zhdk.cloud.switch.ch/swift/v1/crowdai-public/spotify-sequential-skip-prediction-challenge/split-files/training_set_1.tar.gz", 
       #"https://os.zhdk.cloud.switch.ch/swift/v1/crowdai-public/spotify-sequential-skip-prediction-challenge/split-files/training_set_2.tar.gz", 
       #"https://os.zhdk.cloud.switch.ch/swift/v1/crowdai-public/spotify-sequential-skip-prediction-challenge/split-files/training_set_3.tar.gz", 
       #"https://os.zhdk.cloud.switch.ch/swift/v1/crowdai-public/spotify-sequential-skip-prediction-challenge/split-files/training_set_4.tar.gz", 
       #"https://os.zhdk.cloud.switch.ch/swift/v1/crowdai-public/spotify-sequential-skip-prediction-challenge/split-files/training_set_5.tar.gz", 
       #"https://os.zhdk.cloud.switch.ch/swift/v1/crowdai-public/spotify-sequential-skip-prediction-challenge/split-files/training_set_6.tar.gz", 
       #"https://os.zhdk.cloud.switch.ch/swift/v1/crowdai-public/spotify-sequential-skip-prediction-challenge/split-files/training_set_7.tar.gz", 
       #"https://os.zhdk.cloud.switch.ch/swift/v1/crowdai-public/spotify-sequential-skip-prediction-challenge/split-files/training_set_8.tar.gz", 
       #"https://os.zhdk.cloud.switch.ch/swift/v1/crowdai-public/spotify-sequential-skip-prediction-challenge/split-files/training_set_9.tar.gz")

###### unzipei todos os tar do primeiro download
###### li todos e summarizei. Resultado tá no out.
###### agora preciso repetir para os demais arquivos tar no diretorio /media/pa/3E7499C974998475/


# setwd("/media/pa/3E7499C974998475")
# for (url in downloads) {
#     download.file(url, destfile = basename(url))
# }
# files = 

# for(i in list.files("/media/pa/3E7499C974998475")[3:12]){
#     untar(tarfile = i, exdir = "/media/pa/3E7499C974998475")
# }

###################################################################
################ PROCESSING CORRELATIONAL DATA ####################
###################################################################

#Start processing
# interactions = list.files("/media/pa/3E7499C974998475/training_set_1/training_set")
# features = list.files("/media/pa/3E7499C974998475/track_features")
# setwd("/media/pa/3E7499C974998475/track_features")
# f1 = fread(features[1]) 
# f2 = fread(features[2])
# features = bind_rows(f1, f2)

# for(i in 1:length(interactions)){
#     interaction = fread(paste("/media/pa/3E7499C974998475/training_set_1/training_set/", interactions[i], sep = ""))

#     all = merge(features, interaction, 
#                 by.x = "track_id", by.y = "track_id_clean", 
#                 all.y = TRUE)

#     oi = all %>% 
#             group_by(session_id) %>%
#             arrange(session_id, session_position) %>%
#             mutate(filtro = sum(long_pause_before_play)) %>% 
#             filter(filtro == 0) %>% 
#             dplyr::select(valence, energy, loudness, 
#                         tempo, skip_3, session_position, 
#                         session_id) %>%
#             mutate(valence = greater(valence), 
#                 energy = greater(energy), 
#                 loudness = greater(loudness),
#                 tempo = greater(tempo)) %>%
#             mutate(likelyhood_v = likelyhood(valence, tm_v),
#                 likelyhood_e = likelyhood(energy, tm_e),
#                 likelyhood_l = likelyhood(loudness, tm_l),
#                 likelyhood_t = likelyhood(tempo, tm_t)) %>%
#             filter(valence != 'start') %>% 
#             dplyr::summarise(lv = mean(log(as.numeric(likelyhood_v)), na.rm = TRUE),
#                     le = mean(log(as.numeric(likelyhood_e))),
#                     ll = mean(log(as.numeric(likelyhood_l))),
#                     lt = mean(log(as.numeric(likelyhood_t))), 
#                     overall = mean(c(lv, le, ll, lt)), 
#                     not_skipped = sum(skip_3)/length(skip_3))

#     write.csv(oi, paste("/media/pa/3E7499C974998475/out/out3", i, ".csv", sep = "s"))
# }


# #uniting outputs
# files = list.files("/media/pa/3E7499C974998475/out")
# out = c()
# for(i in 1:length(files)){
#     out[[i]] = data.frame(fread(paste("/media/pa/3E7499C974998475/out/", files[i], sep = "")))
# }

# out = bind_rows(out)

# ggplot(data = out, aes(x = overall, y = not_skipped))+
#        geom_bin2d()+
#        geom_smooth(formula = "y ~ x")



###############################################################################
#######################  PROCESSING CATEGORICAL DATA ##########################
###############################################################################

# interactions = list.files("/media/pa/3E7499C974998475/training_set_0/training_set")
# features = list.files("/media/pa/3E7499C974998475/track_features")
# setwd("/media/pa/3E7499C974998475/track_features")
# f1 = fread(features[1]) 
# f2 = fread(features[2])
# features = bind_rows(f1, f2)

# for(i in 1:length(interactions)){
#     interaction = fread(paste("/media/pa/3E7499C974998475/training_set_0/training_set/", interactions[i], sep = ""))

#     all = merge(features, interaction, 
#                 by.x = "track_id", by.y = "track_id_clean", 
#                 all.y = TRUE)

#     all %>% 
#         group_by(session_id) %>%
#         arrange(session_id, session_position) %>%
#         mutate(filtro = sum(long_pause_before_play)) %>% 
#         filter(filtro == 0) %>% 
#         dplyr::select(valence, energy, loudness, 
#                     tempo, skip_3, session_position, 
#                     session_id) %>%
#         sample_n(length(valence)) %>% # random factor ###########################################
#         mutate(valence = greater(valence), 
#             energy = greater(energy), 
#             loudness = greater(loudness),
#             tempo = greater(tempo)) %>%
#         mutate(likelyhood_v = as.numeric(likelyhood(valence, tm_v)),
#             likelyhood_e = as.numeric(likelyhood(energy, tm_e)),
#             likelyhood_l = as.numeric(likelyhood(loudness, tm_l)),
#             likelyhood_t = as.numeric(likelyhood(tempo, tm_t))) %>%
#         filter(valence != 'start') %>%
#         mutate(overall = mean(c(likelyhood_v, likelyhood_e, likelyhood_l, likelyhood_t))) %>%
#         ungroup() -> cat

#         cat %>% filter(skip_3 == TRUE) -> bom
#         cat %>% filter(skip_3 == FALSE) -> ruim

#         bom = sample_n(bom, nrow(ruim))
#         final = bind_rows(bom, ruim)
#     write.csv(final, paste("/media/pa/3E7499C974998475/out_random/random", i, ".csv", sep = ""))
# }

#uniting outputs
files = list.files("/media/pa/3E7499C974998475/out2")
out = c()
for(i in 1:length(files)){
    out[[i]] = data.frame(fread(paste("/media/pa/3E7499C974998475/out2/", files[i], sep = "")))
}
out = bind_rows(out)    
out$condition = "original"

random_files = list.files("/media/pa/3E7499C974998475/out_random")
random = c()
for(i in 1:length(random_files)){
    random[[i]] = data.frame(fread(paste("/media/pa/3E7499C974998475/out_random/", random_files[i], sep = "")))
}
random = bind_rows(random)    
random$condition = "randomized"

mean_log = function(x){
            final = c()
            for(i in 1:length(x)){
                final[i] = log(x[i]) 
            }
            return(sum(final)/length(final))
        }

out = bind_rows(out, random)

out %<>% sample_n(nrow(out)/2) %>%
    select("skip_3", "condition", "likelyhood_e", "likelyhood_v") %>% 
    melt(id.vars = c("skip_3", "condition"), measures.vars = c("likelyhood_v", "likelyhood_e")) %>%
    group_by(variable, skip_3, condition) %>%
    ggplot(aes(x = skip_3, y = value, group = skip_3))+
        facet_wrap(~condition+variable)+
        # geom_violin(trim = TRUE)+
        geom_boxplot() 

ggsave(out, "/media/pa/3E7499C974998475/out2/out_graph.pdf", width = 4, height = 4)


View(head(out))
