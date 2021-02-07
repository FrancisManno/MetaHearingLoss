# ----------------------------------------------------------------------------------- #
#### LOADS DATA FUNCTIONS AND LIBRARIES ####
# ----------------------------------------------------------------------------------- #
# Tables and Rmarkdown output
library(pander)
library(knitr)
library(kableExtra)
library(lubridate)
# General libraries
library(viridis)     # Colormaps
library(scales)      # Alpha function for color transparency
library(corrplot)    # Correlation plots
library(extrafont)   # Include extra fonts in plots
library(ggplot2)     # Ggplots functions for R
library(ggExtra)     # Marginal histogram/density/violin/boxplot in ggplots
library(gridExtra)   # Array for ggplots, equivalent of par(mfrow) 
library(esc)         # Effect size library, for Hedges'g calculation
# Libraries for meta-analysis
library(meta)
library(metafor)
library(rmeta)
library(forestplot)  # Forestplot for meta-regression visualization

# set working directory
setwd("~/git_here/MetaHearingLoss/")
# Upload  functions and libraries
source("meta_functions.R")

# Upload database
meta <- read.csv("~/git_here/MetaHearingLoss/meta_sideDeaf.csv")

# Source of studies, "author + year"
meta$Source <- paste0(meta$year,", ",meta$study)
meta$yrAu <- paste0(meta$year,"-",sapply(strsplit(as.character(meta$study)," "), `[`, 1))

# Total N
meta$N.total <- meta$Number.Hearing.loss + meta$Number.Control

# Cohen's D with direction
meta$cohenD <- meta$Cohen.s.d*ifelse(meta$effect=="decrease",-1,1)

# hedges_g
meta$hedgesG <- hedges_g(d = meta$cohenD, totaln = meta$N.total)

# Cohen's D Variance
meta$varDe <- varDe(meta$Number.Hearing.loss, meta$Number.Control, meta$cohenD)

# Cohen's D Variance
meta$varG <- varDe(meta$Number.Hearing.loss, meta$Number.Control, meta$hedgesG)

# ----------------------------------------------------------------------------------- #
####        GM & WM LINEAR REGRESSIONS BY AGE                                            #### 
# ----------------------------------------------------------------------------------- #
GM.vol.R <- meta[meta$measure=="volume" & meta$matter=="GM" & meta$Side=="right",]
GM.vol.L <- meta[meta$measure=="volume" & meta$matter=="GM" & meta$Side=="left",]
WM.fa.R <- meta[meta$measure=="FA" & meta$matter=="WM" & meta$Side=="right",]
WM.fa.L <- meta[meta$measure=="FA" & meta$matter=="WM" & meta$Side=="left",]
WM.vol.R <- meta[meta$measure=="volume" & meta$matter=="WM" & meta$Side=="right",]
WM.vol.L <- meta[meta$measure=="volume" & meta$matter=="WM" & meta$Side=="left",]

# VOLUME - GRAY MATTER  RIGHT
svg(filename="fig_tmp/lm_GMvol-age_Right.svg", width=4,height=3,pointsize=14,family = "Arial")
ggplot(data = GM.vol.R) + 
  geom_point(mapping = aes(x = HL.age, y = cohenD, size=N.total, alpha=0.4)) +
  geom_smooth(mapping = aes(x = HL.age, y = cohenD), method = lm) +
  ggtitle("Right Gray Matter volume vs Age") +
  labs(y='Cohen\'s D',x='Age') +
  scale_y_continuous(limits = c(-6, 3))
dev.off()

# VOLUME -  GRAY MATTER LEFT
svg(filename="fig_tmp/lm_GMvol-age_Left.svg", width=4,height=3,pointsize=14,family = "Arial")
ggplot(data = GM.vol.L) + 
  geom_point(mapping = aes(x = HL.age, y = cohenD, size=N.total, alpha=0.4)) +
  geom_smooth(mapping = aes(x = HL.age, y = cohenD), method = lm) +
  ggtitle("Left Gray Matter volume vs Age") +
  labs(y='Cohen\'s D',x='Age') +
  scale_y_continuous(limits = c(-6, 3))
dev.off()

# VOLUME -  WHITE MATTER  RIGHT
svg(filename="fig_tmp/lm_WMvol-age_Right.svg", width=4,height=3,pointsize=14,family = "Arial")
ggplot(data = WM.vol.R) + 
  geom_point(mapping = aes(x = HL.age, y = cohenD, size=N.total, alpha=0.4)) +
  geom_smooth(mapping = aes(x = HL.age, y = cohenD), method = lm) +
  ggtitle("Right White Matter Volume vs Age") +
  labs(y='Cohen\'s D',x='Age') +
  scale_y_continuous(limits = c(-6, 3))
dev.off()

