#!/bin/bash

#SBATCH --partition=20
#SBATCH --cpus-per-task=1

#################################################################
# This file is used to annotate the integration events represented by the RP1 that is cloest to the integration site.    
#################################################################

#Use the bedfile generated from last step. Intersct it with the human genome .gtf file. Append two column based on the original bedfile. Integretion catorgory (UTR, CDS, Intron, Intergenic_region) and integrated genes (. for Intergenic_region)
sh ./integ_site_info.sh ${SAMPLENAME}

#Generate the uniq gene list
if [ ! -d uniq_genes ]; then
  mkdir -p uniq_genes
fi

cut -f8 ${SAMPLENAME}_integ_info.csv | sed '/^\s*$/d' | sort | uniq > uniq_genes/${SAMPLENAME}_uniq_gene
