#!/bin/bash

## --------------------------------------------------------------------
## A | sort data by taxa
## --------------------------------------------------------------------

#convert xlsx to tab
ssconvert design.xlsx design.txt
cat design.txt | tr ',' '\t' | tail -n +2 > design.tab
rm design.txt

#bacteria

#get labels
bac_labels=$(cat ../1_design/design.tab | awk '{if ($7 == "b") print $0;}' | awk '{print $8}' | sort | uniq)
#mv them to new folder
mkdir ../2_data/bacteria 2> /dev/null
for b in ${bac_labels}; do
	mv ../2_data/*${b}*.fastq.gz ../2_data/bacteria
done

#fungi

#get labels
fun_labels=$(cat ../1_design/design.tab | awk '{if ($7 == "f") print $0;}' | awk '{print $8}' | sort | uniq)
#mv them to new folder
mkdir ../2_data/fungi 2> /dev/null
for f in ${fun_labels}; do
	mv ../2_data/*${f}*.fastq.gz ../2_data/fungi
done

#move all files not in design to unused_samples folder
mkdir ../2_data/unused_samples 2> /dev/null #may already exist
mv ../2_data/*.fastq.gz ../2_data/unused_samples

#rm no longer need design.tab
rm design.tab
