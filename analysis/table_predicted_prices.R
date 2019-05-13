#! /usr/bin/env Rscript

suppressPackageStartupMessages({
    library(magrittr)
    library(dplyr)
    library(ggplot2)
    library(ggrepel)
    library(glmnet)
    library(reshape2)
    library(JJHmisc)
    library(stargazer)
})

# Load comparables data 

df.raw <- read.csv("../data/data.csv") %>% 
  mutate(price = gsub(",","",price) %>% as.numeric)

########################
## Fit regression models
########################

# Create comps data set 
df.comps <- df.raw %>% filter(comp == 1) 

m.base <- lm(I(price/1000) ~ I(square_feet/1000), data = df.comps)
df.raw$price.hat.base <- predict(m.base, newdata = df.raw)

m.rooms <- lm(I(price/1000) ~ I(square_feet/1000) + bedrooms + baths, data = df.comps)
df.raw$price.hat.rooms <- predict(m.rooms, newdata = df.raw)

m.water <- lm(I(price/1000) ~ I(square_feet/1000) + water_views, data = df.comps)
df.raw$price.hat.water <- predict(m.water, newdata = df.raw)

m.water.loc <- lm(I(price/1000) ~ I(square_feet/1000) + water_views + mashnee_island, data = df.comps)
df.raw$price.hat.water.loc <- predict(m.water.loc, newdata = df.raw)

#####################
### Regression tables
#####################
stargazer::stargazer(m.base,m.rooms, m.water, m.water.loc, type = "text", no.space = TRUE)

##################################################
### All the model predictions for 80 Captain's Row
##################################################

df.raw %>% filter(comp == 0) %>% select(contains("price.hat")) %>%
    melt 
