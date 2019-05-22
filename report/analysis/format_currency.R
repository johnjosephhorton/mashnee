#! /usr/bin/env Rscript


priceFormatter <- function(...){
    f <- function(x){
        result <- ""
    if (x < 1000000) {
        result <- paste0("$", round(x / 1000, 0), "K")
    } else {
        result <- paste0("$", round(x / 1000000, 1), "M")
    }
        result
    }
    function(x) sapply(x, f)
}

