# setwd("/Users/sheliaxin/Documents/Duke/Courses/STA523/Final Proj/Final_Project_STA523")
library(dplyr)
library(RSQLite)
library(data.table)
purchase <- fread("approved_data_purchase-v5.csv")
ga = fread("approved_ga_data_v2.csv")

## use sql
con = dbConnect(RSQLite::SQLite(), ":memory:")
dbWriteTable(con, "train", purchase)   # data frame -> database table

query <- "SELECT purch_party_lkup_id, ticket_text,  
SUM(CASE WHEN tickets_purchased_qty > 0 THEN 1 ELSE 0 END) AS nBuy, 
SUM(tickets_purchased_qty) AS nTickets FROM train GROUP BY purch_party_lkup_id"

# group by purchase number
res_v <- dbSendQuery(con, query) 
number_v <- dbFetch(res_v, n=-1)  # n=-1 means return all
number_v2 = number_v %>% filter(nBuy > 1)
number_v2$frac = number_v2$nTickets/number_v2$nBuy
numberScalpers = number_v2 %>% filter(frac > 5)


# IMPORTANT #
oneTimeBuyers = dim(number_v)[1] - dim(number_v2)[1] 
oneTimeBuyersPerc = oneTimeBuyers/dim(number_v)[1]*100

scalpers = dim(numberScalpers)[1]
scalpersPerc = scalpers/dim(number_v)[1]*100

trueFans = dim(number_v)[1] - (oneTimeBuyers + scalpers)
trueFans = trueFans/dim(number_v)[1]*100

qplot(number_v2$frac, bins = 20, main = "Ratio of Total Tickets/Total Purchases",
      xlab = "Ratio", ylab = "Frequency", fill = I("blue"), col = I("red"))

unique(purchase$fin_mkt_nm)

stateFM = c("Georgia", "New York", "Miami", "Columbus", "Washington DC", "Michigan",
            "California", "Texas", "Texas", "Pennsylvania", "Texas", "California",
            "Massachusetts", "Missouri", "Florida", "Califonia", "Nevada", "North Carlonina",
            "New York", "Arizona", "Florida", "Canada", "Canada", "Canada", "Iowa",
            "Colorado", "Kentucky", "Canada", "Ohio", "Texas", "Ohio", "Oregon", "Washington",
            "Minnesota", "Wisconsin", "Texas", "Louisiana", "Canada", "Alabama", "New Mexico",
            "North Carolina", "Virginia", "Canada", "Missouri", "Pennsylvania", "Tennessee",
            "Hawaii", "Canada", "Canada", "Canada", "Canada", "Alaska", "Utah")
            
## use sql
con = dbConnect(RSQLite::SQLite(), ":memory:")

#add up #of purchases and #of tickets according to event id
dbWriteTable(con, "purchase", purchase)   # data frame -> database table
query1 <- "SELECT event_id, major_cat_name,
SUM(CASE WHEN tickets_purchased_qty > 0 THEN 1 ELSE 0 END) AS nBuy, 
SUM(tickets_purchased_qty) AS nTickets FROM purchase GROUP BY event_id"
res1 <- dbSendQuery(con, query1) 
db1 <- dbFetch(res1, n=-1)  # n=-1 means return all

#add up total hits for each event
dbWriteTable(con, "ga", ga)   # data frame -> database table
query2 <- "SELECT event_id,
SUM(totals_hits) AS nhits FROM ga GROUP BY event_id"
res2 <- dbSendQuery(con, query2) 
db2 <- dbFetch(res2, n=-1)  # n=-1 means return all

#join two models according to event id
dbWriteTable(con, "db1", db1) 
dbWriteTable(con, "db2", db2)
query3 <- "SELECT * FROM db1 JOIN db2 ON db1.event_id = db2.event_id"
res3 <- dbSendQuery(con, query3) 
db3 <- dbFetch(res3, n=-1)

db3$frac = db3$nTickets/db3$nBuy

qplot(db3$frac, bins = 20, main = "Ratio of Total Tickets/Total Purchases",
      xlab = "Ratio", ylab = "Frequency", fill = I("blue"), col=I("red"))
