library(DBI)

by.hand <- FALSE
if (by.hand){
   order.number <- 4
   path.to.db <- "~/GG/instance/GG.sqlite"
}  else {
   source("config.R")
}


con <- dbConnect(RSQLite::SQLite(), path.to.db)

df.raw <- dbGetQuery(con, paste0("select * from properties where order_id = ", order.number))
