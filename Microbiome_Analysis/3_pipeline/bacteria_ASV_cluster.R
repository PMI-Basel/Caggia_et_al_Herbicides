#!/usr/bin/env Rscript

#bash don't automatically select a cran mirror
chooseCRANmirror(ind=5)

#clear the object from memory
rm(list=ls())

#### CHANGE THIS PATHS ####
source <- "YOUR_PATH"
taxa_database <- "YOUR_PATH/database_file"
##########################


# install required libraries
if (!requireNamespace("BiocManager", quietly = TRUE)) {install.packages("BiocManager")}
if (!require(dada2)){BiocManager::install("dada2")}
if (!require(gtools)){install.packages("gtools")}
if (!require(grid)){install.packages("grid")}
if (!require(gridExtra)){install.packages("gridExtra")}
if (!require(xlsx)){install.packages("xlsx")}
if (!require(tidyr)){install.packages("tidyr")}

# load libraries
library(dada2)
library(gtools)
library(grid)
library(gridExtra)
library(xlsx)
library(tidyr)

#set working directory to source file location
setwd(source)

#generate output files
output <- T

#list of bacteria runs
runs <- list.files("../2_data/bacteria")

#folder to store interim results
temp <- "bacteria_interim/"
dir.create(temp)


# ------------------------------------------------------------------------
# Loop over all bacteria runs
# ------------------------------------------------------------------------
for (run in runs) {
  print(paste(run, "started"))
  
  # ------------------------------------------------------------------------
  # get the samples
  # ------------------------------------------------------------------------
  
  #Forward and reverse fastq filenames have format: SAMPLENAME_R1_001.fastq and SAMPLENAME_R2_001.fastq
  path <- paste("../2_data/bacteria/", run, sep="")
  fnFs <- sort(list.files(path, pattern="R1.fastq.gz", full.names = TRUE))
  fnRs <- sort(list.files(path, pattern="R2.fastq.gz", full.names = TRUE))
  
  #Extract sample names, assuming filenames have format: SAMPLENAME_XXX.fastq
  sample.names <- sapply(strsplit(basename(fnFs), "_"), `[`, 2)
  
  #Place filtered files in filtered/ subdirectory
  filtFs <- file.path(path, "filtered", paste0(sample.names, "_F_filt.fastq"))
  filtRs <- file.path(path, "filtered", paste0(sample.names, "_R_filt.fastq"))
  names(filtFs) <- sample.names
  names(filtRs) <- sample.names
  
  #give them a unique name
  assign(paste(run, "_fnFs", sep=""), fnFs)
  assign(paste(run, "_fnRs", sep=""), fnRs)
  assign(paste(run, "_filtFs", sep=""), filtFs)
  assign(paste(run, "_filtRs", sep=""), filtRs)
  
  # ------------------------------------------------------------------------
  #Quality filtering and trimming
  # ------------------------------------------------------------------------
  
  #filter
  out <- filterAndTrim(fnFs, filtFs, fnRs, filtRs, truncLen=c(240,160),
                       maxN=0, maxEE=c(2,2), truncQ=2, rm.phix=TRUE,
                       compress=TRUE, multithread=TRUE)
  
  #unique name and save
  assign(paste(run, "_out", sep=""), out)
  saveRDS(out, paste(temp, run, "_out.RDS", sep=""))
  
  #Avoids to raise an error message if no reads from a sample pass the filter
  missing_fltFs <- c()
  missing_fltRs <- c()
  for (file in filtFs) {if(!file.exists(file)) {missing_fltFs <- c(missing_fltFs, file)}} #collect names of the missing files
  for (file in filtRs) {if(!file.exists(file)) {missing_fltRs <- c(missing_fltRs, file)}}
  filtFs <- setdiff(filtFs, missing_fltFs)
  filtRs <- setdiff(filtRs, missing_fltRs)

  # ------------------------------------------------------------------------
  # Learn the error rate
  # ------------------------------------------------------------------------
  
  #error rate
  errF <- learnErrors(filtFs, multithread=TRUE)
  errR <- learnErrors(filtRs, multithread=TRUE)
  
  #unique name and save
  assign(paste(run, "_errF", sep=""), errF)
  assign(paste(run, "_errR", sep=""), errR)
  saveRDS(errF, paste(temp, run, "_errF.RDS", sep=""))
  saveRDS(errR, paste(temp, run, "_errR.RDS", sep=""))
  
  # ------------------------------------------------------------------------
  # Dereplicate the files
  # ------------------------------------------------------------------------
  
  #dereplicate
  derepFs <- derepFastq(filtFs, verbose=TRUE)
  derepRs <- derepFastq(filtRs, verbose=TRUE)
  
  #unique name and save
  assign(paste(run, "_derepFs", sep=""), derepFs)
  assign(paste(run, "_derepRs", sep=""), derepRs)
  saveRDS(derepFs, paste(temp, run, "_derepFs.RDS", sep=""))
  saveRDS(derepRs, paste(temp, run, "_derepRs.RDS", sep=""))
  
  # ------------------------------------------------------------------------
  #Sample inference algorithm
  # ------------------------------------------------------------------------
  
  # inference algortihm
  dadaFs <- dada(derepFs, err=errF, multithread=TRUE)
  dadaRs <- dada(derepRs, err=errR, multithread=TRUE)
  
  #unique name and save
  assign(paste(run, "_dadaFs", sep=""), dadaFs)
  assign(paste(run, "_dadaRs", sep=""), dadaRs)
  saveRDS(dadaFs, paste(temp, run, "_dadaFs.RDS", sep=""))
  saveRDS(dadaRs, paste(temp, run, "_dadaRs.RDS", sep=""))
  
}

