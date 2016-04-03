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

fit3 <- kmeans(data_trueFan[,2:11], 4)
plot(data_trueFan[,4:5], col = fit3$cluster, cex= .7)
plot(data_trueFan[,2], data_trueFan$concerts, col = fit3$cluster, cex= .7)
plot(data_trueFan[,2], data_trueFan$art, col = fit3$cluster, cex= .7)


# Ward Hierarchical Clustering
d <- dist(data_trueFan, method = "euclidean") # distance matrix
fit <- hclust(d, method="ward") 
plot(fit) # display dendogram
groups <- cutree(fit, k=3) # cut tree into 5 clusters
# draw dendogram with red borders around the 5 clusters 
rect.hclust(fit, k=3, border="red")



### regression
set.seed(123)
index = sample(1:nrow(myDataFanOne),10000)
myData <- myDataFanOne[index,c("firstEvent","market","firstPrice","isFan")]

X <- model.matrix(~ firstEvent + market + firstPrice, data = myData)
### Bayesian ###
y = as.matrix(myData$isFan)
n = length(y)

# Without interaction
# initial value
beta = rep(1, dim(X)[2])
ystar = rnorm(n, X %*% beta,1)

X1 = X
X1_sum <- t(X) %*% X
Ip <- diag(dim(X1)[2])
require(truncnorm)
require(monomvn)
# Gibbs sampling
sn = 5000
GSample <- matrix(NA, sn, n + dim(X1)[2])
GSample[1,] <- c(beta, ystar)

for(i in 2:sn){
  # y*
  a = b= rep(0,n)
  a[which(y==0)] <- -Inf
  b[which(y==1)] <- Inf
  ystar = rtruncnorm(n, a, b, as.matrix(X1) %*% beta,1)
  # beta
  sigma = solve(X1_sum + Ip)
  mu = sigma %*% colSums(ystar * X1)
  beta = mvrnorm(1,mu,sigma)
  GSample[i,] <- c(beta, ystar)
  if((i %/% 100) == (i/100)) print(i)
}

# trace plot
par(mfrow=c(5,4),mar=c(2,2,2,2),oma=c(0,0,2,0))
for(i in 2:dim(X1)[2]){
  plot(GSample[1:1000,i],type="l", ylab = "", main = colnames(X1)[i])
}
title(main = "Trace Plot", outer = TRUE)

# burn-in point
B = 100

# coefficient
beta_p.inter <- apply(GSample[(B+1):sn,1:dim(X1)[2]], 2, mean)
names(beta_p.inter) <- colnames(X1)
coef_B.inter <- beta_p.inter
save(coef_B.inter, file = 'coef_B.RData')

# misclassification
mis_B.inter <- sum(as.numeric((X1 %*% beta_p.inter) >0) != y)/length(y)

coef_B.inter[order(coef_B.inter)]
