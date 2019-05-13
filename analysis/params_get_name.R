#! /usr/bin/env Rscript

suppressPackageStartupMessages({
    library(JJHmisc)
    library(dplyr)
    library(magrittr)
})

# Load comparables data 
addParam <- genParamAdder("../writeup/parameters_name.tex")

df.raw <- read.csv("../data/data.csv") %>% 
  mutate(price = gsub(",","",price) %>% as.numeric)

addParam("\\PropertyName",  df.raw %>% filter(comp == 0) %$% address)
addParam("\\NumberOfComps",  df.raw %>% filter(comp == 1) %>% nrow() )

addParam("\\MinPrice", df.raw %>% filter(comp == 1) %$% price %>% min %>% round(0) %>% formatC(format = "f", digits = 0, big.mark = ","))
addParam("\\MaxPrice", df.raw %>% filter(comp == 1) %$% price %>% max %>% round(0) %>% formatC(format = "f", digits = 0, big.mark = ","))

addParam("\\MeanPricePerFoot",  df.raw %>% filter(comp == 1) %>% mutate(price.per.foot = price / square_feet) %$%
                                price.per.foot %>% mean %>% round(0))

addParam("\\MeanPricePerFootFocal",  df.raw %>% filter(comp == 0) %>% mutate(price.per.foot = price / square_feet) %$%
                                price.per.foot %>% mean %>% round(0))

m <- lm(price ~ square_feet, data = df.raw %>% filter(comp == 1))

addParam("\\MarginalPricePerFoot", coef(m)["square_feet"] %>% round(0))