# VOLUME -  WHITE MATTER LEFT
svg(filename="fig_tmp/lm_WMvol-age_Left.svg", width=4,height=3,pointsize=14,family = "Arial")
ggplot(data = WM.vol.L) + 
  geom_point(mapping = aes(x = HL.age, y = cohenD, size=N.total, alpha=0.4)) +
  geom_smooth(mapping = aes(x = HL.age, y = cohenD), method = lm) +
  ggtitle("Left White Matter VOLUME vs Age") +
  labs(y='Cohen\'s D',x='Age') +
  scale_y_continuous(limits = c(-6, 3))
dev.off()

# FA -  WHITE MATTER  RIGHT
svg(filename="fig_tmp/lm_WMfa-age_Right.svg", width=4,height=3,pointsize=14,family = "Arial")
ggplot(data = WM.fa.R) + 
  geom_point(mapping = aes(x = HL.age, y = cohenD, size=N.total, alpha=0.4)) +
  geom_smooth(mapping = aes(x = HL.age, y = cohenD), method = lm) +
  ggtitle("Right White Matter FA vs Age") +
  labs(y='Cohen\'s D',x='Age') +
  scale_y_continuous(limits = c(-6, 3))
dev.off()

# FA -  WHITE MATTER LEFT
svg(filename="fig_tmp/lm_WMfa-age_Left.svg", width=4,height=3,pointsize=14,family = "Arial")
ggplot(data = WM.fa.L) + 
  geom_point(mapping = aes(x = HL.age, y = cohenD, size=N.total, alpha=0.4)) +
  geom_smooth(mapping = aes(x = HL.age, y = cohenD), method = lm) +
  ggtitle("Left White Matter FA vs Age") +
  labs(y='Cohen\'s D',x='Age') +
  scale_y_continuous(limits = c(-6, 3))
dev.off()


# ----------------------------------------------------------------------------------- #
####      FIGURE 2.E  -   Severity                                                 #### 
# ----------------------------------------------------------------------------------- #
studies$Etiology <- droplevels(studies$Etiology)
etiology <- data.frame(table(studies$Etiology, studies$Severeity))
colnames(etiology) <- c("Etiology", "Severity", "Number") 
# Stacked barplot with multiple groups
ggplot(data=etiology, aes(x=Severity, y=Number, fill=Etiology)) +
  geom_bar(stat="identity") + coord_flip() +
  labs(title="Figure 2.E - Severity", y ="Number of studies", x = "")

# ----------------------------------------------------------------------------------- #
####      FIGURE 2.F  -   Effect size direction                                    #### 
# ----------------------------------------------------------------------------------- #
meta$effect <- droplevels(meta$effect)
meta$Etiology <- droplevels(meta$Etiology)
effect <- data.frame(prop.table(table(meta$Etiology, meta$effect)[,-1], 1))
colnames(effect) <- c("Etiology", "effect", "Proportion") 
# Stacked barplot with multiple groups
ggplot(data=effect, aes(x=effect, y=Proportion, fill=Etiology)) +
  geom_bar(stat="identity", position=position_dodge()) + coord_flip() +
  ylim(0, 0.7) +
  labs(title="Figure 2.F - Effect size direction", y ="Relative percentage", x = "")

# ----------------------------------------------------------------------------------- #
####      FIGURE 3 -   META REGRESSION BY GM/WM SIDE                               #### 
# ----------------------------------------------------------------------------------- #
# GRAY MATTER ALL
# Insersect data by GM+WM and volume+FA
meta.GWm <- meta[
  intersect(which(!is.na(factor(meta$measure, levels=c("volume","FA")))),
            which(!is.na(factor(meta$matter, levels=c("WM","GM")))) ),]
meta.GWm$matter <- droplevels(meta.GWm$matter)
meta.GWm$measure <- droplevels(meta.GWm$measure) 
meta.GWm$class <- factor(paste0(meta.GWm$matter,"-",meta.GWm$measure), levels = c("WM-volume","WM-FA","GM-volume"))

# Funtion to slice data
meta.slice <- function(Data, Side, Matter, Measure){
  Data <- Data[Data$Side==Side & Data$matter==Matter & Data$measure==Measure,]
  return(Data)
  }

# Right-Left structures - GM volume
sub.forest(meta.slice(meta.GWm,"right","GM","volume"), "Gray Matter volume Right")
sub.forest(meta.slice(meta.GWm,"left","GM","volume"), "Gray Matter volume Left")
# Right-Left structures - WM FA
sub.forest(meta.slice(meta.GWm,"right","WM","FA"), "White Matter FA Right")
sub.forest(meta.slice(meta.GWm,"left","WM","FA"), "White Matter FA Left")
# Right-Left structures - WM volume
sub.forest(meta.slice(meta.GWm,"right","WM","volume"), "White Matter volume Right")
sub.forest(meta.slice(meta.GWm,"left","WM","volume"), "White Matter volume Left")



