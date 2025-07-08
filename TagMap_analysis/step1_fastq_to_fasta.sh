#!/bin/bash

#################################################################
# This file converts the Read pair 2 (RP2) FASTQ file into FASTA.
#################################################################

#Set config
input_fastq="$1"
output_fasta="$2"
#input_fastq="${TagMap_FASTQ_folder}/${FILENAME}_L001_R2_001.fastq.gz"
#output_fasta="${output_folder}/${SAMPLENAME}_R2.fa"

# convert RP2 FASTQ to FASTA
seqtk seq -A "$input_fastq" > "$output_fasta" 
