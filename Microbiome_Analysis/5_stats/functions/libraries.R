libraries <- function(){
  
  #BiocManager
  if (!requireNamespace("BiocManager", quietly = TRUE)) {install.packages("BiocManager")}
  if (!require(phyloseq)){BiocManager::install("phyloseq")}; library(phyloseq)
  if (!require(edgeR)){BiocManager::install("edgeR")}; library(edgeR)
  if (!require(vegan)){BiocManager::install("vegan")}; library(vegan)
  
  #data manipulation
  if (!require(readxl)){install.packages("readxl")}; library(readxl)
  if (!require(tidyr)){install.packages("tidyr")}; library(tidyr)
  
  #figures and tables
  if (!require(ggplot2)){install.packages("ggplot2")}; library(ggplot2)
  if (!require(cowplot)){install.packages("cowplot")}; library(cowplot)
  if (!require(ggvenn)){install.packages("cowplot")}; library(ggvenn)
  if (!require(pander)){install.packages("pander")}; library(pander)
  
  #stats
  if (!require(emmeans)){install.packages("emmeans")}; library(emmeans)
  if (!require(multcomp)){install.packages("multcomp")}; library(multcomp)
  if (!require(forcats)){install.packages("forcats")}; library(forcats)
}
