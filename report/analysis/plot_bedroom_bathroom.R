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

inches.per.row <- 0.25
num.rows <- nrow(df.raw)
width <- 4

df <- df.raw %>% select(address, comp, baths, bedrooms) %>% melt(id.vars = c("address", "comp"))

df$address <- with(df, reorder(address, value, max))

pretty.labels <- list("bedrooms" = "Bedrooms", "baths" = "Bathrooms")
df$variable <- with(df, unlist(sapply(variable, function (x) pretty.labels[as.character(x)])))

g <- ggplot(data = df, aes(y = address, x = value,
                           colour = factor(comp), 
                           shape = factor(variable))) +
    facet_wrap(~variable, ncol = 2) +  
    geom_point()  + 
    ylab("") + #    xlab("Number of rooms") +
    xlab("") + 
    theme_bw() +
    theme(legend.position = "none") +
    geom_vline(data = df %>% filter(comp == 0), aes(xintercept = value), colour = "red", linetype = "dashed") 


JJHmisc::writeImage(g, "bedroom_bathroom", width = width, height = num.rows * inches.per.row, path = "../writeup/plots/")




