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

replace.names <- list("square_feet" = "\\\\textsc{SqFt}",
                      "lotSize" = "\\\\textsc{LotSize}")

LaTeXFormula <- function(f, replace.names, betas){
    x <- f
    for(key in names(replace.names)){
        x <- gsub(key, replace.names[key], x)
    }
    x <- gsub("I\\(|\\)", "", x)
    x <- gsub(":", " \\\\times ", x)
    terms <- unlist(strsplit(x, "\\+|~"))
    rhs <- terms[2:length(terms)]
    rhs
    latex.rhs <- paste0(betas[1])
    for (i in 1:(length(terms) - 1)){
        latex.rhs <- paste0(latex.rhs, " + \\\\ ", betas[i + 1], "\\cdot", rhs[i])
    }
    latex.rhs
}

m <- lm(as.formula(f), data = df.comps)
betas.raw <- coef(m)
ses <- sqrt(diag(vcov(m)))

## gets more reasonable significant digits 
BetterBeta <- function(beta, se){
    order.mag.se <- floor(log10(abs(se))) - 2
    round(beta / 10^(order.mag.se)) * 10^order.mag.se
}

betas <- formatC(mapply(BetterBeta, betas.raw, ses), big.mark = ",", format = "f", drop0trailing = TRUE)

writeLines(LaTeXFormula(f, replace.names, betas = betas), "../writeup/formula.tex")

df.raw$price.hat <- predict(m, newdata = df.raw)

df.compare <- df.raw %>% select(price, price.hat, address, comp) %>% melt(id.var = c("address", "comp")) %>%
    mutate(type = ifelse(variable == "price", "Actual", "Predicted"))

df.pct <- df.compare %>% group_by(address, comp) %>%
    summarise(
        middle.height = (value[type == "Actual"]  + value[type == "Predicted"])/2, 
        height = value[type == "Predicted"], 
        pct.change = round(100 * (value[type=="Predicted"] - value[type=="Actual"])/value[type=="Actual"], 1))

addParam <- genParamAdder("../writeup/parameters_models.tex")

median.abs.pct.diff <- df.pct %>% filter(comp == 1) %>% mutate(abs.pct.change = abs(pct.change)) %$% abs.pct.change %>% median

addParam("\\MAPE", median.abs.pct.diff)

# The prediction for 

y.hat <- predict(m, newdata = df.raw %>% filter(comp==0))

y.hat.interval <- predict(m, newdata = df.raw %>% filter(comp==0), interval = "prediction")

y.lower <- y.hat.interval[2]
y.upper <- y.hat.interval[3]
se <- (y.upper - y.lower)/(4 * 1.96)

num.draws <- 1000
df.norm <- data.frame(value = rnorm(num.draws, mean = y.hat, sd = se)) %>%
    mutate(address = "", comp = 0)

addParam("\\PropertyPricePredictionComplex", formatC(y.hat, big.mark = ",", format="f", digits = 0))



y.actual <- df.raw %>% filter(comp == 0) %$% price

addParam("\\PropertyPricePredictionComplexPercent", round(100*(y.hat - y.actual)/y.actual, digits = 1))

phrase <- system("echo '% difference between predicted sale price and list price' | fold -w 18 -s", intern = TRUE) %>%
    paste0(collapse = "\n")

g <- ggplot(data = df.compare, aes(x = type, y = value,
                               group = address,
                               colour = factor(comp)
                               )) +
    geom_line() + 
    scale_y_continuous(labels = priceFormatter()) + 
    theme_bw() + 
    theme(legend.position = "none") +
    geom_text_repel(data = df.compare %>% filter(type == "Actual"), aes(label = address),
                    xlim = c(NA, 1), size = 3,  
                    segment.colour = "grey") + 
    ylab("") +
    xlab("") + 
    geom_text_repel(data = df.pct, x = 2, aes(y = height, label = paste0(pct.change, "%")), segment.colour = "grey",
                    xlim = c(2, NA)) +
    geom_label(data = df.pct %>% filter(comp == 0), x = 1.5,
               aes(y = middle.height, label = phrase), size = 2.5) +
    geom_boxplot(data = df.norm, aes(x = 2.5, y = value), width = 0.1, outlier.size = -1)
    


JJHmisc::writeImage(g, "predictive_model", width = 5, height = 4, path = "../writeup/plots/")
