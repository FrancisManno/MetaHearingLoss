# ----------------------------------------------------------------------------------- #
####        FUNCTIONS                   ####        
# ----------------------------------------------------------------------------------- #
#### Lollipop for frequency tables   #### 
lollipop <- function(Table, Title, Ylim, Order=TRUE, Color="royalblue3") {
  require(plyr)
  require(ggplot2)
  require(extrafont)
  datos <- data.frame(x=names(Table), y=as.vector(Table))
  if (Order==TRUE) {
    # Ordered lollipop chart
    datos %>%
      arrange(y) %>%
      mutate(x=factor(x,x)) %>%
      ggplot( aes(x=x, y=y)) +
      geom_segment( aes(x=x, xend=x, y=0, yend=y), color=Color, size=1) +
      geom_point( color=Color, size=3, alpha=0.85) +
      theme_light() +
      coord_flip(ylim = Ylim) +
      theme(
        panel.grid.major.y = element_blank(),
        panel.border = element_blank(),
        axis.ticks.y = element_blank()
      ) +
      xlab("") +
      ylab("Frecuency") +
      ggtitle(Title) +
      theme_grey(base_family="Arial") 
  } else {
    datos$x <- factor(datos$x, levels = rev(names(Table)))
    ggplot( datos, aes(x=x, y=y)) +
      geom_segment( aes(x=x, xend=x, y=0, yend=y), color=Color, size=1) +
      geom_point( color=Color, size=3, alpha=0.85) +
      theme_light() +
      coord_flip(ylim = Ylim) +
       theme(
         panel.grid.major.y = element_blank(),
         panel.border = element_blank(),
         axis.ticks.y = element_blank()
      ) +
      xlab("") +
      ylab("Frecuency") +
      ggtitle(Title) +
      theme_grey(base_family="Arial") 
  }
  
}

# ----------------------------------------------------------------------------------- #
#### Bar graph from frequency table  #### 
bargraph <- function(Table,Title,Color="royalblue3"){
  require(extrafont)
  require(scales)
  par(family="Tahoma")
  Table <- Table[order(Table,decreasing = FALSE)]
  barplot(Table,horiz = TRUE,las=2,main=Title,space = 0.1,col = alpha(Color,0.6),border = Color,lwd=1)
}

# ----------------------------------------------------------------------------------- #
#### FOREST PLOT   #### 
# https://cran.r-project.org/web/packages/forestplot/vignettes/forestplot.html
sub.forest2 <- function(meta.mod, Title, res=NULL) { par(mfrow=c(1,1))
  # Random effect model
  if (is.null(res)) {
  res <- rma(yi=hedgesG, vi=varG, data = meta.mod, measure = "MD",method="REML",
             slab=yrAu)}
  # weigths
  #O <- funnel(mod1,yaxis = "wi")
  
  ### to specify exactly in which rows the outcomes will be plotted)
  Sublevel <- meta.mod$Side
  D <- dim(meta.mod)[1]
  RL <- as.vector(table(droplevels(Sublevel)))
  K <- seq(1,by = 2,length.out = length(RL))
  Row <- rep(K, times=RL) + 1:D
  # par margins
  par(mar=c(4,4,1,2))
  forest(res, xlim=c(-16, 6), at=c(-5,0,3),
         ilab=cbind(round(meta.mod[,c("HL.age","Con.Age","N.total")],2),meta.mod$big.side),
         ilab.xpos=c(-12,-11,-10,-7.5), cex=0.75, ylim=c(-1, max(Row)+4),
         order=order(Sublevel,meta.mod$hedgesG),rows=Row,showweights = TRUE,
         xlab="Hedge's G", mlab="", psize=1,col = "gray35",border = "gray35", col.predict = "blue")
  # All model text
  text(-16, -1, pos=4, cex=0.75, bquote(paste("RE Model for All Studies (Q = ",
                                              .(formatC(res$QE, digits=2, format="f")), ", df = ", .(res$k - res$p),
                                              ", p = ", .(formatC(res$QEp, digits=2, format="f")), "; ", I^2, " = ",
                                              .(formatC(res$I2, digits=1, format="f")), "%)")))
  ### font and save original settings in object 'op'
  op <- par(cex=0.75, font=4, mar=c(5.1, 4.1, 4.1, 2.1))
  
  ### switch to bold font
  par(font=2)
  
  # Subgroups
  Noms <- names(table(droplevels(Sublevel)))
  Sub <- max(Row)+1; for (i in length(Row):2) {if (Row[i]-Row[i-1]>1){Sub <- c(Row[i-1]+1,Sub)}}
  text(-16, Sub, pos=4,Noms)
  
  # Main Title
  text(-5,D+4+max(K), Title,cex = 1.5)
  ### add column headings to the plot
  text(c(-12,-11,-10,-7.5), D+2.5+max(K), c("Ptn", "Ctl", "N", "ROI"))
  text(c(-11.5),           D+3+max(K), c("Age"))
  text(-16,               D+2.5+max(K), "Year & Author",  pos=4,font=2)
  text(3,                 D+2.5+max(K), "Weights", pos=2,cex = 0.75)
  text(6,                 D+2.5+max(K), "Hedge's G [95% CI]", pos=2, cex = 0.75)
  
  # Plot meta result for subsets
  rem.text <- function(Subset,Ypos){
    res.tmp <- rma(yi=hedgesG, vi=varG, data = meta.mod, measure = "MD",method="REML",
                   slab=paste(year, study, sep=", "), subset=(Side==Subset))
    addpoly(res.tmp, row=Ypos, cex=0.75, mlab="",col = "royalblue2",border = "royalblue2")
    text(-16, Ypos, pos=4, cex=0.75, bquote(paste("RE Model for Subgroup (Q = ",
                                                  .(formatC(res.tmp$QE, digits=2, format="f")), ", df = ", .(res.tmp$k - res.tmp$p),
                                                  ", p = ", .(formatC(res.tmp$QEp, digits=2, format="f")), "; ", I^2, " = ",
                                                  .(formatC(res.tmp$I2, digits=1, format="f")), "%)")))}
  # Plot subsets results
  Sub <- c(0,Sub)
  for (i in 1:length(Noms)) { try(rem.text(Noms[i],Sub[i]+1)) }
  
  ### set par back to the original settings
  par(op)}

