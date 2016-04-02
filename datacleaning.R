# setwd("/Users/sheliaxin/Documents/Duke/Courses/STA523/Final Proj/Final_Project_STA523")
library(dplyr)
library(RSQLite)
library(data.table)
purchase <- fread("approved_data_purchase-v5.csv")
ga = fread("approved_ga_data_v2.csv")

## use sql
con = dbConnect(RSQLite::SQLite(), ":memory:")
dbWriteTable(con, "train", purchase)   # data frame -> database table

query <- "SELECT purch_party_lkup_id,  
SUM(CASE WHEN tickets_purchased_qty > 0 THEN 1 ELSE 0 END) AS nBuy, 
SUM(tickets_purchased_qty) AS nTickets FROM train GROUP BY purch_party_lkup_id"

# group by purchase number
res_v <- dbSendQuery(con, query) 
number_v <- dbFetch(res_v, n=-1)  # n=-1 means return all
number_v2 = number_v %>% filter(nBuy > 1)

head(number_v2)
hist(number_v2$nBuy)

unique(purchase$fin_mkt_nm)

stateFM = c("Georgia", "New York", "Miami", "Columbus", "Washington DC", "Michigan",
            "California", "Texas", "Texas", "Pennsylvania", "Texas", "California",
            "Massachusetts", "Missouri", "Florida", "Califonia", "Nevada", "North Carlonina",
            "New York", "Arizona", "Florida", "Canada", "Canada", "Canada", "Iowa",
            "Colorado", "Kentucky", "Canada", "Ohio", "Texas", "Ohio", "Oregon", "Washington",
            "Minnesota", "Wisconsin", "Texas", "Louisiana", "Canada", "Alabama", "New Mexico",
            "North Carolina", "Virginia", "Canada", "Missouri", "Pennsylvania", "Tennessee",
            "Hawaii", "Canada", "Canada", "Canada", "Canada", "Alaska", "Utah")