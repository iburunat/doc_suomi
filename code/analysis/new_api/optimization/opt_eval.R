setwd("/home/pa/Documents/github/doc_suomi/code")
source("utils.R")
source("data_cook.R")
cat(howto_data)
path = "/home/pa/Documents/github/doc_suomi/data/new_api_call/analysis/optimization/re_ordered/"

albums = paste(path, list.files(path), sep = "")
reordered = lapply(albums, fread)
reordered = bind_rows(reordered)
reordered %<>%
  group_by(album_id) %>%
  filter(track_number != 'start') %>%
  mutate(album_length = length(valence))

optimized = reordered %>% 
              group_by(album_id) %>%
              summarise(acerto = direction_counter(`Unnamed: 0`),
                        album_length = unique(album_length))
optimized$condition = 'optimized'

random = test("test") %>%
    filter(condition == "original") %>%
    filter(track_number != 'start') %>%
    select(track_number, album_id, album_length) %>%
    group_by(album_id) %>%
    sample_n(length(album_id)) %>%
    sample_n(length(album_id)) %>%
    summarise(acerto = direction_counter(track_number), 
              album_length = unique(album_length))
random$condition = 'random'

final = bind_rows(random, optimized)

final$condition <- factor(final$condition, levels = c("random", "optimized"))
final %>%
  ggplot(aes(x = as.factor(acerto), fill = condition))+
    geom_histogram(stat = "count", position = position_dodge2(width = 0.01))+
    xlab("Number of sequences within album")+
    ylab("Frequencies")

bind_rows(optimized, random) %>%
  ggplot(aes(x = condition, y = acerto, fill = condition))+
    geom_boxplot()


#####################
##### Bootstrap #####
#####################

random = c()
for(i in 1:10000){
  test() %>%
    filter(condition == "original") %>%
    filter(track_number != 'start') %>%
    select(track_number, album_id, album_length) %>%
    group_by(album_id) %>%
    sample_n(length(album_id)) %>%
    sample_n(length(album_id)) %>%
    summarise(acerto = direction_counter(track_number), 
              album_length = unique(album_length)) -> media
  random[i] = mean(media$acerto)
}
# mean(random)
# sd(random)
# bootstrap_mean = 0.9026132
# bootstrap_sd = 0.02906368

# sample_mean = 1.53

t.test(sample_mean$acerto, mu = 0, alternative = "two.sided")

#data:  sample_mean$acerto
#t = 39.095, df = 1051, p-value < 2.2e-16
#alternative hypothesis: true mean is not equal to 0
#95 percent confidence interval:
#  1.451798 1.605236
#sample estimates:
#  mean of x 
#1.528517

sample_mean = final %>%
    filter(condition == 'optimized')  %>% select(acerto) 


f %>% melt() %>% 
      group_by(variable) %>%
      ggplot(aes(x = variable, y = value, fill = variable)) +
             geom_boxplot() %>%
             ggsave(path = "/home/pa/Documents/github/doc_suomi/code/optimization/", device='tiff', dpi=700)

