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

df.raw$address <- with(df.raw, reorder(address, yearBuilt, mean))

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
    xlab("Year Built")

JJHmisc::writeImage(g, "age", width = 5, height = 2.5, path = "../writeup/plots/")
