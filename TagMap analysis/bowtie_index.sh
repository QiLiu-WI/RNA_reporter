#!/bin/bash

#SBATCH --partition=20
#SBATCH --mem=42G
#SBATCH --cpus-per-task=16

#################################################################
# This file builds bowtie index for bowtie mapping
#################################################################

# build bowtie index using converted fasta file
#bowtie-build --threads 16 "${SAMPLENAME}_R2.fa" "${SAMPLENAME}_R2" 
bowtie-build --threads 16 "${output_folder}/${SAMPLENAME}_R2_trimmed.fa" "${output_folder}/${SAMPLENAME}_R2_trimmed"
