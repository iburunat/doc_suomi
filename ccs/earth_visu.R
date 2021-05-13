library(ggplot2)
library(dplyr)
require(maps)
require(data.table)
require(viridis)


#####################################################################
######## PLOTTING GEOGRAPHIC DISTRIBUTION OF PARTICIPANTS ###########
#####################################################################
path = "/home/pa/Documents/Ciência/PhD/Suomi/Research projects/Crosscultural/data"

file = "ccsData2.csv"
data = fread(paste(path, file, sep = "/"))

#Fetching geographic data
world_map <- map_data("world")

#Plotting geographic distribution of participants
data %>%
  group_by(Country_identity) %>%
  summarise(number_of_respondents = length(RespondentID)) -> a

#Renaming columns to facilitate merging data frames
colnames(a) <- c("region", "value")

#Renaming USA to fit with geodata
a[a$region == 'United States', ]$region = "USA"


#Merging questionary data with country coordenates
data_world <- right_join(a, world_map, by = "region", keep = TRUE)
#Renaming columns to meet with geom_map requirements
colnames(data_world) = c("region", "value", "long", 
                         "lat", "group", "order", 
                         "region.y", "subregion")

#Ploting data
ggplot(data_world, aes(map_id = region, fill = log(value) ))+
  geom_map(map = data_world,  color = "white")+
  expand_limits(x = data_world$long, y = data_world$lat)+
  scale_fill_viridis_c(option = "C")+
  ggtitle("Country_identity distribution of participants") -> um



##############################################################
######## PLOTTING ANY VARIABLE AGAINST GEOLOCATION ###########
##############################################################
file = "dataDescriptors.csv"
data = fread(paste(path, file, sep = "/"))

#Plotting ANY variables against geolocation
data %>%
  select(CompetitionIsTheLawOfNature,
         RespondentID,
         Country_identity) %>%
  melt(id.vars = c("RespondentID", "Country_identity")) %>%
  group_by(Country_identity) %>%
  summarise(value = mean(value, na.rm = TRUE)) -> a

#Renaming columns to facilitate merging data frames
colnames(a) <- c("region", "value")
#Renaming countries with different names
a[a$region == 'United States', ]$region = "USA"
#Merging questionary data with country coordenates
data_world <- right_join(a, world_map, by = "region", keep = TRUE)
#Renaming columns to meet with geom_map requirements
colnames(data_world) = c("region", "value", "long", 
                         "lat", "group", "order", 
                         "region.y", "subregion")

#Ploting data
ggplot(data_world, aes(map_id = region, fill = value))+
  geom_map(map = data_world,  color = "white")+
  expand_limits(x = data_world$long, y = data_world$lat)+
  scale_fill_viridis_c(option = "C")+
  ggtitle("Competition is the law of nature") -> dois


################################################################
######## Spotify's features vs Participant's answers ###########
################################################################
#Plotting ANY variables against geolocation
data %>% 
  select(Happiness,
         valence,
         RespondentID,
         Country_identity) %>%

  ggplot(aes(x = as.factor(Happiness), y = valence)) +
    geom_violin(trim = FALSE, fill = 'gray')+
    geom_boxplot(size = 1, width = 0.1)+
    scale_fill_viridis(name = "Spotify valence", option = "C") +
    labs(title = 'Spotify vs User ratings', 
         x = "Happiness (Respondent)", y = "Valence (Spotify)") -> tres




##################################################################
######## PLOTTING SPOTIFY VARIABLE AGAINST GEOLOCATION ###########
##################################################################
file = "dataDescriptors.csv"
data = fread(paste(path, file, sep = "/"))

#Plotting ANY variables against geolocation
data %>%
  select(valence,
         RespondentID,
         Country_identity) %>%
  melt(id.vars = c("RespondentID", "Country_identity")) %>%
  group_by(Country_identity) %>%
  summarise(value = mean(value, na.rm = TRUE)) -> a

#Renaming columns to facilitate merging data frames
colnames(a) <- c("region", "value")
#Renaming countries with different names
a[a$region == 'United States', ]$region = "USA"
#Merging questionary data with country coordenates
data_world <- right_join(a, world_map, by = "region", keep = TRUE)
#Renaming columns to meet with geom_map requirements
colnames(data_world) = c("region", "value", "long", 
                         "lat", "group", "order", 
                         "region.y", "subregion")

#Ploting data
ggplot(data_world, aes(map_id = region, fill = value))+
  geom_map(map = data_world,  color = "white")+
  expand_limits(x = data_world$long, y = data_world$lat)+
  scale_fill_viridis_c(option = "C")+
  ggtitle("Valence by country") -> quatro


##################################################################
######## PLOTTING SPOTIFY VARIABLE REASON TO LISTEN TO MUSIC #####
##################################################################
file = "dataDescriptors.csv"
data = fread(paste(path, file, sep = "/"))

#Plotting ANY variables against geolocation
data %>%
  select(Music_HaveFun,
         RespondentID,
         valence,
         Country_identity) %>%
  
  ggplot(aes(x = as.factor(Music_HaveFun), y = valence)) +
    geom_violin(trim = FALSE, fill = 'gray')+
    geom_boxplot(size = 1, width = 0.1)+
    scale_fill_viridis(name = "Spotify valence", option = "C") +
    labs(title = 'Valence levels against music to have fun', 
         x = "Music to have fun (participant)", y = "Valence (Spotify)") -> cinco

ggsave(um, filename = "/home/pa/Documents/Ciência/PhD/Suomi/Research projects/Crosscultural/images/1.jpg", dpi = 600)
ggsave(dois, filename = "/home/pa/Documents/Ciência/PhD/Suomi/Research projects/Crosscultural/images/2.jpg", dpi = 600)
ggsave(tres, filename = "/home/pa/Documents/Ciência/PhD/Suomi/Research projects/Crosscultural/images/3.jpg", dpi = 600)
ggsave(quatro, filename = "/home/pa/Documents/Ciência/PhD/Suomi/Research projects/Crosscultural/images/4.jpg", dpi = 600)
ggsave(cinco, filename = "/home/pa/Documents/Ciência/PhD/Suomi/Research projects/Crosscultural/images/5.jpg", dpi = 600)


