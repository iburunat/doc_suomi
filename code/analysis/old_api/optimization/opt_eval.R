setwd("/home/pa/Documents/github/doc_suomi/code")
source("utils.R")
source("data_cook.R")
cat(howto_data)

reordered = fread("/home/pa/Documents/github/doc_suomi/data/optimization/reordered.csv")

overlook = reordered %>% select(track_number, album_id) %>%
                         group_by(album_id) %>%
                         mutate(album_length = max(track_number), acertos = direction_counter(track_number)) %>%
                         ungroup() %>% group_by(album_length) %>% na.omit() %>%
                         summarise(n_trials = length(acertos), 
                                   acertos = sum(acertos))

overlook$prob = unlist(lapply(overlook$album_length, function(x){seq(2, 1, x)}))


direction_counter = function(x){
    count = c(NA)
    for(i in 1:(length(x)-1)){
        if(x[[i]] == x[[i+1]]-1){
            count[i+1] = 1
        } else{
            count[i+1] = 0
        }
    }
    return(count)
}

seq = function(x, y, t){
        if(x == t-1){
            acerto = (x*y)*(t-1)
            possibilidades = factorial(t)*(t-1)
            return(acerto/possibilidades)
        }
        return(seq(x+1, x*y, t)) 
    }

n_overalal_trials = c(); n_trials_album = c(); hits = c(); prob_single_hit = c()
p_value = c(); binom_distr = c(); empirical = c(); n_overall_trials = c()

for(i in 1:nrow(overlook)){
    n_overall_trials[i] = overlook$n_trials[i]
    n_trials_album[i] = overlook$album_length[i]
    hits[i] = overlook$acertos[i]
    prob_single_hit[i] = overlook$prob[i]
    p_value[i] = binom.test(x = hits[i], n = n_overall_trials[i], p = prob_single_hit[i], alternative = "greater")$p.value
    binom_distr[[paste(i+5)]] = dbinom(0:(n_trials_album[i]-1), n_trials_album[i]-1, prob_single_hit[i])
    reordered %>% select(track_number, album_id) %>%
                         group_by(album_id) %>%
                         summarise(album_length = max(track_number), acertos = direction_counter(track_number)) %>% 
                         ungroup() %>% group_by(album_id, album_length) %>%
                         summarise(acertos = sum(acertos, na.rm = TRUE)) %>% filter(album_length == n_trials_album[i]) %>% 
                         ungroup() %>% select(acertos) %>% as.list() %>% unname() %>% unlist() -> emp
    empirical[[paste(i+5)]] = emp 
}
one = data.frame(n_trials = n_overall_trials,
       album_length = n_trials_album, 
       prob = prob_single_hit,
       p_value = p_value)

binom_probs = data.frame(expected = stack(binom_distr)$values,
       album_length = stack(binom_distr)$ind) %>%
       group_by(album_length) %>%
       mutate(hits = 0:(length(expected)-1))

# freqs indica o número de acertos para cada permutação. Ou seja: nós temos 15 albums de tamanho 6, e freqs representa o número de acerto de cada.
two = data.frame(hits = stack(empirical)$value,
       album_length = stack(empirical)$ind)

two %<>% 
    group_by(album_length, hits) %>%
    summarise(real = length(hits)) 

two = merge(binom_probs, two, all = TRUE)
two[is.na(two)] <- 0



final = merge(one, two, by.x = c("album_length"), by.y = c("album_length"))  
# final$expected = round(final$binom_probs*(final$album_length-1))
final %<>% 
    group_by(album_length) %>%
    mutate(real = real/sum(real))

oi = function(x){
    if(x<0.05){
        return("p < 0.05")
        }
    if(x>0.05){
        return("p > 0.05")
    }
   }
final$p_value = lapply(final$p_value, oi)
final %>% 
    melt(id.vars = c("album_length", "hits", "n_trials", "prob", "p_value"), 
         measures.vars = c("real", "expected")) %>%
    ggplot(aes(x = hits, y = value, group = variable, fill = variable, color = variable)) + 
        facet_wrap(~album_length, scale = "free")+
    geom_bar(stat = "identity", position = "dodge", color = "black")+
    scale_x_continuous(breaks = 0:15)+
    xlim(c(0,8))+ ylim(c(0, 0.6))+
    geom_label( aes(x=5, y=0.55, label=p_value), color = "black")

########################### DENSITY PLOT OF ACCURACY - DIERCTION ############################
original = fread("/home/pa/Documents/github/doc_suomi/data/optimization/original.csv")
reordered = fread("/home/pa/Documents/github/doc_suomi/data/optimization/reordered.csv")

control = album_splitter(original)
for(i in 1:length(control)){ control[[i]] = special_shuffler(control[[i]]) }
control = bind_rows(control)

