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

df.raw <- read.csv("../data/data.csv") %>% 
  mutate(price = gsub(",","",price) %>% as.numeric) %>%
    mutate(sq.ft.k = square_feet / 1000)

# Create comps data set 
df.comps <- df.raw %>% filter(comp == 1) 

X <- model.matrix(~ (sq.ft.k + bedrooms + baths)^2,
                  data = df.comps)

y <- df.comps$price
m.ridge <- glmnet(X,y)

plot(m.ridge)

cv.out <- cv.glmnet(X,y)
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

X.full <- model.matrix(~ (sq.ft.k + bedrooms + baths)^2, 
                            data = df.raw)

df.raw$price.hat <- predict(m.ridge, s = bestlam, newx = X.full) %>% as.numeric


g <- ggplot(data = df.raw, aes(x = square_feet, y = price, 
                          colour = factor(comp))) + 
  geom_point() + 
  geom_point(aes(y = price.hat), shape = 1) +
  geom_segment(aes(yend = price.hat, xend = square_feet), 
               arrow=arrow(type = "closed", length = unit(0.05, "inches"))) + 
  scale_x_continuous(labels = scales::comma) + 
  scale_y_continuous(labels = scales::comma) + 
  theme_bw() + 
  theme(legend.position = "none") + 
  ylab("Price") + 
  xlab("Square Feet") +
  annotate("text", x = df.raw %>% filter(comp == 0) %$% square_feet, y = df.raw %>% filter(comp == 0) %$% price, label = 'Actual') + 
  annotate("text", x = df.raw %>% filter(comp == 0) %$% square_feet, y = df.raw %>% filter(comp == 0) %$% price.hat, label = "Predicted") 

JJHmisc::writeImage(g, "predictive_model", width = 4, height = 4, path = "../writeup/plots/")
