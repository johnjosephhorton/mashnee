#! /usr/bin/env Rscript

suppressPackageStartupMessages({
    library(magrittr)
    library(dplyr)
    library(reshape2)
    library(JJHmisc)
})

# Load comparables data 
source("get_data.R")

df.raw %>% select(address, url) %>%
    mutate(line = paste0("\\item \\href{", url, "}{", address, "}")) %$% line %>% 
    as.character %>% writeLines(con = "../writeup/tables/links.tex")

