setwd("/home/pa/Documents/github/doc_suomi/code")
source("utils.R")
source("data_cook.R")
cat(howto_data)

dt_train = train("train_producers")
dt_test  = test("test_producers")

#Logistic regression
mylogit <- glm(as.factor(condition) ~
                 loudness_o*valence_o*energy_o*loudness_o*tempo_o, 
               data = dt_train, family = "binomial")
summary(mylogit)

dt_test$probs = predict(mylogit, newdata = dt_test, type = "response")
dt_test$categorical = 1
dt_test$categorical[dt_test$probs > .5] = 2
table(dt_test$categorical, c(as.factor(dt_test$condition)))

mean(dt_test$categorical == c(as.factor(dt_test$condition)))

dt_test %>% 
  ungroup() %>%
  select(valence_o, energy_o, loudness_o, tempo_o, 
         probs, condition) %>%
  melt(id.vars = c('probs', 'condition')) %>%
  ggplot(aes(x = value, y = probs))+
  facet_wrap(~variable, scale = 'free')+
  geom_point(size = 0.5)+
  geom_smooth(method = 'lm')

################## Random Forest
model.rf = randomForest(formula = as.factor(condition)~
                        valence_o*energy_o*loudness_o*tempo_o,
               data=dt_train, ntree = 100,
               importance=TRUE)

model.rf

pred = predict(model.rf, dt_test)
true = dt_test$condition

mean(pred == true)

paste("Model: "   , Metrics::rmse(pred, true), sep = "")
paste("Zerorule: ", Metrics::rmse(pred, mean(true)), sep = "")

plot(true[2000:2200], type='line', col = 'blue', xlim = c(0,  200), ylim = c(0, 16), ylab = "")
par(new = TRUE)
plot(round(pred[2000:2200]), type='line', col = 'red',  xlim = c(0,  200), ylim = c(0, 16), ylab = "")
par(new = TRUE)
plot(rep(mean(true), length(true)), type='ls', col = 'black',  xlim = c(0,  200), ylim = c(0, 16), ylab = "")