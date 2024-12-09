#!/bin/bash

#SBATCH --partition=20
#SBATCH --mem=42G
#SBATCH --cpus-per-task=8

#################################################################
# This file trims the first 18bp of RP2 from fasta file.
#################################################################

# trim first 18bp of R2 from fasta file
cutadapt -j 8 -u 18 -m 20 -o "${output_folder}/${SAMPLENAME}_R2_trimmed.fa" "${output_folder}/${SAMPLENAME}_R2.fa"
