library(DBI)
library(geosphere)
library(magrittr)
library(dplyr)

if (!file.exists("config.R")){
    path.to.db <- "~/GG/instance/GG.sqlite"
    con <- dbConnect(RSQLite::SQLite(), path.to.db)
    order.number <- as.numeric(dbGetQuery(con, "select max(id) from orders") )
    randomize.address <- TRUE
}  else {
    source("config.R")
    randomize.address <- FALSE
    con <- dbConnect(RSQLite::SQLite(), path.to.db)
}


df.raw <- dbGetQuery(con, paste0("select p.*, u.url from properties as p join urls as u on u.id = p.url_id where p.order_id = ",
                                 order.number))


target.lat <- df.raw %>% filter(comp == 0) %$% latitude
target.lon <- df.raw %>% filter(comp == 0) %$% longitude

df.dist <- df.raw %>% filter(comp == 1) %>%
    select(address, latitude, longitude) %>%
    mutate(target.lon = target.lon,
           target.lat = target.lat
           )

x <- with(df.raw, matrix(c(longitude, latitude), ncol = 2))
y <- with(df.raw, matrix(c(target.lon, target.lat), ncol = 2))

df.raw$miles <- (distm(x, y, fun = distHaversine) / 1609.34)

#CleanName <- function(x) gsub("#", "\\\\textnumero", x)

CleanName <- function(x) gsub("#", " ", x)
df.raw$address <- sapply(df.raw$address, CleanName)

if (randomize.address){
    source("random_streets.R")
    df.raw$url <- 'http://www.galtongauss.com'
    df.raw$address <- FakeAddress(nrow(df.raw))
}
saveRDS(df.raw, "../data/data.rds")

