#! /usr/bin/env Rscript

suppressPackageStartupMessages({
library(magrittr)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(glmnet)
library(reshape2)
})

# Load comparables data 

df.raw <- read.csv("../data/data.csv") %>% 
  mutate(price = gsub(",","",price) %>% as.numeric)

df.raw$address <- with(df.raw, reorder(address, price,  mean))

g <- ggplot(data = df.raw, aes(x = price, y = address, 
                          colour = factor(comp))) + 
    geom_point() + 
    theme_bw() + 
    theme(legend.position = "none") + 
    xlab("Price") +
    scale_x_continuous(labels = scales::comma) + 
    geom_vline(data = df.raw %>% filter(comp == 0),
               aes(xintercept = price),
               colour = "red",
               linetype = "dashed") +
    ylab("")

JJHmisc::writeImage(g, "price", width = 5, height = 2.5, path = "../writeup/plots/")
