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

df.comps <- df.raw %>% filter(comp == 1) %>% select(address,  baths, bedrooms, square_feet, price) %>% melt(id.vars = c("address"))

df.target <- df.raw %>% filter(comp == 0) %>% select(address, baths, bedrooms, square_feet, price) %>% melt(id.vars = c("address")) %>%
    mutate(target.value = value) %>%
    select(-value) %>%
    select(-address)

df.combo <- df.comps %>% left_join(df.target, by = c("variable")) %>%
    mutate(percentile = (value - target.value)/target.value) %>%
    mutate(direction = ifelse(value > target.value, "pos", "neg"))

df.combo$address <- with(df.combo, reorder(address, -percentile, mean))
     
g <- ggplot(data = df.combo, aes(x = variable, y = percentile)) +
    facet_wrap(~address, ncol = 3) +
    geom_bar(stat = "identity", aes(fill = direction), colour = "black") + 
    theme_bw() +
    scale_y_continuous(label = scales::percent) +
    theme(axis.text.x = element_text(angle = 90)) +
    geom_hline(yintercept = 0, colour = "black") +
    scale_fill_manual("direction",
                      values = c("same" = "gray", "pos" = "lightgreen", "neg" = "pink")
                      ) +
    theme(legend.position = "none") +
    ylab("% relative to target property") +
    xlab("")

JJHmisc::writeImage(g, "ecdf", width = 5, height = 5, path = "../writeup/plots/")



