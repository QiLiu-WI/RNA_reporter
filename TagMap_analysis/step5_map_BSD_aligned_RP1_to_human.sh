#!/bin/bash

#################################################################
# This file is used to extract the RP1 with its mate RP2 that map to BSD and the RP1 extracted are mapped to human genome and filtered for quality.  
#################################################################

#Set config
input_fastq_gz="$1"
input_read_name="$2"
BSD_aligned_RP1_fastq="$3"
human_gemone_fasta="$4"
BSD_aligned_RP1_sam="$5"
BSD_aligned_RP1_filtered_sam="$6"

#input_fastq_gz = "${TagMap_FASTQ_folder}/${FILENAME}_L001_R1_001.fastq.gz"
#input_read_name = "${output_folder}/${SAMPLENAME}_BSD_aligned_read_name"
#BSD_aligned_RP1_fastq = "${output_folder}/${SAMPLENAME}_BSD_aligned_RP1.fastq"
#human_gemone_fasta = "${hg38_bwa_folder}/hg38_all.fa"
#BSD_aligned_RP1_sam = "${output_folder}/${SAMPLENAME}_BSD_aligned_RP1_to_human.sam"
#BSD_aligned_RP1_filtered_sam = "${output_folder}/${SAMPLENAME}_BSD_aligned_RP1_to_human_filtered.sam"

#Use the read_name list from Xinlei to extract the cooresponding RP1 reads.
seqtk subseq "$input_fastq_gz" "$input_read_name" > "$BSD_aligned_RP1_fastq"
#Align these extracted RP1 reads to human genome 
bwa mem -t 8 -M -o "$BSD_aligned_RP1_sam" "$human_gemone_fasta" "$BSD_aligned_RP1_fastq"
#Assume one read might be aligned to different positions. Select first with the MAPQ > 20 reads and then select the RP1 alignment that have the hightest MAPQ as the representative. 
samtools view -h -q 20 -F 260 "$BSD_aligned_RP1_sam" > $BSD_aligned_RP1_filtered_sam
