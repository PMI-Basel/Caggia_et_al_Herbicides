###############################################
## function loading wrapper ##
###############################################
## NOTE: 
## Loads all functions required for the analysis 

functions <- function(path="functions/") {
  
  #add "/" at the end if not there
  if (substring(path, nchar(path), nchar(path)) != "/") {path <- paste0(path, "/")}
  
  #load
  source(paste0(path,"libraries.R"))
  source(paste0(path,"fun_norm_edgeR_obj.R"))
  source(paste0(path,"variability_table.R"))
}
  
