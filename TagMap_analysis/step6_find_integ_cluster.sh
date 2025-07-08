#!/bin/bash

#################################################################
# This script clusters RP1 reads that are within 500bp of each other
# to indicate one integration event.
#################################################################

# Set input/output file paths from command-line arguments
input_sam="$1"
# The samfile that do not contain alignments mapped to chrY (293t cells are derived from female) and chr_alt
sam_without_Y_alt_chr="$2"
output_bed="$3"
#clustering_based_on_distance.py
clustering_python_script="$4"

# Remove alignments to alternative chromosomes (containing '_') and chrY
awk '{
  if(/^@/) {
    print
  } else {
    if($3 !~ /_/ && $3 !~ /chrY/)
      print
  }
}' "$input_sam" > "$sam_without_Y_alt_chr"

# Run clustering script to identify integration sites based on distance
python "$clustering_python_script" "$sam_without_Y_alt_chr" "$output_bed"
