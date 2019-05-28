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

source("get_data.R")
source("format_currency.R")

df.comps <- df.raw %>% filter(comp == 1) 

f <- "price ~ square_feet + I(square_feet^2) + lotSize + I(lotSize^2) + square_feet:lotSize"

GetPrice <- function(f, df.sample){
    m <- lm(as.formula(f), data = df.sample)
    predict(m, newdata = df.raw %>% filter(comp == 0))
}

price.hats <- c()
df.comps <- df.raw %>% filter(comp == 1) 
properties <- df.comps %$% address %>% unique
for(property in properties){
    price.hats <- c(price.hats, GetPrice(f, df.comps %>% filter(address != property)))
}

df.left.out <- data.frame(address = properties, price.prediction = price.hats) %>%
    mutate(pct.change = (price.prediction - GetPrice(f, df.comps))/GetPrice(f, df.comps)) %>%
    mutate(direction = ifelse(pct.change > 0, "pos", "neg"))

df.left.out$address <- with(df.left.out, reorder(address, pct.change, mean))

full.phrase <- with(data = df.left.out %>% filter(pct.change == min(df.left.out$pct.change)),
                    paste0("Removing ", address, " from the comps would lower the predicted price for the target property by ",
                           round(100 * abs(pct.change), 1), "%"
                           ))

phrase <- system(paste0("echo '", full.phrase,"' | fold -w 22 -s"), intern = TRUE) %>%
    paste0(collapse = "\n")

g <- ggplot(df.left.out, aes(x = address, y = pct.change, fill = direction), colour = "black") + geom_bar(stat = "identity") +
        scale_fill_manual("direction",
                      values = c("same" = "gray", "pos" = "lightgreen", "neg" = "pink")
                      ) + theme_bw() +
    geom_label_repel(data = df.left.out %>% filter(pct.change == min(df.left.out$pct.change)),
                     aes(y = 0, label = phrase), ylim = c(0, NA), size = 2) +
    ylab("Change to prediction") +
    scale_y_continuous(label = scales::percent) + 
    xlab("") + 
    coord_flip() +
    theme_bw() +
    theme(legend.position = "none") 

inches.per.row <- 0.25
num.rows <- nrow(df.raw)
width <- 4

JJHmisc::writeImage(g, "diagnostics", width = width, height = num.rows * inches.per.row, path = "../writeup/plots/")


## diagPlot<-function(model){
        
##     p3<-ggplot(model, aes(.fitted, sqrt(abs(.stdresid))))+geom_point(na.rm=TRUE)
##     p3<-p3+stat_smooth(method="loess", na.rm = TRUE)+xlab("Fitted Value")
##     p3<-p3+ylab(expression(sqrt("|Standardized residuals|")))
##     p3<-p3+ggtitle("Scale-Location")+theme_bw()
    
##     p4<-ggplot(model, aes(seq_along(.cooksd), .cooksd))+geom_bar(stat="identity", position="identity")
##     p4<-p4+xlab("Obs. Number")+ylab("Cook's distance")
##     p4<-p4+ggtitle("Cook's distance")+theme_bw()
    
##     p5<-ggplot(model, aes(.hat, .stdresid))+geom_point(aes(size=.cooksd), na.rm=TRUE)
##     p5<-p5+stat_smooth(method="loess", na.rm=TRUE)
##     p5<-p5+xlab("Leverage")+ylab("Standardized Residuals")
##     p5<-p5+ggtitle("Residual vs Leverage Plot")
##     p5<-p5+scale_size_continuous("Cook's Distance", range=c(1,5))
##     p5<-p5+theme_bw()+theme(legend.position="bottom")
    
##     p6<-ggplot(model, aes(.hat, .cooksd))+geom_point(na.rm=TRUE)+stat_smooth(method="loess", na.rm=TRUE)
##     p6<-p6+xlab("Leverage hii")+ylab("Cook's Distance")
##     p6<-p6+ggtitle("Cook's dist vs Leverage hii/(1-hii)")
##     p6<-p6+geom_abline(slope=seq(0,3,0.5), color="gray", linetype="dashed")
##     p6<-p6+theme_bw()
    
##     return(list(rvfPlot=p1, qqPlot=p2, sclLocPlot=p3, cdPlot=p4, rvlevPlot=p5, cvlPlot=p6))
## }


## diagPlts <- diagPlot(fortify(m))

## lbry<-c("grid", "gridExtra")
## lapply(lbry, require, character.only=TRUE, warn.conflicts = FALSE, quietly = TRUE)

## do.call(grid.arrange, c(diagPlts, main="Diagnostic Plots", ncol=3))

## m <- fortify(m)

## g.1 <- ggplot(m, aes(x = .fitted, y = .resid)) +
##     geom_point() +
##     geom_smooth(method="loess") +
##     geom_hline(yintercept=0, col="red", linetype="dashed") +
##     xlab("Fitted values") +
##     ylab("Residuals") +
##     ggtitle("Residual vs Fitted Plot")+
##     theme_bw()


## g.2 <- ggplot(m, aes(x = qqnorm(.stdresid)[[1]], y = .stdresid)) +
##     geom_point(na.rm = TRUE) +
##     geom_abline(aes(qqline(.stdresid)))+
##     xlab("Theoretical Quantiles")+
##     ylab("Standardized Residuals") +
##     ggtitle("Normal Q-Q")+
##     theme_bw()
