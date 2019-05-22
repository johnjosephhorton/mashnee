#! /usr/bin/env Rscript

suppressPackageStartupMessages({
    library(magrittr)
    library(dplyr)
    library(ggplot2)
    library(ggrepel)
    library(reshape2)
})


source("get_data.R")

df.raw$address <- with(df.raw, reorder(address, price,  mean))

inches.per.row <- 0.25
num.rows <- nrow(df.raw)

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

#priceFormatter(1000)

g <- ggplot(data = df.raw, aes(x = price, y = address, 
                               colour = factor(comp),
                               shape = factor(comp))) + 
    geom_point(size = 2) + 
    theme_bw() + 
    theme(legend.position = "none") + 
    xlab("(thousands)") +
    scale_x_continuous(labels = priceFormatter()) + 
    geom_vline(data = df.raw %>% filter(comp == 0),
               aes(xintercept = price),
               colour = "red",
               linetype = "dashed") +
    ylab("") +
    xlab("")

print(g)

JJHmisc::writeImage(g, "price", width = 4, height = inches.per.row * num.rows, path = "../writeup/plots/")
