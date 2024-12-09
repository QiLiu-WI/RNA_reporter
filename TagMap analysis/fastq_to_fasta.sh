#!/bin/bash

#SBATCH --partition=20
#SBATCH --cpus-per-task=1

#################################################################
# This file converts the Read pair 2 (RP2) FASTQ file into FASTA.
#################################################################

# convert RP2 FASTQ to FASTA
fastqToFa "${TagMap_FASTQ_folder}/${FILENAME}_L001_R2_001.fastq.gz" "${output_folder}/${SAMPLENAME}_R2.fa" 
# convert trimmed FASTQ to FASTA
#fastqToFa "${SAMPLENAME}_R2_trimmed.fq.gz" "${SAMPLENAME}_R2_trimmed.fa"
