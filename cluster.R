# K-Means Clustering with 5 clusters
library(dplyr)
## k-means of all data
data = rbind(data1,data2)
fit <- kmeans(data[,2:3], 3)
plot(data[,2:3], col = fit$cluster, cex= .7)

## k-means of data without one-time buyers
fit1 <- kmeans(data1[,2:3], 2)
plot(data1[,2:3], col = fit1$cluster, cex= .7)

fit2<- kmeans(data1[,2:11], 3)
plot(data1[,2:3], col = fit2$cluster, cex= .7)

data_clustered = mutate(data, fit_cluster=fit$cluster)

plot(data_clustered[,2:3], col = data_clustered$fit_cluster, cex= .7)
plot(data_clustered[which(data_clustered$fit_cluster==1),2:3], cex= .7)


## ignore scalpers (977)
data_trueFan = data1[which(data1$nTickets/data1$nBuy <6 ),] 

fit3 <- kmeans(data_trueFan[,4:11], 2)
plot(data_trueFan[,4:5], col = fit3$cluster, cex= .7)
plot(data_trueFan[,2], data_trueFan[,8], col = fit3$cluster, cex= .7)
