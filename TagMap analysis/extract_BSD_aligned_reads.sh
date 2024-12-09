#!/bin/bash

#SBATCH --partition=20
#SBATCH --cpus-per-task=1

#################################################################
# This file is used to extract the RP2 that map to the BSD sequence. 
#################################################################

# extract BSD matching read name from bowtie output
cut -f 3 "${output_folder}/${SAMPLENAME}_BSD_noPolyA_R2_trimmed.bowtie.out" > "${output_folder}/${SAMPLENAME}_BSD_aligned_read_name"
# extract BSD aligned reads from fasta
seqtk subseq "${output_folder}/${SAMPLENAME}_R2_trimmed.fa" "${output_folder}/${SAMPLENAME}_BSD_aligned_read_name" > "${output_folder}/${SAMPLENAME}_BSD_aligned_reads.fa"
