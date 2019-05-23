#! /usr/bin/env Rscript

priceFormatter <- function(...){
    function(x) ifelse(x < 1000000, paste0("$", round(x / 1000, 0), "K"), paste0("$", round(x / 1000000, 1), "M"))
}


