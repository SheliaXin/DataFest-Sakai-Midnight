# setwd("/Users/sheliaxin/Documents/Duke/Courses/STA523/Final Proj/Final_Project_STA523")
library(dplyr)
library(RSQLite)
library(data.table)
purchase <- fread("approved_data_purchase-v5.csv")


## use sql
con = dbConnect(RSQLite::SQLite(), ":memory:")
dbWriteTable(con, "train", purchase)   # data frame -> database table

query <- "SELECT purch_party_lkup_id,  
SUM(CASE WHEN tickets_purchased_qty > 0 THEN 1 ELSE 0 END) AS nBuy, 
SUM(tickets_purchased_qty) AS nTickets FROM train GROUP BY purch_party_lkup_id"

# group by purchase number
res_v <- dbSendQuery(con, query) 
number_v <- dbFetch(res_v, n=-1)  # n=-1 means return all
number_v
