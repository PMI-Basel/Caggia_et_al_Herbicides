#!/bin/bash

#SBATCH --time=04:00:00
#SBATCH --mem=120g
#SBATCH --output=ASV.out
#SBATCH --error=ASV.error
#SBATCH --job-name=ASV_clustering
#SBATCH --cpus-per-task=16
#SBATCH --mail-user=YOUR_EMAIL
#SBATCH --mail-type=ALL

#load R module
module add R/3.5.1

#start scripts
./bacteria_ASV_cluster.R;
./fungi_ASV_cluster.R;
