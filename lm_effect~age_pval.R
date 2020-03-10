# ------------------------------------------------------------------------------ #
#### LINEAR REGRESSION HEDGES'S G by AGE with P-VALUE and CONFIDENCE INTERVAL #### 
# ------------------------------------------------------------------------------ #
scaleBetween <- function(X,a,b) {
  Fx <- ((b-a)*(X-min(X))/(max(X)-min(X)))+a
  return(Fx)}

df <- data.frame(na.omit(cbind(
  WM.fa.R$HL.age,
  WM.fa.R$hedgesG,
  WM.fa.R$HL.age-WM.fa.R$Con.Age,
  WM.fa.R$N.total,
  WM.fa.R$Etiology)))

Main <- "Right White Matter vs Age"
X <- df$X1 # Age
Y <- df$X2 # Hedges'G
N <- scaleBetween(df$X4,1,4) # Total Size
G <- c("red4","blue4")[df$X5]
f <-lm(Y~X,data = df)

par(mfrow=c(1,2))
plot(jitter(X,10),Y, xlab = "Age", ylab="Hedge's G", main= Main, bty="n",cex=N,pch=21,bg=alpha(G,0.6),col=G)

# Confidence Intervals at 95%
newx <- seq(min(X,na.rm = T), max(X,na.rm = T), length.out=length(X))
preds <- predict(f, interval="confidence")
polygon(c(rev(newx), newx), c(rev(preds[ ,3]), preds[ ,2]), col = alpha('gray45',0.4), border = NA)

abline(f,col="gray35",lwd=2)
lines(newx,preds[,1],lwd=2,col="gray35")


# Calculate the p-value based on a normal distribution
se <- (preds[,3]-preds[,2])/(2*1.96)
tstats <- preds[,1]/se
pval <- 2*pnorm(-abs(tstats))

## Allow a second plot on the same graph
par(new=TRUE)

## Plot the second plot and put axis scale on right
plot(newx, 1-pval, pch=15,  xlab="", ylab="", ylim=c(0.95,1), 
     axes=FALSE, type="l", col="red")
## a little farther out (line=4) to make room for labels
mtext("p-value",side=4,col="red",line=-1.5) 
axis(4, ylim=c(0,0.05), col="red",col.axis="red",las=2,pos = 65)

plot(preds[,1], Y,ylim=c(-2,0),xlim=c(-2,0),xlab = "Predicted Hedge's G",ylab = "Original Hedge's G",
     cex=N,pch=21,bg=alpha(G,0.6),col=G)
lines(-2:2,-2:2,col="red",lty=2)




