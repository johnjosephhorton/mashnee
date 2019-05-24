#! /usr/bin/env Rscript

suppressPackageStartupMessages({
    library(JJHmisc)
    library(dplyr)
    library(magrittr)
    library(ggplot2)
})

source("get_data.R")
## df.raw <- read.csv("../data/data.csv") %>% 
##   mutate(price = gsub(",","",price) %>% as.numeric)
# Load comparables data 

addParam <- genParamAdder("../writeup/parameters_name.tex")

states <- df.raw %$% state %>% table

ListToPhrase <- function(x){
    num.items <- length(x)
    if (num.items == 2){
        paste0(x[1], " and ", x[2])
    } else {
        paste0(paste0(x[1:(num.items - 2)], collapse = ", "), ", ", x[num.items -1], " and ", x[num.items])
    }
}

addParam("\\States",  ifelse(length(states) == 1, paste0("All the properties are in ", names(states), "."),
                             paste0("The properties are spread out over ", length(states), " states: ", ListToPhrase(names(states)), ".")))

cities <- df.raw %$% city %>% table



addParam("\\Cities",  ifelse(length(cities) == 1, paste0("All the properties are in ", names(cities), "."),
                             paste0("The properties are spread out over ", length(cities), " cities: ",
                                    ListToPhrase(names(cities)), ".")))


addParam("\\PropertyName",  df.raw %>% filter(comp == 0) %$% address)

addParam("\\PropertyCity", df.raw %>% filter(comp == 0) %$% city)
addParam("\\PropertyState", df.raw %>% filter(comp == 0) %$% state)

addParam("\\AvgDistance", (df.raw %>% filter(comp == 1) %$% miles %>% mean) %>% round(2))
addParam("\\MinDistance", (df.raw %>% filter(comp == 1) %$% miles %>% min) %>% round(2))
addParam("\\MaxDistance", (df.raw %>% filter(comp == 1) %$% miles %>% max) %>% round(2))


home.type <- df.raw %>% filter(comp == 0) %$% homeType %>% as.character

addParam("\\PropertyType", gsub("_", " ", tolower(home.type)))

property.types <- df.raw %>% filter(comp == 1) %$% homeType %>% table
                                 
addParam("\\TypeWarning", ifelse(length(property.types) > 1, "Not all comparables are the same property type, which could negatively impact the quality of the analysis.", ""))

property.built <-df.raw %>% filter(comp == 0) %$% yearBuilt
addParam("\\PropertyYearBuilt", property.built)

oldest <- df.raw %>% filter(comp == 1) %$% yearBuilt %>% min
addParam("\\Oldest", oldest)
youngest <- df.raw %>% filter(comp == 1) %$% yearBuilt %>% max
addParam("\\Youngest", youngest)

addParam("\\ExtremeWarningAgeYoung", ifelse(property.built > youngest,
                                       "A potential concern is that the target property is newer than all the comparables.", "")) 
addParam("\\ExtremeWarningAgeOld", ifelse(property.built < oldest,
                                       "A potential concern is that the target property is younger than all the comparables.", "")) 


addParam("\\NumberOfBedrooms",  df.raw %>% filter(comp == 0) %$% bedrooms)

addParam("\\NumberOfBaths",  df.raw %>% filter(comp == 0) %$% baths)

avg.beds  <- df.raw %>% filter(comp==1) %$% bedrooms %>% mean %>% round(1)
avg.baths <- df.raw %>% filter(comp==1) %$% baths %>% mean %>% round(1)

addParam("\\AverageBedrooms", avg.beds)
addParam("\\AverageBaths", avg.baths)

#addParam("\\YearBuilt",  df.raw %>% filter(comp == 0) %$% year)

addParam("\\PropertySqFt",  df.raw %>% filter(comp == 0) %$% square_feet %>% round(0) %>%
                            formatC(format = "f", digits = 0, big.mark = ",")
         )

property.price <-  df.raw %>% filter(comp == 0) %$% price

addParam("\\PropertyPrice", property.price %>% round(0) %>%
                            formatC(format = "f", digits = 0, big.mark = ",")
         )


addParam("\\NumberOfComps",  df.raw %>% filter(comp == 1) %>% nrow() )

min.price <- df.raw %>% filter(comp == 1) %$% price %>% min
max.price <- df.raw %>% filter(comp == 1) %$% price %>% max

addParam("\\MinPrice", min.price %>% round(0) %>% formatC(format = "f", digits = 0, big.mark = ","))
addParam("\\MaxPrice", max.price %>% round(0) %>% formatC(format = "f", digits = 0, big.mark = ","))

