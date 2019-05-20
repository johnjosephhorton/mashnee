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

source("get_data.R")

property.name <- df.raw %>% filter(comp == 0) %$% address

df.raw %>%
    select(-id, -created, -url_id) %>% 
    gt() %>%
    cols_align(align = "left", columns = vars(address)) %>%
    cols_label("address" = "Address", "square_feet" = "sqft", "bedrooms" = "Bedrooms", "baths" = "Baths", "price" = "Price") %>% 
    fmt_currency(
        columns = vars(price),
        currency = "USD",
        decimals = 0 
    ) %>%
    fmt_number(
        columns = vars(square_feet),
        decimals = 0
    ) %>% as_latex %>% as.character %>% writeLines(con = "../writeup/tables/comps.tex")

