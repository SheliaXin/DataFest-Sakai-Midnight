library(readr)
library(dplyr)
library(magrittr)
library(data.table)
library(RSQLite)
library(dummies)
library(lubridate)

purchase <- fread("approved_data_purchase-v5.csv")

purchase$sales_ord_tran_dt = ymd(purchase$sales_ord_tran_dt)
purchase = purchase %>% arrange(sales_ord_tran_dt)

con = dbConnect(RSQLite::SQLite(), ":memory:")
dbWriteTable(con, "purchase", purchase)
db <- select(purchase, purch_party_lkup_id, trans_face_val_amt, major_cat_name, event_id,primary_act_id, primary_act_name,
             tickets_purchased_qty,sales_ord_tran_dt,venue_state)
dum <- data.frame(dummy(db$major_cat_name))
dbb <- db %>% mutate(art=dum$major_cat_name.ARTS,concerts=dum$major_cat_name.CONCERTS,
                     family=dum$major_cat_name.FAMILY,misc=dum$major_cat_name.MISC,
                     movies=dum$major_cat_name.MOVIES,sports=dum$major_cat_name.SPORTS)

dbWriteTable(con, "dbb", dbb) 
query1 <- "SELECT purch_party_lkup_id, 
SUM(trans_face_val_amt) AS revenue,
SUM(art) AS art,
SUM(concerts) AS concerts,
SUM(family) AS family,
SUM(misc) AS misc,
SUM(movies) AS movies,
SUM(sports) AS sports,
SUM(CASE WHEN tickets_purchased_qty > 0 THEN 1 ELSE 0 END) AS nBuy, 
SUM(tickets_purchased_qty) AS nTickets FROM dbb GROUP BY purch_party_lkup_id,primary_act_id"
res1 <- dbSendQuery(con, query1) 
db1 <- dbFetch(res1, n=-1)  # n=-1 means return all
dbRemoveTable(con,"dbb")

dbWriteTable(con, "db1", db1) 
query2 <- "SELECT purch_party_lkup_id, 
SUM(revenue) AS revenue,
SUM(art) AS art,
SUM(concerts) AS concerts,
SUM(family) AS family,
SUM(misc) AS misc,
SUM(movies) AS movies,
SUM(sports) AS sports,
SUM(nBuy) AS nBuy, 
SUM(nTickets) AS nTickets FROM db1 GROUP BY purch_party_lkup_id"
res2 <- dbSendQuery(con, query2) 
db2 <- dbFetch(res2, n=-1)  # n=-1 m
dbRemoveTable(con,"db1")


### calculate the revenue
D_true = db2 %>% filter(nBuy > 1 & nTickets/nBuy <6)
D_one = db2 %>% filter(nBuy == 1) 
D_s = db2 %>% filter(nBuy > 1 & nTickets/nBuy >=6) 

rmean = c(mean(D_true$revenue),mean(D_one$revenue),mean(D_s$revenue))
rsum = c(sum(D_true$revenue),sum(D_one$revenue),sum(D_s$revenue))


db3 <- db2 %>% mutate(p_event=rowSums(db2[,c('art','concerts','family','misc','movies','sports')]!=rep(0,nrow(db2)))/db2$nBuy,
                      p_art=db2$`count(primary_act_id)`/db2$nBuy)
db3[,c('art','concerts','family','misc','movies','sports')]=db3[,c('art','concerts','family','misc','movies','sports')]/db3$nBuy
db4 <- db3 %>% select(purch_party_lkup_id,primary_act_name,nBuy,nTickets,p_event,p_art,
                      art,concerts,family,misc,movies,sports)
names(db4) = c('purchase_id','primary_act_name',"nBuy","nTickets","p_event","p_art","art","concerts","family","misc","movies","sports")

data1 = db4 %>% filter(nBuy>1)
data2 = db4 %>% filter(nBuy==1)

## Join Tables
dbWriteTable(con, "db11", db11) 
dbWriteTable(con, "db33", db33)
query44 <- "SELECT * FROM db11 JOIN db33 ON db11.purch_party_lkup_id = db33.purch_party_lkup_id"
res44 <- dbSendQuery(con, query44) 
db44 <- dbFetch(res44, n=-1) 


# Plots
library(dplyr)
library(ggplot2)

dat = rbind(data1,data2)[,2:3] %>% tbl_df() %>% sample_frac(0.1)
dat1 = dat %>% filter(nBuy==1) %>% mutate(col=1)
dat2 = dat %>% filter(nBuy>1 & nTickets/nBuy<6) %>% mutate(col=2)
dat3 = dat %>% filter(nBuy>1 & nTickets/nBuy>=6) %>% mutate(col=3)
dat_plot = rbind(dat1,dat2,dat3)
ggplot(dat_plot,aes(x = log(nBuy), y = log(nTickets),col = dat_plot$col))+
  geom_point()+
  labs(x="log(# of Purchases)",y="log(# of Tickets)")+
  theme(axis.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=32),
        legend.title=element_blank())
        
        
