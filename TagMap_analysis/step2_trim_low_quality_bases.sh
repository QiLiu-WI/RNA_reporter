#!/bin/bash

#################################################################
# This file trims the first 18bp of RP2 from fasta file.
#################################################################

#Set config
output_trimmed_fasta="$1"
input_fasta="$2"
#output_trimmed_fasta = "${output_folder}/${SAMPLENAME}_R2_trimmed.fa"
#input_fasta = "${output_folder}/${SAMPLENAME}_R2.fa"

echo "output_folder: ${output_folder}"
echo "SAMPLENAME: ${SAMPLENAME}"
ls -lh "${output_folder}"

# trim first 18bp of R2 from fasta file
cutadapt -j 8 -u 18 -m 20 -o "$output_trimmed_fasta" "$input_fasta"

