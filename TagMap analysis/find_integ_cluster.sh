#!/bin/bash

#SBATCH --partition=20
#SBATCH --cpus-per-task=1

#################################################################
# This file is used to cluster the RP1 that within 500bp range to indicate one integration event.   
#################################################################

# Remove alignment to alternative assembly chr and chrY
cat "${output_folder}/${SAMPLENAME}_BSD_aligned_RP1_to_human_filtered.sam" | awk '{if(/^@/){print} else{if($3!~/_/ && $3!~/chrY/)print}}' > "${output_folder}/${SAMPLENAME}_BSD_aligned_RP1_to_human_filtered_chr.sam"
# run Qi script clustering.py to find integration site based on size selection
python ./clustering.py "${output_folder}/${SAMPLENAME}_BSD_aligned_RP1_to_human_filtered_chr.sam" "${output_folder}/${SAMPLENAME}_clustering.bed"