# ------------------------------------------------------------------------
#combine all bacteria runs
# ------------------------------------------------------------------------

#combine and save
fnFs <- vector()
for(i in runs){fnFs <- c(fnFs, get(paste(i, "_fnFs", sep="")))}
fnRs <- vector()
for(i in runs){fnRs <- c(fnRs, get(paste(i, "_fnRs", sep="")))}
saveRDS(fnFs, paste(temp, "fnFs.RDS", sep=""))
saveRDS(fnRs, paste(temp, "fnRs.RDS", sep=""))

filtFs <- vector()
for(i in runs){filtFs <- c(filtFs, get(paste(i, "_filtFs", sep="")))}
filtRs <- vector()
for(i in runs){filtRs <- c(filtRs, get(paste(i, "_filtRs", sep="")))}
saveRDS(filtFs, paste(temp, "filtFs.RDS", sep=""))
saveRDS(filtRs, paste(temp, "filtRs.RDS", sep=""))

out <- get(paste(runs[1], "_out", sep=""))
if(length(runs)>1){for(i in runs[2:length(runs)]){out <- rbind(out, get(paste(i, "_out", sep="")))}}
saveRDS(out, paste(temp, "out.RDS", sep=""))

derepFs <- vector()
for(i in runs){derepFs <- c(derepFs, get(paste(i, "_derepFs", sep="")))}
derepRs <- vector()
for(i in runs){derepRs <- c(derepRs, get(paste(i, "_derepRs", sep="")))}
saveRDS(derepFs, paste(temp, "derepFs.RDS", sep=""))
saveRDS(derepRs, paste(temp, "derepRs.RDS", sep=""))

dadaFs <- vector()
for(i in runs){dadaFs <- c(dadaFs, get(paste(i, "_dadaFs", sep="")))}
dadaRs <- vector()
for(i in runs){dadaRs <- c(dadaRs, get(paste(i, "_dadaRs", sep="")))}
saveRDS(dadaFs, paste(temp, "dadaFs.RDS", sep=""))
saveRDS(dadaRs, paste(temp, "dadaRs.RDS", sep=""))

#names from all bacterial runs
sample.names <- sapply(strsplit(basename(fnFs), "_"), `[`, 2)

# ------------------------------------------------------------------------
# Merge the forward and reverse reads
# ------------------------------------------------------------------------

#merge
mergers <- mergePairs(dadaFs, derepFs, dadaRs, derepRs, verbose=TRUE)
saveRDS(mergers, paste(temp, "mergers.RDS", sep=""))

