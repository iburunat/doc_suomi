setwd("/home/pa/Documents/github/doc_suomi/code")
source("utils.R")
source("data_cook.R")

global = base_global()
global %>%
  group_by(album_id) %>%
  mutate(position = segment(track_number, 3, c("1st", "2nd", "3d"))) %>%
  ungroup() %>% group_by(album_id, position) %>%
  summarise(valence = mean(valence), 
            energy = mean(energy),
            loudness = mean(loudness),
            tempo = mean(tempo), 
            danceability = mean(danceability),
            overall = mean(valence, energy, loudness, tempo, danceability)) -> x

x %>% ggplot(aes(x = position, y = overall))+
        geom_boxplot()

modelo.anova = lm(valence ~ position, data = x)
TukeyHSD(aov(modelo.anova))
