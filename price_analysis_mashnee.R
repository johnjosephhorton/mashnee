#! /usr/bin/env Rscript

library(magrittr)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(glmnet)
library(reshape2)


# Load comparables data 

df.raw <- read.csv("captains_row_80_comps.csv") %>% 
  mutate(price = gsub(",","",price) %>% as.numeric)

############################
### Price versus square feet
############################

g <- ggplot(data = df.raw, aes(x = square_feet, y = price, 
                          colour = factor(comp))) + 
  geom_point() + 
  geom_label_repel(aes(label = address), 
             size = 1) + 
  scale_x_continuous(labels = scales::comma) + 
  scale_y_continuous(labels = scales::comma) + 
  theme_bw() + 
  theme(legend.position = "none") + 
  ylab("Price") + 
  xlab("Square Feet") 

print(g)

pdf("price_versus_square_feet.pdf", width = 3, height = 3)
print(g)
dev.off()

########################
## Fit regression models
########################

# Create comps data set 
df.comps <- df.raw %>% filter(comp == 1) 

m.base <- lm(I(price/1000) ~ I(square_feet/1000), data = df.comps)
df.raw$price.hat.base <- predict(m.base, newdata = df.raw)

m.rooms <- lm(I(price/1000) ~ I(square_feet/1000) + bedrooms + baths, data = df.comps)
df.raw$price.hat.rooms <- predict(m.rooms, newdata = df.raw)

m.water <- lm(I(price/1000) ~ I(square_feet/1000) + water_views, data = df.comps)
df.raw$price.hat.water <- predict(m.water, newdata = df.raw)

m.water.loc <- lm(I(price/1000) ~ I(square_feet/1000) + water_views + mashnee_island, data = df.comps)
df.raw$price.hat.water.loc <- predict(m.water.loc, newdata = df.raw)

#####################
### Regression tables
#####################
stargazer::stargazer(m.base,m.rooms, m.water, m.water.loc, type = "text", no.space = TRUE)

##################################################
### All the model predictions for 80 Captain's Row
##################################################

df.raw %>% filter(comp == 0) %>% select(contains("price.hat")) %>%
    melt 

##########################################################
## Maybe it's a few bad apples bringing down the estimate? 
## Bootstrap model (4) w/ replacement 
##########################################################

predicted.price <- c()
for (i in 1:1000){
    df.comps.sample <- df.comps[sample(1:nrow(df.comps),replace = TRUE), ]
    m.water.loc <- lm(I(price/1000) ~ square_feet + water_views + mashnee_island, data = df.comps.sample)
    df.raw$price.hat.water.loc <- predict(m.water.loc, newdata = df.raw)
    price.hat <- df.raw %>% filter(comp == 0) %$% price.hat.water.loc
    predicted.price <- c(predicted.price, price.hat)
}

pp <- predicted.price[predicted.price > 100 & predicted.price < 2000]
qplot(pp) 

pdf("predicted_price_bootstrap.pdf", width = 3, height = 3)
print(g)
dev.off()


###############################################################################
## Predictive model - ridge w/ CV for model tuning. All 2nd degree interactions
###############################################################################

X <- model.matrix(~ (square_feet + water_views + mashnee_island)^2,
                  data = df.comps)
y <- df.comps$price
m.ridge <- glmnet(X,y)

cv.out <- cv.glmnet(X,y)
bestlam <- cv.out$lambda.min

X.full <- model.matrix(~ (square_feet + water_views + mashnee_island)^2, 
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
  annotate("text", x = df.raw %>% filter(comp == 0) %$% square_feet, y = df.raw %>% filter(comp == 0) %$% price.hat, label = "Predicted") + 
  ggtitle("Predicted & Actual Price\n vs. Square Feet")

print(g)

pdf("with_predictions.pdf", width = 3, height = 3)
print(g)
dev.off()


## Bourne data

df.bourne <- read.csv("bourne_median_price_index.csv")
colnames(df.bourne) <- c("date", "price")

df.bourne %<>% mutate(date = as.Date(date))

g <- ggplot(data = df.bourne, aes(x = date, y = price)) +
    geom_line() +
    geom_smooth(span = 0.2) +
    geom_vline(xintercept = as.Date("2007-01-01"), colour = "red", linetype = "dashed") +
    xlab("Date") + ylab("Median sale\nprice in Bourne") +
    theme_bw()

pdf("bourne_median_sale_prices.pdf", width = 5, height = 3)
print(g)
dev.off()

df.bourne$index <- 1:nrow(df.bourne)


PredictPrice <- function(span){
    loess.smoother  <- loess(price ~ index, data = df.bourne, span = span)
    df.bourne$price.hat <- predict(loess.smoother)
    df.bourne %<>% mutate(days.away = abs(difftime(as.Date("2007-01-01"), date)) %>% as.numeric)
    sale.date <- df.bourne %>% filter(days.away == min(df.bourne$days.away)) %$% date
    p0 <- df.bourne %>% filter(date == sale.date) %$% price.hat
    p1 <- df.bourne %>% filter(date == max(df.bourne$date)) %$% price.hat
    pct.change <- ((p1 - p0)/p0)
    975 * (1 + pct.change)
}

sapply(seq(0.1, 0.8, 0.01), PredictPrice)
