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

#df.raw <- read.csv("../data/data.csv") %>% 
#  mutate(price = gsub(",","",price) %>% as.numeric)

source("get_data.R")


df <- df.raw %>% select(address, comp, baths, bedrooms) %>% melt(id.vars = c("address", "comp"))

df$address <- with(df, reorder(address, value, max))

g <- ggplot(data = df, aes(y = address, x = value,
                           colour = factor(comp), 
                           shape = factor(variable))) +
    facet_wrap(~variable, ncol = 2) +  
    geom_point()  + 
    ylab("") + 
    xlab("Number of rooms") +
    theme_bw() +
    theme(legend.position = "none") +
    geom_vline(data = df %>% filter(comp == 0), aes(xintercept = value), colour = "red", linetype = "dashed") 

JJHmisc::writeImage(g, "bedroom_bathroom", width = 4, height = 3, path = "../writeup/plots/")