sub.forest <- function(meta.mod, Title, res=NULL) { par(mfrow=c(1,1))
  # Random effect model
  if (is.null(res)) {
    res <- rma(yi=hedgesG, vi=varG, data = meta.mod, measure = "MD",method="REML",
               slab=yrAu)}
  # weigths
  #O <- funnel(mod1,yaxis = "wi")
  
  ### to specify exactly in which rows the outcomes will be plotted)
  Sublevel <- meta.mod$Side
  D <- dim(meta.mod)[1]
  RL <- as.vector(table(droplevels(Sublevel)))
  K <- seq(1,by = 2,length.out = length(RL))
  Row <- rep(K, times=RL) + 1:D
  # par margins
  par(mar=c(4,4,1,2))
  forest(res, xlim=c(-16, 6), at=c(-5,0,3),
         ilab=cbind(round(meta.mod[,c("N.total")],2),as.character(meta.mod$ROI), as.character(meta.mod$Big.area) ),
         ilab.xpos=c(-11.5,-10,-7.5), cex=0.75, ylim=c(-1, max(Row)+4),
         order=order(Sublevel,meta.mod$hedgesG),rows=Row,showweights = TRUE,
         xlab="Hedge's G", mlab="", psize=1,col = "gray35",border = "gray35", col.predict = "blue")
  # All model text
  text(-16, -1, pos=4, cex=0.75, bquote(paste("RE Model for All Studies (Q = ",
                                              .(formatC(res$QE, digits=2, format="f")), ", df = ", .(res$k - res$p),
                                              ", p = ", .(formatC(res$QEp, digits=2, format="f")), "; ", I^2, " = ",
                                              .(formatC(res$I2, digits=1, format="f")), "%)")))
  ### font and save original settings in object 'op'
  op <- par(cex=0.75, font=4, mar=c(5.1, 4.1, 4.1, 2.1))
  
  ### switch to bold font
  par(font=2)
  
  # Subgroups
  Noms <- names(table(droplevels(Sublevel)))
  Sub <- max(Row)+1; for (i in length(Row):2) {if (Row[i]-Row[i-1]>1){Sub <- c(Row[i-1]+1,Sub)}}
  text(-16, Sub, pos=4,Noms)
  
  # Main Title
  text(-5,D+4+max(K), Title,cex = 1.5)
  ### add column headings to the plot
  text(c(-11.5,-10,-7.5), D+2.5+max(K), c("N", "ROI", "Area"))
  text(-16,               D+2.5+max(K), "Year & Author",  pos=4,font=2)
  text(3,                 D+2.5+max(K), "Weights", pos=2,cex = 0.75)
  text(6,                 D+2.5+max(K), "Hedge's G [95% CI]", pos=2, cex = 0.75)
  
  # Plot meta result for subsets
  rem.text <- function(Subset,Ypos){
    res.tmp <- rma(yi=hedgesG, vi=varG, data = meta.mod, measure = "MD",method="REML",
                   slab=paste(year, study, sep=", "), subset=(Side==Subset))
    addpoly(res.tmp, row=Ypos, cex=0.75, mlab="",col = "royalblue2",border = "royalblue2")
    text(-16, Ypos, pos=4, cex=0.75, bquote(paste("RE Model for Subgroup (Q = ",
                                                  .(formatC(res.tmp$QE, digits=2, format="f")), ", df = ", .(res.tmp$k - res.tmp$p),
                                                  ", p = ", .(formatC(res.tmp$QEp, digits=2, format="f")), "; ", I^2, " = ",
                                                  .(formatC(res.tmp$I2, digits=1, format="f")), "%)")))}
  # Plot subsets results
  Sub <- c(0,Sub)
  for (i in 1:length(Noms)) { try(rem.text(Noms[i],Sub[i]+1)) }
  
  ### set par back to the original settings
  par(op)}

