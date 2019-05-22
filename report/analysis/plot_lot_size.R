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

df.raw$address <- with(df.raw, reorder(address, lotSize, mean))

inches.per.row <- 0.25
num.rows <- nrow(df.raw)
width <- 4

df.raw$acres <- with(df.raw, lotSize / 43560)

g <- ggplot(data = df.raw, aes(x = acres, y = address, 
                               colour = factor(comp),
                               shape = factor(comp))) + 
    geom_point() + 
    theme_bw() + 
    theme(legend.position = "none") + 
    scale_x_continuous() + 
    geom_vline(data = df.raw %>% filter(comp == 0), aes(xintercept = acres), colour = "red", linetype = "dashed") +
    ylab("") +
    xlab("(acres)")

JJHmisc::writeImage(g, "lot_size", width = width, height = num.rows * inches.per.row, path = "../writeup/plots/")
