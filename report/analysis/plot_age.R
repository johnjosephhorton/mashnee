#! /usr/bin/env Rscript

suppressPackageStartupMessages({
library(magrittr)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(glmnet)
library(reshape2)
})

df.raw <- readRDS("../data/data.rds")

df.raw$address <- with(df.raw, reorder(address, yearBuilt, mean))

inches.per.row <- 0.25
num.rows <- nrow(df.raw)
width <- 4

g <- ggplot(data = df.raw, aes(x = yearBuilt, y = address, 
                               colour = factor(comp),
                               shape = factor(comp))) + 
    geom_point() + 
    theme_bw() + 
    theme(legend.position = "none") + 
    xlab("yearBuilt") +
    scale_x_continuous() + 
    geom_vline(data = df.raw %>% filter(comp == 0), aes(xintercept = yearBuilt), colour = "red", linetype = "dashed") +
    ylab("") +
    xlab("")

JJHmisc::writeImage(g, "age", width = width, height = num.rows * inches.per.row, path = "../writeup/plots/")
