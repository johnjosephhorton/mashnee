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

df.raw <- read.csv("../data/data.csv") %>% 
  mutate(price = gsub(",","",price) %>% as.numeric)


g <- ggplot(data = df.raw, aes(x = square_feet, y = price, 
                          colour = factor(comp))) + 
    geom_point() +
    geom_smooth(data = df.raw %>% filter(comp == 1), method = "lm", linetype = "dashed", size = 0.5) + 
    geom_text_repel(aes(label = address)) +
    scale_x_continuous(labels = scales::comma) + 
    scale_y_continuous(labels = scales::dollar_format()) + 
    theme_bw() + 
    theme(legend.position = "none") + 
    ylab("Price") + 
    xlab("Square Feet") 

JJHmisc::writeImage(g, "price_versus_square_feet", width = 5, height = 4, path = "../writeup/plots/")
