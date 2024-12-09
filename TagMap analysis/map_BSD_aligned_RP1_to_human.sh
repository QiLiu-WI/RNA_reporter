#!/bin/bash

#SBATCH --partition=20
#SBATCH --mem=42G
#SBATCH --cpus-per-task=8

#################################################################
# This file is used to extract the RP1 with its mate RP2 that map to BSD and the RP1 extracted are mapped to human genome and filtered for quality.  
#################################################################

#Use the read_name list from Xinlei to extract the cooresponding RP1 reads.
seqtk subseq "${TagMap_FASTQ_folder}/${FILENAME}_L001_R1_001.fastq.gz" "${output_folder}/${SAMPLENAME}_BSD_aligned_read_name" > ${output_folder}/${SAMPLENAME}_BSD_aligned_RP1.fastq
#Align these extracted RP1 reads to human genome 
bwa mem -t 8 -M -o "${output_folder}/${SAMPLENAME}_BSD_aligned_RP1_to_human.sam" "${hg38_bwa_folder}/hg38_all.fa" "${output_folder}/${SAMPLENAME}_BSD_aligned_RP1.fastq"
#Assume one read might be aligned to different positions. Select first with the MAPQ > 20 reads and then select the RP1 alignment that have the hightest MAPQ as the representative. 
samtools view -h -q 20 -F 256 "${output_folder}/${SAMPLENAME}_BSD_aligned_RP1_to_human.sam" | awk '{
    if ($1 ~ /^@/) {
        print $0;
    } else {
        read_name = $1;
        mapq = $5;

        if (read_name in max_mapq) {
            if (mapq > max_mapq[read_name]) {
                max_mapq[read_name] = mapq;
                lines[read_name] = $0;
            }
        } else {
            max_mapq[read_name] = mapq;
            lines[read_name] = $0;
        }
    }
}
END {
    for (read_name in lines) {
        print lines[read_name];
    }
}' > ${output_folder}/${SAMPLENAME}_BSD_aligned_RP1_to_human_filtered.sam
