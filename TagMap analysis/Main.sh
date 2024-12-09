#!/bin/bash

# folder configuration
# TagMap_FASTQ_folder="/lab/solexa_jaenisch/Qi_Xinlei/TagMap_data_02272024/240223_WIGTC-NOVASEQ1A_AHWJMYDRX3/FASTQ"
# output_folder="/lab/solexa_jaenisch/Qi_Xinlei/TagMap_data_02272024/exp2_and_exp3"
# template_folder="/lab/solexa_jaenisch/Qi_Xinlei/TagMap_data_02272024/exp1_mapping_vector"
# hg38_bwa_folder="/nfs/genomes/human_hg38_dec13/bwa"
# hg38_gtf_folder="/nfs/genomes/human_hg38_dec13/gtf"

while IFS=$'\t' read -r sample_name file_name
do
echo "convert fastq to fasta for ${sample_name}"
    JID_JOB1=`sbatch --export=ALL,FILENAME="$file_name",SAMPLENAME="$sample_name" \
           --job-name="$sample_name"_fastqToFa \
           --output="${sample_name}_fastqToFa_%j.out" \
           --error="${sample_name}_fastqToFa_%j.err" \
           fastq_to_fasta.sh`
JID_JOB1_NO=`echo $JID_JOB1 | cut -f 4 -d ' '`
#echo $JID_JOB1_NO
echo "trim the first 18 bp of read pair 2 from ${sample_name}_R2.fa"
    JID_JOB2=`sbatch -p 20 --dependency=afterok:$JID_JOB1_NO --kill-on-invalid-dep=yes --export=ALL,FILENAME="$file_name",SAMPLENAME="$sample_name" \
           --job-name="$sample_name"_trim \
           --output="${sample_name}_trim_%j.out" \
           --error="${sample_name}_trim_%j.err" \
           trim_low_quality_bases.sh`
JID_JOB2_NO=`echo $JID_JOB2 | cut -f 4 -d ' '`
echo "build bowtie index using fasta of ${sample_name}"
    JID_JOB3=`sbatch --dependency=afterok:$JID_JOB2_NO --kill-on-invalid-dep=yes --export=ALL,FILENAME="$file_name",SAMPLENAME="$sample_name" \
           --job-name="$sample_name"_bowtieIndex \
           --output="${sample_name}_bowtieIndex_%j.out" \
           --error="${sample_name}_bowtieIndex_%j.err" \
           bowtie_index.sh`
JID_JOB3_NO=`echo $JID_JOB3 | cut -f 4 -d ' '`
echo "map BSD sequence to read pair 2"
    JID_JOB4=`sbatch --dependency=afterok:$JID_JOB3_NO --kill-on-invalid-dep=yes --export=ALL,FILENAME="$file_name",SAMPLENAME="$sample_name" \
           --job-name="$sample_name"_mapBSD \
           --output="${sample_name}_mapBSD_%j.out" \
           --error="${sample_name}_mapBSD_%j.err" \
           map_BSD_to_R2.sh`
JID_JOB4_NO=`echo $JID_JOB4 | cut -f 4 -d ' '`
echo "extract BSD aligned read pair 2 for ${sample_name} and write into fasta file"
    JID_JOB5=`sbatch --dependency=afterok:$JID_JOB4_NO --kill-on-invalid-dep=yes --export=ALL,FILENAME="$file_name",SAMPLENAME="$sample_name" \
           --job-name="$sample_name"_extract \
           --output="${sample_name}_extract_%j.out" \
           --error="${sample_name}_extract_%j.err" \
           extract_BSD_aligned_reads.sh`
JID_JOB5_NO=`echo $JID_JOB5 | cut -f 4 -d ' '`
echo "extract BSD aligned read pair 1 for ${sample_name} and align to human"
    JID_JOB6=`sbatch --dependency=afterok:$JID_JOB5_NO --kill-on-invalid-dep=yes --export=ALL,FILENAME="$file_name",SAMPLENAME="$sample_name" \
           --job-name="$sample_name"_RP1align \
           --output="${sample_name}_RP1_align_%j.out" \
           --error="${sample_name}_RP1_align_%j.err" \
           map_BSD_aligned_RP1_to_human.sh`
JID_JOB6_NO=`echo $JID_JOB6 | cut -f 4 -d ' '`
echo "run Qi's script to find potential integration clusters based on fragment size"
    JID_JOB7=`sbatch --dependency=afterok:$JID_JOB6_NO --kill-on-invalid-dep=yes --export=ALL,FILENAME="$file_name",SAMPLENAME="$sample_name" \
           --job-name="$sample_name"_cluster \
           --output="${sample_name}_cluster_%j.out" \
           --error="${sample_name}_cluster_%j.err" \
           find_integ_cluster.sh`
JID_JOB7_NO=`echo $JID_JOB7 | cut -f 4 -d ' '`
echo "run Qi's script to annotate genomic regions and genes for each integration site"
    JID_JOB8=`sbatch --dependency=afterok:$JID_JOB7_NO --kill-on-invalid-dep=yes --export=ALL,FILENAME="$file_name",SAMPLENAME="$sample_name" \
           --job-name="$sample_name"_annotate \
           --output="${sample_name}_annotate_%j.out" \
           --error="${sample_name}_annotate_%j.err" \
           annotate_integration.sh`
done < ./Sample_info.txt

