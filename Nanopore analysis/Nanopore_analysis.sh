#!/bin/bash

# Configuration
# Here, we take the analysis of a Nanopore sequencing of NC-3'UTR group as an example. It is in barcode09.  
# Nanopore_FASTQ_folder="/lab/solexa_jaenisch/Qi_Xinlei/Nanopore_data_10312023/231025Jae/PseudoID-9876/20231026_1603_2B_PAQ52690_9c0c97e5/fastq_pass/barcode09"
# Sample_name="NC-3UTR"
# merged_FASTQ_folder="/lab/solexa_jaenisch/Qi_Xinlei/Nanopore_data_10312023/merged_fastq"
# template_BSD_file="/lab/solexa_jaenisch/Qi_Xinlei/Nanopore_data_08192024/analysis/vector/BSD-mCMV_noPolyA.fa"
# output_folder="/lab/solexa_jaenisch/Qi_Xinlei/Nanopore_data_10312023/minimap2"

# The Oxford Nanopore Technologies sequencing results comes as mutiple .fastq.gz files in a folder. Therefore, we should fuse them into a single file for convenience.
cat "${Nanopore_FASTQ_folder}/*.fastq.gz" > ${merged_FASTQ_folder}/${Sample_name}_pass_merged.fq.gz

# Minimap2 are used for mapping the long reads from Nanopore sequencing. 
minimap2 -p 0.8 -ax map-ont -t 24 ${template_BSD_file} ${merged_FASTQ_folder}/${Sample_name}_pass_merged.fq.gz > ${output_folder}/${Sample_name}_pass_merged_p0.8_BSD.sam

# The reads that successfully map to the BSD template are extracted by using the template file name.
grep "BSD-mCMV" ${output_folder}/${Sample_name}_pass_merged_p0.8_BSD.sam | grep -v "@SQ"  | grep -v "@PG"  > ${output_folder}/${Sample_name}_chimeric_read.sam

#Finally, the reads in the .sam file are analyzed manually using BLAT.