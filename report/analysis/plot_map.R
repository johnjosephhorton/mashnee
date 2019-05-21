#! /usr/bin/env Rscript

suppressPackageStartupMessages({
    library(magrittr)
    library(dplyr)
    library(ggplot2)
    library(ggrepel)
    library(reshape2)
})

# Load comparables data 

source("get_data.R")

library(ggmap)

BBox <- ggmap::make_bbox(lon = df.raw$longitude,lat = df.raw$latitude)

b <- get_map(BBox,maptype="toner-lite", source="stamen")

g <- ggmap(b) + geom_point(data = df.raw, aes(x = longitude, y = latitude)) +
    geom_label_repel(data = df.raw, aes(x = longitude, y = latitude, label = address))

JJHmisc::writeImage(g, "map", width = 8, height = 8, path = "../writeup/plots/")
