setwd("/home/pa/Documents/github/doc_suomi/code")
source("utils.R")
source("data_cook.R")
cat(howto_data)

base = producers()
base$track_number = as.factor(base$track_number)
base$producer_query

base %<>% filter(album_id != '2zUpKJnQgl3YMUJ4dqYo61')

base %>%
  group_by(album_id, producer_query) %>%
  # mutate(section = segment(as.numeric(track_number), 3, c('1st', '2nd', '3d'))) %>%
  mutate_if(is.numeric, z) %>%
  # select(!track_number) %>%
  melt(id.vars = c('track_number', 'producer_query', 'album_id')) %>%
  ungroup() %>% group_by(track_number, producer_query) %>%
  ggplot(aes(x = track_number, y = value, group = track_number))+
    facet_wrap(~producer_query+variable)+
    geom_boxplot()

