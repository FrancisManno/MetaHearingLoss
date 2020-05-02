# Hearing loss impacts brain structure across the lifespan: Systematic review, meta-analysis and meta-regression of quantitative metrics of gray and white matter  
  
Francis A. M. Manno DPhil, PhD<sup>1,2</sup>†, Raul Rodríguez-Cruces MD, PhD<sup>3</sup>, Rachit Kumar BS<sup>4</sup>, Yilai Shu MD, PhD<sup>5</sup>, J. Tilak Ratnanather DPhil<sup>6</sup>, Condon Lau PhD<sup>2</sup>  
  
**1.** School of Biomedical Engineering, Faculty of Engineering, University of Sydney, Sydney, New South Wales, Australia  
**2.** Department of Physics, City University of Hong Kong, Kowloon, Hong Kong SAR, China  
**3.** Montreal Neurological Institute, McGill University, Montreal, Canada  
**4.** Wallace H. Coulter Department of Biomedical Engineering, Georgia Institute of Technology and Emory University, Atlanta, GA, USA  
**5.** ENT Institute and Otorhinolaryngology Department of the Affiliated Eye and ENT Hospital, State Key Laboratory of Medical   Neurobiology, Institutes of Biomedcial Sciences, Fudan University, Shanghai, China  
**6.** Center for Imaging Science and Institute for Computational Medicine, Department of Biomedical Engineering, Johns Hopkins University, Baltimore, MD, USA  

**Corresponding:** <francis.manno@sydney.edu.au>  

**OSF:** <https://osf.io/7y59j/>  

**Keywords:** Sensorineural hearing loss, Structural MRI, DTI, Bilateral hearing loss, Unilateral hearing loss  

Abstract
========
  
**Importance.**  Hearing loss is a heterogeneous disorder thought to affect brain reorganization across the lifespan. The exact structural endophenotype of hearing loss is not known, although it is assumed to affect the auditory regions of the temporal lobe such as Heschl's gyrus.  
**Objective.**  Here we assessed the structural alterations of hearing loss by using a meta-analysis of effect size measures based on MNI coordinate mapping of MRI studies. Unique effect size metrics based on Cohen’s d and Hedges’ g were created to map coordinates of gray matter (GM) and white matter (WM) alterations from bilateral congenital and acquired hearing loss populations. Three coordinate mapping techniques were used and compared: coordinate-based anatomic likelihood estimation (ALE), multi-level kernel density analysis (mKDA), and seed-based d Mapping (SDM). Using a meta-regression, GM and WM trajectories were mapped to visualize the progression of congenital and acquired hearing loss. Heterogeneity in effect size metrics was determined using the forest, Baujat, Funnel, Galbraith and bubble plots to discern dispersion and spread of datapoints. Lastly, we displayed an endophenotype map of hearing loss alterations in GM and WM obtained from a multivariable meta-regression of the effect size.
  
Repository contents
===================

Files
-----
| File                    | Description                                                                                          |
|-------------------------|------------------------------------------------------------------------------------------------------|
| `hearing_loss_meta.Rmd` | Markdown file with the meta-analysis report                                                          |
| `hearing_loss_meta.pdf` | Supplementary information pdf file with the meta-analysis report  (output of `hearing_loss_meta.Rmd`) |
| `meta_functions.R`      | R script file with necessary functions for the meta-analysis.                                        |
| `meta_figures.R`        | R script file with that generatea plots for the main manuscript.                                     |
| `lm_effect~age_pval.R`  | R script file with a linear model for the effect of age.                                             |
| `README.md`             | File that generates this layout.                                                                     |
  
Directories content
-------------------
| Directories            | Description                                              |
|------------------------|----------------------------------------------------------|
| `./databases`          | Contains full meta-analysis database, and SI tables.     |
| `./fsaverage5`         | Surfaces of the SDM, mKDA and ALE on fsaverage5 space.   |
| `./media`              | Image files (png) for the SI document                    |
| `./surfaceVis`         | Matlab scripts to generate the surface plots             |
  

R version and libraries
-----------------------
This analysis run on R version 3.6.3 (2020-02-29) -- "Holding the Windsock", with the following packages:
```r
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
```
