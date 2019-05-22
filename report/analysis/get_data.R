library(DBI)

if (!file.exists("config.R")){
   order.number <- 1
   path.to.db <- "~/GG/instance/GG.sqlite"
}  else {
   source("config.R")
}


con <- dbConnect(RSQLite::SQLite(), path.to.db)

#df.raw <- dbGetQuery(con, paste0("select * from properties where order_id = ", order.number))

df.raw <- dbGetQuery(con, paste0("select p.*, u.url from properties as p join urls as u on u.id = p.url_id where p.order_id = ",
                                  order.number))