junto = dplyr::bind_cols(original, reordered, control)
colnames(junto) = c("V1", "album_id1", "track_number_original", "valence_original", "energy_original", "loudness_original", "tempo_original",
                    "V2", "album_id2", "track_number_reor",     "valence_reor",     "energy_reor",     "loudness_reor", "tempo_reor",
                    "V3", "album_id3", "track_number_control", "valence_control", "energy_control", "loudness_control", "tempo_control")


junto %>% 
    group_by(album_id1) %>%
    summarise(model_valence = match(valence_original, valence_reor), 
              model_energy = match(energy_original, energy_reor),
              model_loudness = match(loudness_original, loudness_reor),
              model_tempo = match(tempo_original, tempo_reor),      
              control_valence = match(valence_original, valence_control),
              control_energy = match(energy_original, energy_control),
              control_loudness = match(loudness_original, loudness_control),
              control_tempo = match(tempo_original, tempo_control)) %>%

              melt(id.vars = c("album_id1"), 
                   measure.vars = c("model_valence", 'model_energy', 
                                    "model_loudness", "model_tempo", 
                                    "control_valence", "control_energy", 
                                    "control_loudness", "control_tempo")) %>%
              
              separate(variable, c("condition", "feature"), "_") %>%

              ggplot(aes(x = value, fill = condition)) +
                         facet_wrap(~feature)+
                         geom_density(alpha = 0.8)




########################### DISSIMILARITY - INCREASING SEQUENCE ############################
dd = album_splitter(z_scored())
dd = dd[round(length(dd)*0.8):length(dd)]
dd = dplyr::bind_rows(dd)
dd %<>% filter(album_id %in% unique(reordered$album_id)) %>% arrange(album_id)
# dd %>% View()
# reordered %>% View()
reordered %<>% filter(album_id %in% unique(dd$album_id)) %>% arrange(album_id)

control = album_splitter(dd)

for(i in 1:length(control)){ control[[i]] = special_shuffler(control[[i]]) }
control = bind_rows(control)

model = left_join(reordered, dd, by=c("album_id", "track_number"))
control = left_join(control, dd, by=c("album_id", "track_number"))
comp = data.frame(valence_model = model$valence.y, 
                  valence_original = dd$valence,
                  valence_control = control$valence.x,
                  energy_model = model$energy.y,
                  energy_original = dd$energy,
                  energy_control = control$energy.x,
                  loudness_model = model$loudness.y,
                  loudness_original = dd$loudness,
                  loudness_control = control$loudness.x,
                  tempo_model = model$tempo.y,
                  tempo_original = dd$tempo,
                  tempo_control = control$tempo.x,
                  album_id = dd$album_id)

v = c("valence_model", "valence_original", "valence_control")
e = c("energy_model", "energy_original", "energy_control")
l = c("loudness_model", "loudness_original", "loudness_control")
t =  c("tempo_model", "tempo_original", "tempo_control")

features = list(v,e,l,t)
comp = album_splitter(comp)

ha = c()
for(j in 1:length(features)){
    final = c()
    for(i in 1:length(comp)){
        comp[[i]] %>% select(features[[j]]) %>% t() %>% data.frame() %>% daisy() -> oi
        final[[i]] = data.frame(as.matrix(oi))
    }
    final = bind_rows(final)
    ha[[j]] = final
}

for(i in 1:length(ha)){
    colnames(ha[[i]]) <- c("model", "original", "control") 
}

ha[[1]]$feature = "valence"
ha[[2]]$feature = "energy"
ha[[3]]$feature = "loudness"
ha[[4]]$feature = "tempo"

cabo = bind_rows(ha)
cabo %>% select(!model) %>% filter(original != 0) %>% filter(control != 0) %>% melt(id.vars = "feature") %>% 
    group_by(feature, variable) %>%
    summarise(m_v = mean(value),
              stder = sd(value)/sqrt(length(value))) %>%
              ggplot(aes(x = feature, y = m_v, fill = variable, color = variable, group = variable))+
                    #  facet_wrap(~feature)+
                     geom_point(position = position_dodge(width = 0.9))+
                     geom_errorbar(position = position_dodge(width = 0.9), aes(ymin = m_v-stder, ymax = m_v+stder))+
                     ylab("Dissimilarity with model")



cabo %>% melt(id.vars = "feature") %>% View()
colnames(cabo)





























f %>% melt() %>% 
      group_by(variable) %>%
      ggplot(aes(x = variable, y = value, fill = variable)) +
             geom_boxplot() %>%
             ggsave(path = "/home/pa/Documents/github/doc_suomi/code/optimization/", device='tiff', dpi=700)

    

dd %>% View()