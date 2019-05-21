library(DBI)

source("config.R")

con <- dbConnect(RSQLite::SQLite(), path.to.db)

df.raw <- dbGetQuery(con, paste0("select * from properties where order_id = ", order.number))
