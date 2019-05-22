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


source("get_data.R")


g <- ggplot(data = df.raw, aes(x = square_feet, y = price, 
                          colour = factor(comp))) + 
    geom_point() +
    geom_smooth(data = df.raw %>% filter(comp == 1), method = "lm", linetype = "dashed", size = 0.5) + 
    geom_label_repel(aes(label = address), size = 2) +
    scale_x_continuous(labels = scales::comma) + 
    scale_y_continuous(labels = scales::dollar) + 
    theme_bw() + 
    theme(legend.position = "none") + 
    ylab("Price") + 
    xlab("SqFt") 

JJHmisc::writeImage(g, "price_versus_square_feet", width = 4, height = 2.5, path = "../writeup/plots/")
