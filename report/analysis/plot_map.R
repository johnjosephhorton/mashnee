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


# Needs to the development version 
#library(devtools)
#install_github("dkahle/ggmap")

library(ggmap)

#register_google(key = "AIzaSyCZw9-XdxLmNeWaSR7qZi4WNPbyXamIkYk", write = TRUE)

BBox <- ggmap::make_bbox(lon = df.raw$longitude,lat = df.raw$latitude)

SquareOff <- function(box){
    left = box[1]
    bottom = box[2]
    right = box[3]
    top = box[4]
    width = right - left
    height = top - bottom
    if (height > width){
        delta = height - width
        new.right = right + delta / 2
        new.left = left - delta / 2
        new.top = top
        new.bottom = bottom
    } else {
        delta = width - height
        new.top = top + delta / 2
        new.bottom = top - delta/2
        new.right = right
        new.left = left
    }
    new.box = c(new.left, new.bottom, new.right, new.top)
    names(new.box) <- c("left", "bottom", "right", "top")
    new.box
}

BBox.square <- SquareOff(BBox)

#BBox.square[4] - BBox.square[2]
#BBox.square[3] - BBox.square[1]

b <- get_map(BBox.square,maptype="toner-lite", source="stamen")

#height <- BBox$top - BBox$bottom
#width <- b["right"] - b["left"]

g <- ggmap(b) +
    geom_point(data = df.raw, aes(x = longitude, y = latitude, colour = factor(comp))) +
    geom_label_repel(data = df.raw, aes(x = longitude, y = latitude, label = address, colour = factor(comp))) +
    theme(legend.position = "none") +
    xlab("") +
    ylab("") +
    scale_y_continuous(NULL, NULL)

#b <- get_map(BBox, source="google")
#g <- ggmap(b, base_layer = ggplot(aes(x = latitude, y = longitude), data = df.raw)) + geom_point()
#print(g)
#g <- ggmap(b) +
#    geom_point(data = df.raw, aes(x = longitude, y = latitude, colour = factor(comp))) +
#    geom_label_repel(data = df.raw, aes(x = longitude, y = latitude, label = address, colour = factor(comp)))
# print(g)

JJHmisc::writeImage(g, "map", width = 8, height = 8, path = "../writeup/plots/")
