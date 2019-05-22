#! /usr/bin/env Rscript

suppressPackageStartupMessages({
    library(magrittr)
    library(dplyr)
    library(ggplot2)
    library(ggrepel)
    library(glmnet)
    library(reshape2)
    library(JJHmisc)
})

# Load comparables data 
source("get_data.R")

df.comps <- df.raw %>% select(address, comp, baths, bedrooms, square_feet, price, lotSize) %>% melt(id.vars = c("comp", "address"))

pretty.labels <- list("baths" = "Baths",
                      "bedrooms" = "Bedrooms",
                      "square_feet" = "Living space",
                      "lotSize" = "Lot size",
                      "price" = "Price"
                      )

#df.combo$variable <- with(df.combo, as.character(sapply(variable, function(x) pretty.labels[as.character(x)])))

df.comps %<>% group_by(variable) %>%
    mutate(value = (value - min(value)) / (max(value) - min(value))) %>% ungroup

g <- ggplot(data = df.comps, aes(x = value, fill = factor(comp))) +
    facet_wrap(~variable, ncol = 3) +
    geom_dotplot(stackgroups = TRUE, method = "dotdensity", binwidth = 0.1, binpositions = "bygroup") + 
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90)) +
    theme(legend.position = "none", strip.text.y = element_text(angle = 0)) +
 #   scale_y_continuous(NULL, breaks = NULL) + 
    ylab("% relative to target property") +
    xlab("") +
    scale_x_continuous(breaks = (0:10)/10)
#    coord_fixed() +
print(g)

JJHmisc::writeImage(g, "hist", width = 5, height = 5, path = "../writeup/plots/")




