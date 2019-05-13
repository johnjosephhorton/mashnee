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

df <- df.raw %>% select(address, comp, baths, bedrooms, square_feet, price) %>% melt(id.vars = c("address", "comp"))  %>%
    group_by(variable) %>%
    mutate(percentile = ecdf(value)(value))

df.comps <- df %>% filter(comp == 1)
df.comps$address <- with(df.comps, reorder(address, -percentile, mean))

g <- ggplot(data = df.comps, aes(x = variable, y = percentile)) +
    geom_point() +
    geom_point(data = df %>% filter(comp == 0) %>% select(variable, percentile), colour = "pink") + 
    facet_wrap(~address, ncol = 3) +
    theme_bw() +
    scale_y_continuous(label = scales::percent) +
    theme(axis.text.x = element_text(angle = 45))

JJHmisc::writeImage(g, "ecdf", width = 5, height = 5, path = "../writeup/plots/")




