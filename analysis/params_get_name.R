#! /usr/bin/env Rscript

suppressPackageStartupMessages({
    library(JJHmisc)
    library(dplyr)
    library(magrittr)
    library(ggplot2)
})

# Load comparables data 
addParam <- genParamAdder("../writeup/parameters_name.tex")

df.raw <- read.csv("../data/data.csv") %>% 
  mutate(price = gsub(",","",price) %>% as.numeric)

addParam("\\PropertyName",  df.raw %>% filter(comp == 0) %$% address)

addParam("\\PropertySqFt",  df.raw %>% filter(comp == 0) %$% square_feet %>% round(0) %>%
                            formatC(format = "f", digits = 0, big.mark = ",")
         )

addParam("\\PropertyPrice",  df.raw %>% filter(comp == 0) %$% price %>% round(0) %>%
                            formatC(format = "f", digits = 0, big.mark = ",")
         )


addParam("\\NumberOfComps",  df.raw %>% filter(comp == 1) %>% nrow() )

addParam("\\MinPrice", df.raw %>% filter(comp == 1) %$% price %>% min %>% round(0) %>% formatC(format = "f", digits = 0, big.mark = ","))
addParam("\\MaxPrice", df.raw %>% filter(comp == 1) %$% price %>% max %>% round(0) %>% formatC(format = "f", digits = 0, big.mark = ","))

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


property.price <- df.raw %>% filter(comp == 0) %$% price
predicted.price <- predict(m, newdata = df.raw %>% filter(comp == 0)) %>% as.numeric


GetPrediction <- function(){
    df.sample <- df.raw %>% filter(comp ==1)
    n <- nrow(df.sample)
    df.sample.bs <- df.raw[sample(1:n, replace = TRUE), ]
    m <- lm(price ~ square_feet, data = df.sample.bs)
    predicted.price <- predict(m, newdata = df.raw %>% filter(comp == 0)) %>% as.numeric
    predicted.price
}

df.results <- data.frame(sapply(1:500, function(x) GetPrediction() ))
colnames(df.results) <- c("predictions")

g <- ggplot(data = df.results, aes(x = predictions)) +
    geom_histogram() +
    geom_vline(xintercept = property.price, colour = "red", linetype = "dashed") +
    theme_bw() +
    scale_x_continuous(labels = scales::comma)

print(g)
