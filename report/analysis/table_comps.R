
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
    select(-id, -created, -url_id, -city, -state, -latitude, -longitude, -homeType, -comp, -order_id) %>% 
    gt() %>%
    cols_align(align = "left", columns = vars(address)) %>%
    cols_label("address" = "Address", "yearBuilt" = "Year", "square_feet" = "Sqft", "lotSize" = "Lot", "bedrooms" = "Beds", "baths" = "Baths", "price" = "Price") %>% 
#    tab_header(title = paste0("Comparable properties for:"),
#               subtitle = as.character(property.name)
#               ) %>% 
     fmt_currency(
        columns = vars(price),
        currency = "USD",
        decimals = 0 
    ) %>%
    fmt_number(
        columns = vars(square_feet, lotSize),
        decimals = 0
    ) %>% as_latex %>% as.character %>% writeLines(con = "../writeup/tables/comps.tex")

