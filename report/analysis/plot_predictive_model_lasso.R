#! /usr/bin/env Rscript

suppressPackageStartupMessages({
    library(magrittr)
    library(dplyr)
    library(ggplot2)
    library(ggrepel)
    library(glmnet)
    library(reshape2)
})

# Load comparables data 

source("get_data.R")

source("format_currency.R")

## df.raw %<>% mutate(sq.ft.k = square_feet / 1000) %>%
##     mutate(lot.sq.ft.k = lotSize / 1000) %>% 
##     mutate(age = lubridate::year(Sys.Date()) - yearBuilt)

# Create comps data set 
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
    x <- gsub(":", " \\times ", x)
    terms <- unlist(strsplit(x, "\\+|~"))
    rhs <- terms[2:length(terms)]
    rhs
    latex.rhs <- paste0(betas[1])
    for (i in 1:(length(terms) - 1)){
        latex.rhs <- paste0(latex.rhs, "+ \\\\ ", betas[i + 1], "\\cdot", rhs[i])
    }
    latex.rhs
}

writeLines(LaTeXFormula(f, replace.names, betas = c(1,2,3,4,5,6)), "../writeup/formula.tex")




m <- lm(as.formula(f), data = df.comps)
summary(m)

X <- model.matrix(as.formula(f), data = df.comps)

#ggplot(data = df.comps, aes(x = square_feet, y = price)) + geom_point() + geom_smooth(method = "lm") 

y <- df.comps$price

m <- lm(price ~ square_feet, data = df.comps)

m.ridge <- glmnet(X,y)

plot(m.ridge)

cv.out <- cv.glmnet(X,y, grouped = FALSE, nfolds = nrow(df.comps))

plot(cv.out)

bestlam <- cv.out$lambda.min

fit <- glmnet(X, y, lambda=bestlam)

x <- coef(fit)


vars <- row.names(x)
betas <- round(as.numeric(x),0)

vars.non.zero <- vars[betas != 0]
betas.non.zero <- betas[betas != 0]

formula <- paste0(formatC(betas.non.zero[1], big.mark = ",", format = "f", digits = 0), "  + \\nonumber \\\\ ")

for(i in 2:length(vars.non.zero)){
    coef <- print(formatC(betas.non.zero[i], big.mark = ",", format = "f", digits = 0))
    var <- paste0("(", gsub("bedrooms", "BR", gsub(":", " \\\\times ", vars.non.zero[i])), ")")
    formula <- paste0(formula, " ", print(paste0(coef, " \\cdot ", print(var))), ifelse(i == length(vars.non.zero),""," +"), "\\\\ \\nonumber")
}

writeLines(text = formula, con = "../writeup/formula.tex")

X.full <- model.matrix(as.formula(f), 
                            data = df.raw)

#df.raw$price.hat <- predict(m.ridge, s = bestlam, newx = X.full) %>% as.numeric

df.raw$price.hat <- predict(m, newdata = df.raw)


y <- predict(m.ridge, s = bestlam, newx = X.full, interval="predict") 

df.compare <- df.raw %>% select(price, price.hat, address, comp) %>% melt(id.var = c("address", "comp")) %>%
    mutate(type = ifelse(variable == "price", "Actual", "Predicted"))


df.pct <- df.compare %>% group_by(address, comp) %>%
    summarise(
        middle.height = (value[type == "Actual"]  + value[type == "Predicted"])/2, 
        height = value[type == "Predicted"], 
        pct.change = round(100 * (value[type=="Predicted"] - value[type=="Actual"])/value[type=="Actual"], 1))

df.pct %>% filter(comp == 1) %>% mutate(abs.pct.change = abs(pct.change)) %$% abs.pct.change %>% median

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
    geom_text_repel(data = df.pct, x = 2, aes(y = height, label = paste0(pct.change, "%")), segment.colour = "grey") +
    geom_label(data = df.pct %>% filter(comp == 0), x = 1.5,
                     aes(y = middle.height, label = "% difference\nbetween\npredicted\nand actual\nprices"), size = 2)


print(g)

JJHmisc::writeImage(g, "predictive_model", width = 5, height = 4, path = "../writeup/plots/")
