setwd("/home/pa/Documents/github/doc_suomi/code")
source("utils.R")
source("data_cook.R")
cat(howto_data)

dt = base_global()
dt = album_splitter(dt)
dt = dt[1:(length(dt)*0.8)]
dt = bind_rows(dt)

tn = 1
dt %>% 
  group_by(album_id) %>%
  mutate(valence = segment(valence, 3, c("1st", "2nd", "3d")),
         energy = segment(energy, 3, c("1st", "2nd", "3d")), 
         loudness = segment(loudness, 3, c("1st", "2nd", "3d")),
         tempo = segment(tempo, 3, c("1st", "2nd", "3d"))) %>%
  filter(track_number == tn) -> segmented

data.table(valence = unlist(unname(table(segmented$valence)/nrow(segmented))),
           energy = unlist(unname(table(segmented$energy)/nrow(segmented))),
           loudness = unlist(unname(table(segmented$loudness)/nrow(segmented))),
           tempo = unlist(unname(table(segmented$tempo)/nrow(segmented)))
) %>% select(valence.N, energy.N, loudness.N, tempo.N) -> freqs

colnames(freqs) <- c("valence", "energy", "loudness", "tempo")
redblack = colorRampPalette(c("red", "black"))(100)
#freqs$quantile = c("1st", "2nd", "3d")
levelplot(as.matrix(freqs), col.regions = redblack)

freqs$quantiles <- c("1st", "2nd", "3d")
freqs %>% 
  melt() %>% 
  ggplot(aes(x = quantiles, y = value, color = variable, group = variable))+
  geom_line()+
  geom_point()+
  geom_hline(yintercept = 1/3, linetype = 2)+
  ylab("Probability")+
  xlab("Quantile")