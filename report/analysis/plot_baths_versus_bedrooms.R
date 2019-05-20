#! /usr/bin/env Rscript

suppressPackageStartupMessages({
    library(magrittr)
    library(dplyr)
    library(ggplot2)
    library(ggrepel)
    library(glmnet)
    library(reshape2)
    library(JJHmisc)
})

# Load comparables data 

## df.raw <- read.csv("../data/data.csv") %>% 
##   mutate(price = gsub(",","",price) %>% as.numeric)

source("get_data.R")


df <- df.raw %>% select(address, comp, baths, bedrooms)

g <- ggplot(data = df, aes(x = bedrooms, y = baths, colour = factor(comp))) +
    geom_point() +
    theme_bw() +
    geom_smooth(data = df %>% filter(comp == 1), method = "lm", linetype = "dashed") + 
    geom_text_repel(aes(label = address)) +
    geom_smooth(method = "lm") +
    theme_bw() +
    theme(legend.position = "none") +
    xlab("Bedrooms") +
    ylab("Bathrooms")

JJHmisc::writeImage(g, "baths_versus_bedrooms", width = 3.5, height = 2.25, path = "../writeup/plots/")
