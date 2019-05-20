
#! /usr/bin/env Rscript

suppressPackageStartupMessages({
    library(JJHmisc)
    library(dplyr)
    library(magrittr)
    library(ggplot2)
})

source("get_data.R")
## df.raw <- read.csv("../data/data.csv") %>% 
##   mutate(price = gsub(",","",price) %>% as.numeric)
# Load comparables data 

addParam <- genParamAdder("../writeup/parameters_name.tex")


addParam("\\PropertyName",  df.raw %>% filter(comp == 0) %$% address)

addParam("\\NumberOfBedrooms",  df.raw %>% filter(comp == 0) %$% bedrooms)

addParam("\\NumberOfBaths",  df.raw %>% filter(comp == 0) %$% baths)

addParam("\\PropertySqFt",  df.raw %>% filter(comp == 0) %$% square_feet %>% round(0) %>%
                            formatC(format = "f", digits = 0, big.mark = ",")
         )

property.price <-  df.raw %>% filter(comp == 0) %$% price

addParam("\\PropertyPrice",   property.price %>% round(0) %>%
                            formatC(format = "f", digits = 0, big.mark = ",")
         )


addParam("\\NumberOfComps",  df.raw %>% filter(comp == 1) %>% nrow() )

min.price <- df.raw %>% filter(comp == 1) %$% price %>% min
max.price <- df.raw %>% filter(comp == 1) %$% price %>% max

addParam("\\MinPrice", min.price %>% round(0) %>% formatC(format = "f", digits = 0, big.mark = ","))
addParam("\\MaxPrice", max.price %>% round(0) %>% formatC(format = "f", digits = 0, big.mark = ","))

addParam("\\InPriceRange", ifelse(property.price > min.price & property.price < max.price, "is", "is not"))

F <- df.raw %>% filter(comp == 1) %$% price %>% ecdf

addParam("\\PricePercentile", 100 * F(property.price))

df.raw %<>% mutate(price.error = (price - property.price)^2)

###############
# Property size 
###############

property.size <- df.raw %>% filter(comp == 0) %$% square_feet 
addParam("\\PropertySize", property.size %>% formatC(format = "f", big.mark = ",", digits = 0))

df.raw %<>% mutate(size.error = (square_feet - property.size)^2)

df.raw <- df.raw[order(df.raw$size.error),]
addParam("\\ClosestOnSize", df.raw[2,"address"] %>% as.character)

min.size <- df.raw %>% filter(comp == 1) %$% square_feet %>% min
max.size <- df.raw %>% filter(comp == 1) %$% square_feet %>% max

addParam("\\MinSize", min.size %>% round(0) %>% formatC(format = "f", digits = 0, big.mark = ","))
addParam("\\MaxSize", max.size %>% round(0) %>% formatC(format = "f", digits = 0, big.mark = ","))

addParam("\\InSizeRange", ifelse(property.size > min.size & property.size < max.size, "is", "is not"))

df.raw <- df.raw[order(df.raw$size.error),]
addParam("\\ClosestOnPrice", df.raw[2,"address"] %>% as.character)

addParam("\\MeanPricePerFoot",  df.raw %>% filter(comp == 1) %>% mutate(price.per.foot = price / square_feet) %$%
                                price.per.foot %>% mean %>% round(0))

addParam("\\MeanPricePerFootFocal",  df.raw %>% filter(comp == 0) %>% mutate(price.per.foot = price / square_feet) %$%
                                price.per.foot %>% mean %>% round(0))

m <- lm(price ~ square_feet, data = df.raw %>% filter(comp == 1))

addParam("\\MarginalPricePerFoot", coef(m)["square_feet"] %>% round(0))

addParam("\\Intercept", coef(m)["(Intercept)"] %>% round(0) %>% formatC(format = "f", digits = 0, big.mark = ","))

addParam("\\PropertyPredict", predict(m, newdata = df.raw %>% filter(comp == 0)) %>% as.numeric %>%
                              formatC(format = "f", digits = 0, big.mark = ","))

property.price <- df.raw %>% filter(comp == 0) %$% price
predicted.price <- predict(m, newdata = df.raw %>% filter(comp == 0)) %>% as.numeric


addParam("\\ComparePredictedToActual", ifelse(predicted.price > property.price, "more", "less"))
addParam("\\PctDiff", ((predicted.price - property.price)/predicted.price) %>% multiply_by(100) %>% round(0))


