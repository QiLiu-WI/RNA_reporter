#!/bin/bash

#################################################################
# This file is used to extract the RP2 that map to the BSD sequence. 
#################################################################

#Set congfig
input_bowtie_out="$1"
output_read_name="$2"
#input_bowtie_out = "${output_folder}/${SAMPLENAME}_BSD_noPolyA_R2_trimmed.bowtie.out"
#output_read_name = "${output_folder}/${SAMPLENAME}_BSD_aligned_read_name"

# extract BSD matching read name from bowtie output
awk -F '\t' '$3 == "BSD_noPolyA_trim5_18" {print $1}' "$input_bowtie_out" | cut -d ' ' -f 1 | sort | uniq > "$output_read_name"