reg.conf.intervals <- function(x, y, Group, Cex, Ylim, Main) {
  # https://rpubs.com/aaronsc32/regression-confidence-prediction-intervals
  # removes na values
  df <- data.frame(x,y)[complete.cases(data.frame(x,y)),]
  x <- df$x
  y <- df$y
  
  # Find length of y to use as sample size
  n <- length(y) 
  lm.model <- lm(y ~ x) # Fit linear model
  
  # Extract fitted coefficients from model object
  b0 <- lm.model$coefficients[1]
  b1 <- lm.model$coefficients[2]
  
  # Find SSE and MSE
  sse <- sum((y - lm.model$fitted.values)^2)
  mse <- sse / (n - 2)
  
  t.val <- qt(0.975, n - 2) # Calculate critical t-value
  
  # Fit linear model with extracted coefficients
  x_new <- 1:max(x)
  y.fit <- b1 * x_new + b0
  
  # Find the standard error of the regression line
  se <- sqrt(sum((y - y.fit)^2) / (n - 2)) * sqrt(1 / n + (x - mean(x))^2 / sum((x - mean(x))^2))
  
  # Fit a new linear model that extends past the given data points (for plotting)
  x_new2 <- 1:max(x + 100)
  y.fit2 <- b1 * x_new2 + b0
  
  # Warnings of mismatched lengths are suppressed
  slope.upper <- suppressWarnings(y.fit2 + t.val * se)
  slope.lower <- suppressWarnings(y.fit2 - t.val * se)
  
  # Collect the computed confidence bands into a data.frame and name the colums
  bands <- data.frame(cbind(slope.lower, slope.upper))
  colnames(bands) <- c('Lower Confidence Band', 'Upper Confidence Band')
  
  # Plot the fitted linear regression line and the computed confidence bands
  plot(x, y, cex = 1.75, pch = 20, col=NA, ylim=Ylim,bty='n', xlab="Age", ylab="Hedge's G",main=Main,axes = FALSE,xlim=c(0,75))
  axis(2,col.ticks = "black",tick = TRUE, col =NA,las=2)
  axis(1,col.ticks = "black",tick = TRUE, col =NA)
  rect(par("usr")[1],par("usr")[3],par("usr")[2],par("usr")[4],col = "gray95",border = NA)
  abline(h=seq(-10,10,by=2),v=seq(0,70,by=10),col="white",lwd=1.5)
  polygon(c(rev(x_new2), x_new2), c(rev(bands[ ,2]), bands[ ,1]), col = alpha('gray40',0.4), border = NA)
  lines(y.fit2, col = 'gray35', lwd = 2)
  #lines(bands[1], col = 'blue', lty = 2, lwd = 2)
  #lines(bands[2], col = 'blue', lty = 2, lwd = 2)
  points(x, y, pch= 21, bg=alpha(Group,0.4), col=Group, cex=Cex)
  
  # Print values
  text(paste("Intercept:", round(summary(lm.model)$coefficients[1],2), 
              "pval=",round(summary(lm.model)$coefficients[1,4],3)),x = 50,y=1)
  text(paste("Age:", round(summary(lm.model)$coefficients[2],2), 
              "pval=",round(summary(lm.model)$coefficients[2,4],3)),x = 50,y=0)
  
  # Calculate the p-value based on a normal distribution
  se <- (bands[,1]-bands[,2])/(2*1.96)
  tstats <- y.fit2/se
  pval <- 2*pnorm(-abs(tstats))
  
  ## Allow a second plot on the same graph
  par(new=TRUE)
  
  ## Plot the second plot and put axis scale on right
  plot(x_new2, pval, pch=15,  xlab="", ylab="", ylim=c(0,0.05), 
       axes=FALSE, type="l", col="red3")
  ## a little farther out (line=4) to make room for labels
  mtext("p-value",side=4,col="red3",line=1) 
  axis(4, ylim=c(0,0.05), col="red",col.axis="red",las=2)
  
  # return(bands)
}

plot.Slice <- function(Data, Lim, Main){
  df <- data.frame(Data$HL.age,Data$hedgesG,Data$N.total)
  df <- df[complete.cases(df),]
  x <- df[,1]
  y <- df[,2]
  n <- df[,3]
  G <- c("darkturquoise", "indianred2")[Data$Etiology]
  C <- scaleBetween(log(n),1,4)
  reg.conf.intervals(x,y,G,C,Lim,Main)
}


svg("~/Escritorio/2018_hearing_loss/MetaAnalysis/fig_tmp/right_GMvol~age.svg",width = 7,height = 5,pointsize = 13)
plot.Slice(GM.vol.R, c(-6,3), "Right Gray Matter Volume vs Age"); dev.off()

svg("~/Escritorio/2018_hearing_loss/MetaAnalysis/fig_tmp/left_GMvol~age.svg",width = 7,height = 5,pointsize = 13)
plot.Slice(GM.vol.L, c(-6,3), "Left Gray Matter Volume vs Age"); dev.off()

svg("~/Escritorio/2018_hearing_loss/MetaAnalysis/fig_tmp/right_WMvol~age.svg",width = 7,height = 5,pointsize = 13)
plot.Slice(WM.vol.R, c(-6,3), "Right White Matter Volume vs Age"); dev.off()

svg("~/Escritorio/2018_hearing_loss/MetaAnalysis/fig_tmp/left_WMvol~age.svg",width = 7,height = 5,pointsize = 13)
plot.Slice(WM.vol.L, c(-6,4), "Left White Matter Volume vs Age"); dev.off()

svg("~/Escritorio/2018_hearing_loss/MetaAnalysis/fig_tmp/right_WMfa~age.svg",width = 7,height = 5,pointsize = 13)
plot.Slice(WM.fa.R, c(-2,3), "Right White Matter FA vs Age"); dev.off()

svg("~/Escritorio/2018_hearing_loss/MetaAnalysis/fig_tmp/left_WMfa~age.svg",width = 7,height = 5,pointsize = 13)
plot.Slice(WM.fa.L, c(-2,3), "Left White Matter FA vs Age"); dev.off()