# ----------------------------------------------------------------------------------- #
####      FIGURE 4 -   META REGRESSION GRAY MATTER BY AREA                                          #### 
# ----------------------------------------------------------------------------------- #


# Gray matter Subareas

# ----------------------------------------------------------------------------------- #
# WHITE MATTER ALL

# White matter  RIGHT structures

# White matter Left structures

# White Matter LEFT vs  RIGHT

# White matter Subareas

# ----------------------------------------------------------------------------------- #

# ----------------------------------------------------------------------------------- #
####      SUPPLEMENTARY FIGURE -   GOSH plot                                          #### 
# ----------------------------------------------------------------------------------- #



### decrease margins so the full space is used
par(mar=c(4,4,1,2))

### Sliced the featured data
Big.area <- c("temporal lobe", "parietal", "frontal", "cerebellum", "occipital", "insular cortex")
meta.sliced <- meta[meta$measure=="volume" & meta$matter=="GM",]
meta.sliced <- meta.sliced[meta.sliced$Big.area %in% Big.area,]
meta.sliced$Big.area <- droplevels(meta.sliced$Big.area)
# Plot forest plot of each subset
for ( i in Big.area) {sub.forest(meta[meta$measure=="volume" & meta$matter=="GM" & meta$Big.area==i,], paste0("Gray matter Volume - ",i)) }


sub.forest(meta[meta$measure=="volume" & meta$matter=="GM" & meta$Big.area==i,], paste0("Gray matter Volume - ",i))

#### Variance Stimators ####
#http://www.metafor-project.org/doku.php/analyses:dersimonian2007



# Plot forest plot of each subset
for ( i in Big.area) {sub.forest(meta[meta$measure=="volume" & meta$matter=="GM" & meta$Big.area==i,], paste0("Gray matter Volume - ",i)) }




# Plot forest plot of each subset
for ( i in Big.area) {
  par(mfrow=c(1,1))
  sub.forest(meta[meta$measure=="volume" & meta$matter=="GM" & meta$Big.area==i,], paste0("Gray matter Volume - ",i)) 
  plot.meta(meta[meta$measure=="volume" & meta$matter=="GM" & meta$Big.area==i,], paste0("GM-Vol-",i))
}


# Contribution to the regression????
# http://www.metafor-project.org/doku.php/analyses:konstantopoulos2011
# http://www.metafor-project.org/doku.php/analyses:dersimonian2007
# http://www.metafor-project.org/doku.php/analyses:viechtbauer2007a
# http://www.metafor-project.org/doku.php/analyses:viechtbauer2005


#### Caterpilar Plot #### 
### create plot
yi <- meta.sliced$cohenD
vi <- meta.sliced$varDe
Col <- c(NA,"gray15","red4","royalblue",NA)[meta.sliced$Side]
Order <- order(meta.sliced$Side,yi)
forest(yi, vi,
       xlim=c(-6,4),        ### adjust horizontal plot region limits
       subset=Order,        ### order by Side and size of yi
       slab=NA, annotate=FALSE, ### remove study labels and annotations
       efac=0,                  ### remove vertical bars at end of CIs
       pch=19,                  ### changing point symbol to filled circle
       col=Col,            ### change color of points/CIs
       psize=2,                 ### increase point size
       cex.lab=1, cex.axis=1,   ### increase size of x-axis title/labels
       lty=c("solid","blank"))  ### remove horizontal line at top of plot

### draw points one more time to make them easier to see
points(yi[Order], 120:1, pch=19, cex=0.5, col=Col[Order])

### add summary polygon at bottom and text
addpoly(res, mlab="", annotate=FALSE, cex=1)
text(-2, -2, "RE Model", pos=4, offset=0, cex=1)

#### Cumulative Plot ####
# http://www.metafor-project.org/doku.php/plots:plot_of_cumulative_results
### cumulative meta-analysis (in the order of publication year)
tmp <- cumul(res, order=order(meta.sliced$year))

### plot of cumulative results
plot(tmp,  lwd=3, cex=1.3)


plot.meta(res,"Random Effects Model\n Gray Matter volume")
plot.meta(res2,"Fixed Effects Model\n Gray Matter volume")


par(mfrow=c(2,2))
funnel(res, main="Standard Error")
funnel(res1, main="Standard Error")
funnel(res2, main="Standard Error")
funnel(res3, main="Standard Error")

funnel(res, yaxis="vi", main="Sampling Variance")
funnel(res3, yaxis="vi", main="Sampling Variance")
funnel(res2, yaxis="seinv", main="Inverse Standard Error")
funnel(res2, yaxis="vinv", main="Inverse Sampling Variance")

