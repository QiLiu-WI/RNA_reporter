#!/bin/bash

#SBATCH --partition=20
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8

#################################################################
# This file is used for map BSD sequence to the RP2.
#################################################################

# use bowtie to map BSD to RP2 (allow two mismatches in seed region)
bowtie -p 8 -a -n 2 -f -x "${output_folder}/${SAMPLENAME}_R2_trimmed" "${template_folder}/BSD_noPolyA.fa" "${output_folder}/${SAMPLENAME}_BSD_noPolyA_R2_trimmed.bowtie.out"
#bowtie -p 8 -a -n 2 -f -S -x "${SAMPLENAME}_R2_trimmed" BSD_noPolyA.fa "${SAMPLENAME}_BSD_noPolyA_R2_trimmed.sam"
