
library(DBI)

con <- dbConnect(RSQLite::SQLite(), "/home/john/GG/instance/GG.sqlite")

df.raw <- dbGetQuery(con, "select * from properties where order_id = 3")
