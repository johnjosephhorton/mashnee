library(DBI)

if (!file.exists("config.R")){
    path.to.db <- "~/GG/instance/GG.sqlite"
    con <- dbConnect(RSQLite::SQLite(), path.to.db)
    order.number <- as.numeric(dbGetQuery(con, "select max(id) from orders") )
}  else {
   source("config.R")
}

con <- dbConnect(RSQLite::SQLite(), path.to.db)

df.raw <- dbGetQuery(con, paste0("select p.*, u.url from properties as p join urls as u on u.id = p.url_id where p.order_id = ",
                                 order.number))

library(geosphere)

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

