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

#