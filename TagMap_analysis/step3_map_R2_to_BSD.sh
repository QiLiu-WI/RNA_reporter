#!/bin/bash

#################################################################
# This file is used for map RP2 sequence to the BSD.
#################################################################

#Set config
input_bowtie_idx="$1"
input_trimmed_fasta="$2"
output_bowtie_out="$3"

#input_bowtie_idx = "${template_folder}/BSD_noPolyA_idx"
#input_trimmed_fasta = "${output_folder}/${SAMPLENAME}_R2_trimmed.fa"
#output_bowtie_out = "${output_folder}/${SAMPLENAME}_BSD_noPolyA_R2_trimmed.bowtie.out"


# use bowtie to map RP2 to BSD (allow two mismatches in seed region)

bowtie -p 8 -a -n 2 -f -x "$input_bowtie_idx" "$input_trimmed_fasta" "$output_bowtie_out"
#bowtie -p 8 -a -n 2 -f -S -x "${SAMPLENAME}_R2_trimmed" BSD_noPolyA.fa "${SAMPLENAME}_BSD_noPolyA_R2_trimmed.sam"