addParam("\\InPriceRange", ifelse(property.price > min.price & property.price < max.price, "is", "is not"))

F <- df.raw %>% filter(comp == 1) %$% price %>% ecdf

addParam("\\PricePercentile", 100 * F(property.price) %>% round(0))

df.raw %<>% mutate(price.error = (price - property.price)^2)

####
## Lot size
####

df.raw$acres <- with(df.raw, lotSize / 43560)

smallest.lot <- df.raw %$% acres %>% min
addParam("\\SmallestLot", smallest.lot %>% round(2))
largest.lot <- df.raw %$% acres %>% max
addParam("\\LargestLot", largest.lot %>% round(2))

property.lot.size <- df.raw %>% filter(comp == 0) %$% acres 
addParam("\\PropertyLotSize", property.lot.size %>% formatC(format = "f", big.mark = ",", digits = 2))

addParam("\\ExtremeWarningLargestLot", ifelse(property.lot.size > largest.lot,
                                       "A potential concern is that the target property has a larger lot than all the comparables.", "")) 
addParam("\\ExtremeWarningSmallestLot", ifelse(property.lot.size < smallest.lot,
                                       "A potential concern is that the target property is younger than all the comparables.", "")) 



addParam("\\PricePercentile", 100 * F(property.price) %>% round(0))


###############
# Property size 
###############

property.size <- df.raw %>% filter(comp == 0) %$% square_feet 
addParam("\\PropertySize", property.size %>% formatC(format = "f", big.mark = ",", digits = 0))

df.raw %<>% mutate(size.error = (square_feet - property.size)^2)

df.raw <- df.raw[order(df.raw$size.error),]
addParam("\\ClosestOnSize", df.raw[2,"address"] %>% as.character)

min.size <- df.raw %>% filter(comp == 1) %$% square_feet %>% min
max.size <- df.raw %>% filter(comp == 1) %$% square_feet %>% max

addParam("\\MinSize", min.size %>% round(0) %>% formatC(format = "f", digits = 0, big.mark = ","))
addParam("\\MaxSize", max.size %>% round(0) %>% formatC(format = "f", digits = 0, big.mark = ","))

addParam("\\InSizeRange", ifelse(property.size > min.size & property.size < max.size, "is", "is not"))

df.raw <- df.raw[order(df.raw$size.error),]
addParam("\\ClosestOnPrice", df.raw[2,"address"] %>% as.character)

addParam("\\MeanPricePerFoot",  df.raw %>% filter(comp == 1) %>% mutate(price.per.foot = price / square_feet) %$%
                                price.per.foot %>% mean %>% round(0))

addParam("\\MeanPricePerFootFocal",  df.raw %>% filter(comp == 0) %>% mutate(price.per.foot = price / square_feet) %$%
                                price.per.foot %>% mean %>% round(0))



mean.sqft.comp <- df.raw %>% filter(comp == 1) %>% mutate(price.per.foot = price / square_feet) %$%
                                price.per.foot %>% mean %>% round(0)

mean.sqft.target <- df.raw %>% filter(comp == 0) %>% mutate(price.per.foot = price / square_feet) %$%
                                price.per.foot %>% mean %>% round(0)

addParam("\\MeanPricePerFootPct", ((mean.sqft.comp - mean.sqft.target)/mean.sqft.target) %>% multiply_by(100) %>% round(0) %>% abs) 
addParam("\\ComparePricePerFoot", ifelse(mean.sqft.target > mean.sqft.comp, "higher", "lower"))


m <- lm(price ~ square_feet, data = df.raw %>% filter(comp == 1))

addParam("\\MarginalPricePerFoot", coef(m)["square_feet"] %>% round(0))

addParam("\\Intercept", coef(m)["(Intercept)"] %>% round(0) %>% formatC(format = "f", digits = 0, big.mark = ","))

addParam("\\PropertyPredict", predict(m, newdata = df.raw %>% filter(comp == 0)) %>% as.numeric %>%
                              formatC(format = "f", digits = 0, big.mark = ","))

property.price <- df.raw %>% filter(comp == 0) %$% price
predicted.price <- predict(m, newdata = df.raw %>% filter(comp == 0)) %>% as.numeric


addParam("\\ComparePredictedToActual", ifelse(predicted.price > property.price, "more", "less"))
addParam("\\PctDiff", ((predicted.price - property.price)/predicted.price) %>% multiply_by(100) %>% round(0))