### create contour enhanced funnel plot (with funnel centered at 0)
funnel(res1, level=c(90, 95, 99), shade=c("white", "gray", "darkgray"), refline=res$b)
funnel(res, yaxis="seinv", main="Inverse Standard Error",level=c(90, 95, 99), shade=c("white", "gray", "darkgray"), refline=res$b)

#### Radial plot Galbraith 
radial(res, main="Random Effects Model\n Gray Matter volume")
radial(res1, main="Fixed Effects Model\n Gray Matter volume")

#### Baujat Plot: Contribution of each study to the overal Q-test statistic for heterogeity
#  influence of each study (defined as the standardized squared difference between the overall estimate based on a fixed-effects model with and without the 
# ith study included in the model) on the vertical axis
baujat(res)
baujat(res1)
baujat(res2)
baujat(res3)

#### QQ-plot
qqnorm(res, main="Random-Effects Model",pch=20)
qqnorm(res1, main="Fixed-Effects Model",pch=20)
abline(h=0,v=0,lty=2,col="gray30")

#### GOSH plot: Graphical Display of study Heterogeneity
### fit FE model to all possible subsets
# results of a fixed-effects model in all possible subsets of size 1,....k
sav <- gosh(res.l)
plot(sav)

#### Influence plots
### calculate influence diagnostics
inf <- influence(res)

### plot the influence diagnostics
plot(inf, layout=c(4,1))

#### Bubble plot
Cex <- rescale(1/meta.sliced$varDe,c(0.5,3))
plot(yi)

sub.forest(meta[meta$measure=="FA" & meta$matter=="WM" & meta$Big.area=="temporal lobe",], paste0("Gray matter Volume - ",i))

# ----------------------------------------------------------------------------------------------------------- 
### GRAY MATTER
# ----------------------------------------------------------------------------------------------------------- 

# ----------------------------------------------------------------------------------------------------------- 
### WHITE MATTER
# ----------------------------------------------------------------------------------------------------------- 
Big.area <- c("temporal lobe", "thalmus", "brainstem", "corpus callosum", "frontal", "parietal")
meta.wm <- meta[meta$measure=="FA" & meta$matter=="WM",]
meta.wm.L <- meta[meta$measure=="FA" & meta$matter=="WM" & meta$Side=="left",]
meta.wm.R <- meta[meta$measure=="FA" & meta$matter=="WM" & meta$Side=="right",]

for ( i in Big.area) {
  par(mfrow=c(1,1))
  sub.forest(meta[meta$measure=="FA" & meta$matter=="WM" & meta$Big.area==i,], paste0("WM FA - ",i)) 
  plot.meta(meta[meta$measure=="FA" & meta$matter=="WM" & meta$Big.area==i,], paste0("WM-FA-",i))
}

# LEFT WHITE MATTER meta-regression
sub.forest(meta.wm.L, "White matter LEFT - FA")
rma(yi=cohenD, vi=varDe, data = meta.wm.L,measure = "MD",method="REML",
    slab=paste(year, study, sep=", "))

# RIGHT WHITE MATTER meta-regression
sub.forest(meta.wm.R, "White matter RIGHT - FA")
rma(yi=cohenD, vi=varDe, data = meta.wm.R,measure = "MD",method="REML",
    slab=paste(year, study, sep=", "))

sub.forest(meta[meta$ROI=="HG" & meta$measure=="FA",], "HG") 
sub.forest(meta[meta$ROI=="STG" & meta$measure=="FA",], "STG")



# fixed effects, SE =1 and Control mean=0
par(mfrow=c(1,1))
meta.sliced <- meta[meta$measure=="volume" & meta$Big.area=="temporal lobe" & meta$matter=="WM",]
N <- dim(meta.sliced)[1]
meta.mod <- metacont(n.e = Number.Hearing.loss, mean.e = cohenD, n.c=Number.Control, mean.c=rep(0,N), sd.e=rep(1,N), sd.c=rep(1,N), byvar = Side, print.byvar = FALSE, data=meta.sliced)

funnel(meta.mod, comb.random=FALSE, pch=16,contour=c(0.9, 0.95, 0.99),
       col.contour=c("darkgray", "gray","lightgray"))
legend(0.25, 0.1,c("0.1 > p > 0.05", "0.05 > p > 0.01", "< 0.01"), fill=c("darkgray", "gray","lightgray"), bty="n")


mod1 <- rma.uni(yi=cohenD, vi=varDe, data = meta.sliced, method = "DL")

### fit mixed-effects model with AGE as predictor
res <- rma(yi=cohenD, vi=varDe, data = meta.sliced, mods = HL.age + Con.Age ~ 1,measure = "MD",method="REML")

#### Brain parcelations ####
# https://surfer.nmr.mgh.harvard.edu/fswiki/CorticalParcellation
# https://galton.uchicago.edu/faculty/InMemoriam/worsley/research/surfstat/
