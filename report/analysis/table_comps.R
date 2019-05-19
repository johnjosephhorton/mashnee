#! /usr/bin/env Rscript

suppressPackageStartupMessages({
    library(magrittr)
    library(dplyr)
    library(ggplot2)
    library(ggrepel)
    library(glmnet)
    library(reshape2)
    library(JJHmisc)
    library(gt)
})

# Load comparables data 

df.raw <- read.csv("../data/data.csv") %>% 
  mutate(price = gsub(",","",price) %>% as.numeric)

property.name <- df.raw %>% filter(comp == 0) %$% address

df.raw %>% select(-mashnee_island, -water_views, -sale_price) %>%
    gt() %>%
    cols_align(align = "left", columns = vars(address)) %>%
    cols_label("address" = "Address") %>% 
    tab_header(title = paste0("Comparable properties for:"),
               subtitle = as.character(property.name)
               ) %>%
    fmt_currency(
        columns = vars(price),
        currency = "USD",
        decimals = 0 
    ) %>%
    fmt_number(
        columns = vars(square_feet),
        decimals = 0
    ) %>% as_latex %>% as.character %>% writeLines(con = "../writeup/tables/comps.tex")

