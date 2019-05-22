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

df.raw %<>% mutate(ask = ifelse(comp == 0, "Yes", NA))

#df.raw %<>% mutate(address = paste0("\\href{", url, "}{", address, "}"))

df.raw %>% 
    select(-id, -city, -created, -url_id, -state, -latitude, -longitude, -homeType, -order_id, -comp, -url) %>% 
    gt() %>%
    cols_align(align = "left", columns = vars(address)) %>%
    cols_label("address" = "Property",
               # "city" = "City",
               "yearBuilt" = "Built",
               "square_feet" = "Living",
               "lotSize" = "Lot",
               "bedrooms" = "Bed",
               "baths" = "Bath",
               "price" = " ",
               "ask" = "Ask?") %>%
    tab_spanner("Rooms", c("bedrooms", "baths")) %>%
    tab_spanner("Pricing", c("price", "ask")) %>%
    tab_spanner("Space (sqft)", c("square_feet", "lotSize")) %>%
    fmt_missing(columns = vars(ask), missing_text = " ") %>%
    fmt_currency(
        columns = vars(price),
        currency = "USD",
        decimals = 0 
    ) %>%
    fmt_number(
        columns = vars(square_feet, lotSize),
        decimals = 0
    ) %>% as_latex %>% as.character %>% writeLines(con = "../writeup/tables/comps.tex")