# ----------------------------------------------------------------------------------- #
#### Meta-regression Heterogeneity to plot the contributions for each model  #### 
plot.meta <- function(Model,Title){
  par(mfrow=c(2,2))
  ### create contour enhanced funnel plot (with funnel centered at 0)
  if (!dim(Model$b)[1]==1){
    funnel(Model, level=c(90, 95, 99), shade=c("white", "gray", "darkgray"))
  } else {
    funnel(Model, level=c(90, 95, 99), shade=c("white", "gray", "darkgray"), refline=Model$b)
    #### Radial plot Galbraith 
    radial(Model, main=Title)
  }
  #### Baujat plot
  baujat(Model,symbol = "slab",bty='l')
  #### QQ-plot
  qqnorm(Model, main=Title,pch=20)
  #    }}
}

# ----------------------------------------------------------------------------------- #
#### Cohen's D confidence intervals   #### 
cohen.d <- function(u1, u2, s1, s2, n1, n2) {
  # Pooled standard deviation for two independent samples
  s <- sqrt(((n1-1)*s1^2 + (n2-1)*s2^2)/(n1+n2-2))
  
  # Cohen's D
  D <- (u2-u1)/s
  return(D)
}

# ----------------------------------------------------------------------------------- #
#### Cohen's D confidence intervals   #### 
cohen_ci <- function(d, N, Alpha) {
  # Hedges, L. V., & Olkin, I. (1985). Statistical methods for meta.
  # 1-alpha confidence interval = d +/- se * Zcrit
  # se = \sqrt{\div{1}{N} + \div{d^2}{2n}}
  # Inverse of the standard normal cumulative distribution
  Z <- qnorm(1-Alpha/2)
  
  # Standar Error
  se <- sqrt( (1/N)+(d^2/(2*N)) )
  
  # Confidence Intervals
  d.lo <- d-se*Z
  d.up <- d+se*Z
  
  # Hedge'G
  hG <- d*(1-3/(4*(N-1)-1))
  return(cbind(d.lo, d.up, se, hG))
}

# ----------------------------------------------------------------------------------- #
####  forest table with Cohen'D CI estimates ####  
forestable <- function(DF){
  require(extrafont)
  tabletext <- cbind(DF$Source,as.character(DF$Side),as.character(DF$N.total),round(DF$hedgesG,2),round(DF$varG,2))
  tabletext <- rbind(c("Study","Side","Number","Cohens'D","Variance"),tabletext)
  CI <- cohen_ci(DF$hedgesG, DF$N.total, 0.05)
  own <- fpTxtGp(label = gpar(fontfamily = "Tahoma"),ticks = gpar(cex=0.75),cex=0.5)
  forestplot(tabletext[-1,],mean = DF$hedgesG, lower = CI[,1], upper =CI[,2],
             clip=c(-6,2),txt_gp = own, boxsize=0.2,col=fpColors(box="royalblue",line="darkblue", summary="royalblue"), 
             xticks = seq(-6,2,2), grid = structure(c(1), gp = gpar(lty = 2, col = "#CCCCFF")),cex=0.05)
}


# ----------------------------------------------------------------------------------- #
#### Variance estimation from effect size measures   #### 
# Estimates the variances from a Cohen's D
varD <- function(n1, n2, d){
  #https://trendingsideways.com/the-cohens-d-formula
  Vd <- (((n1+n2)/(n1*n2))+(d^2/2*(n1+n2-2)))*((n1+n2)/(n1+n2-2))
  return(Vd)}
varDe <- function(n1, n2, d){
  #https://stats.stackexchange.com/questions/144084/variance-of-cohens-d-statistic
  Vd <- ((n1+n2)/(n1*n2))+((d^2)/(2*(n1+n2-2)))
  return(Vd)  }

