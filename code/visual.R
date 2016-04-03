rm(list = ls())
setwd("/Users/yujiangzhen/Documents/02Spring16/Data and Codebook")
library(data.table)
library(maps)
library(sqldf)
library(ggplot2)

#Venue by state
load("rdata/stateFreq.rdata")
p = qplot(long, lat, data = stateFreq, 
          group = group,
          fill = total,
          geom = "polygon")
p = p + scale_fill_continuous(low = "khaki1", high = "indianred4", guide="colorbar")
p = p + theme_bw()  + 
  labs(fill = "total" 
       ,title = "number of venue in the U.S. by state", x="", y="") 
p = p + geom_path(data = stateFreq, colour = "grey", size = 0.1)
png(filename="image/venue.png")
p
dev.off()

# market segment by state
load("rdata/mgStateFreq.rdata")

pMkSeg = qplot(long, lat, data = mgStateFreq , 
               group = group,
               fill = total,
               geom = "polygon")
pMkSeg = pMkSeg + scale_fill_continuous(low = "khaki1", high = "indianred4", guide="colorbar")
pMkSeg = pMkSeg + theme_bw()  + 
         labs(fill = "total" 
         ,title = "number of purchase by market in the U.S. by state", x="", y="")
pMkSeg = pMkSeg + geom_path(data = mgStateFreq, colour = "grey", size = 0.1)
png(filename="image/mkSeg.png")
pMkSeg
dev.off()


#Ticket per purchase by state
load("rdata/stateBuyTicket.rdata")
pTP = qplot(long, lat, data = stateBuyTicket, 
            group = group,
            fill = ticketPerBuy,
            geom = "polygon")

pTP = pTP + scale_fill_continuous(low = "khaki1", high = "indianred4", guide="colorbar")
pTP = pTP + theme_bw()  + 
  labs(fill = "ticket/purchase" 
       ,title = "Average ticket per purchase in U.S.", x="", y="") 
pTP = pTP + geom_path(data = stateBuyTicket , 
                      colour = "grey", size = 0.1)
png(filename="image/ticket_purchase.png")
pTP
dev.off()
