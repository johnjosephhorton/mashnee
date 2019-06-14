#! /usr/bin/env Rscript

suppressPackageStartupMessages({
    library(magrittr)
    library(dplyr)
    library(ggplot2)
    library(ggrepel)
    library(reshape2)
})


df.raw <- readRDS("../data/data.rds")

df.raw$address <- with(df.raw, reorder(address, price,  mean))

inches.per.row <- 0.25
num.rows <- nrow(df.raw)
width <- 4

source("format_currency.R")

target.price <- df.raw %>% filter(comp == 0) %$% price

g <- ggplot(data = df.raw, aes(x = price, y = address, 
                               colour = factor(comp),
                               shape = factor(comp))) + 
    geom_point(size = 2) + 
    theme_bw() + 
    theme(legend.position = "none") + 
    scale_x_continuous(labels = priceFormatter()) + 
    geom_vline(data = df.raw %>% filter(comp == 0),
               aes(xintercept = price),
               colour = "red",
               linetype = "dashed") +
    ylab("") +
    xlab("") +
    geom_label_repel(data = df.raw %>% filter(comp == 0), label = "Listing price\nfor target", size = 2, 
                     segment.colour = "grey",
                     arrow = arrow(length = unit(0.03, "npc"), type = "closed", ends = "last")
                     #xlim = c(NA, 0.9 * target.price),
                     #ylim = c(num.rows - 1.5, NA)
                     )


print(g)

JJHmisc::writeImage(g, "price", width = width, height = inches.per.row * num.rows, path = "../writeup/plots/")