# ------------------------------------------------------------------------
# ASV table
# ------------------------------------------------------------------------

#create table and remove bimera
seqtab <- makeSequenceTable(mergers)
seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE, verbose=TRUE)
saveRDS(seqtab, paste(temp, "seqtab.RDS"))
saveRDS(seqtab.nochim, paste(temp, "seqtab_nochim.RDS", sep=""))

# ------------------------------------------------------------------------
# track table
# ------------------------------------------------------------------------

getN <- function(x) sum(getUniques(x))
track <- cbind(out, sapply(dadaFs, getN), sapply(dadaRs, getN), sapply(mergers, getN), rowSums(seqtab.nochim))
colnames(track) <- c("input", "filtered", "denoisedF", "denoisedR", "merged", "nonchim")
rownames(track) <- sample.names
saveRDS(track, paste(temp, "track.RDS", sep=""))

# ------------------------------------------------------------------------
# Assign taxanomy
# ------------------------------------------------------------------------
taxa <- assignTaxonomy(seqtab.nochim, taxa_database, multithread=TRUE)
saveRDS(taxa, paste(temp, "taxa.RDS", sep=""))

# ------------------------------------------------------------------------
# Header names
# ------------------------------------------------------------------------

#change headers from the long sequence to simple ASV numbers
seq <- colnames(seqtab.nochim)
ASV <- c()
for (i in 1:length(seq)) {ASV[i] <- paste("ASV",i , sep="") }
ASV_seq <- cbind(ASV, seq)
ASV_seq[,1] <- paste(">", ASV_seq[,1], sep="")

#replace sequence headers by ASV numbers in seqtab.nochim
colnames(seqtab.nochim) <- ASV

#replace the sequence headers by the correct ASV number in taxa
for (i in 1:nrow(taxa)){
  for (j in 1:nrow(ASV_seq)){
    if(rownames(taxa)[i] == ASV_seq[j,2]){
      rownames(taxa)[i] <- ASV_seq[j,1]
    }
  }
}

# ------------------------------------------------------------------------
# Generate output files
# ------------------------------------------------------------------------
if(output){
  
  setwd(source)
  dir.create("../../4_output/bacteria_ASV")
  out <- c("../../4_output/bacteria_ASV/")
  
  #quality profiles unfiltered and untrimmed
  pdf(paste(out,"bacteria_reads_quality_unfilt_untrim.pdf",sep=""))
    for (i in 1:length(sample.names)) {
      try(figure <- plotQualityProfile(c(fnFs[i],fnRs[i])))
      try(print(figure))
      try(rm(figure))
    }
  dev.off()
  
  #quality profiles filtered and trimmed
  pdf(paste(out,"bacteria_reads_quality_filt_trim.pdf",sep=""))
  for (i in 1:length(sample.names)) {
    try(figure <- plotQualityProfile(c(filtFs[i],filtRs[i])))
    try(print(figure))
    try(rm(figure))
  }
  dev.off()
  
  #error rate learning
  runs_errF <- c (paste(runs, "_errF", sep=""))
  runs_errR <- c (paste(runs, "_errR", sep=""))
  
  pdf(paste(out,"bacteria_error_rate.pdf",sep=""))
    for (i in 1:length(runs)) {
      plot(plotErrors(get(runs_errF[i]), nominalQ=TRUE))
      grid.text(paste(runs[i], "forward"),hjust=-2, vjust = -27.5, rot = 90)
      plot(plotErrors(get(runs_errR[i]), nominalQ=TRUE))
      grid.text(paste(runs[i], "reverse"),hjust=-2, vjust = -27.5, rot = 90)
      }
  dev.off() 
  
  write.table(seqtab.nochim, paste(out, "bacteria_ASV.tab", sep=""), sep="\t")
  write.table(taxa, paste(out, "bacteria_taxa.tab", sep=""), sep="\t")
  write.table(ASV_seq, paste(out, "bacteria_sequences.fasta", sep=""), quote=F, row.names = FALSE, col.names = FALSE)

  #number of reads
  write.xlsx(track, paste(out, "bacteria_track.xlsx", sep=""))
}


