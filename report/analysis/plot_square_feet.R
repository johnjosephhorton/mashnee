#! /usr/bin/env Rscript

suppressPackageStartupMessages({
    library(magrittr)
    library(dplyr)
    library(ggplot2)
    library(ggrepel)
    library(glmnet)
    library(reshape2)
})

source("get_data.R")

inches.per.row <- 0.25
num.rows <- nrow(df.raw)
width <- 4

df.raw$address <- with(df.raw, reorder(address, square_feet, mean))

g <- ggplot(data = df.raw, aes(x = square_feet, y = address, 
                               colour = factor(comp),
                               shape = factor(comp))) + 
    geom_point() + 
    theme_bw() + 
    theme(legend.position = "none") + 
    xlab("Square Feet") +
    scale_x_continuous(labels = scales::comma) + 
    geom_vline(data = df.raw %>% filter(comp == 0), aes(xintercept = square_feet), colour = "red", linetype = "dashed") +
    ylab("") +
    xlab("")

JJHmisc::writeImage(g, "square_feet", width = width, height = inches.per.row * num.rows, path = "../writeup/plots/")
