suppressPackageStartupMessages({
    library(JJHmisc)
    library(dplyr)
    library(magrittr)
    library(ggplot2)
})

source("get_data.R")

m <- lm(price ~ square_feet + lotSize, data = df.raw %>% filter(comp == 1))

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

df.results %<>% mutate(pctile = ecdf(predictions)(predictions)) %>% filter(pctile > 0.05) %>% filter(pctile < 0.95)

g <- ggplot(data = df.results, aes(x = predictions)) +
    geom_histogram() +
    geom_vline(xintercept = property.price, colour = "red", linetype = "dashed") +
    theme_bw() +
    scale_x_continuous(labels = scales::comma)

JJHmisc::writeImage(g, "bootstrap_price_predictions", width = 5, height = 5, path = "../writeup/plots/")
