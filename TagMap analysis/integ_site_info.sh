#!/bin/bash

#echo "Enter the path of the bed file of integration site:"
#read -r integ_bed
sample_name=$1
integ_bed="${output_folder}/${sample_name}_clustering.bed"
final_file="${output_folder}/${sample_name}_integ_info.csv"
keep_files="yes"

if [ ! -d clustering ];then
    mkdir -p clustering
fi

if [ ! -d clustering/${sample_name} ]; then
    mkdir -p clustering/${sample_name}
fi

bedtools intersect -a $integ_bed -b "${hg38_gtf_folder}/gencode.v24.annotation.gtf" -wo > clustering/${sample_name}/annotation_file.csv

awk '{
# Initialize an associative array 'group' to store information for each key (unique identifier from column 4).
    key = $4;
    type = $9;
	
    # If the key is not in the 'group' array, initialize its attributes.
    if (!(key in group)) {
        group[key]["has_utr"] = 0;
        group[key]["has_CDS"] = 0;
        group[key]["has_exon"] = 0;
        group[key]["has_transcript"] = 0;
        group[key]["info"] = $1 "\t" $2 "\t" $3 "\t" $4" \t" $5 "\t" $6;
        group[key]["gene_name_CDS"] = "";
        group[key]["gene_name_UTR"] = "";
        group[key]["gene_name_intron"] = "";
    }
	
	# Check the type and update attributes accordingly. The priority: CDS > UTR > ncRNA_exon > Intron.
    if (type == "CDS") {
        group[key]["has_CDS"] = 1;
        match($0, /gene_name "([^"]+)"/, arr);
        group[key]["gene_name_CDS"] = arr[1];
    } else if (type == "UTR") {
        group[key]["has_utr"] = 1;
        match($0, /gene_name "([^"]+)"/, arr);
        group[key]["gene_name_UTR"] = arr[1];
    } else if (type == "exon") {
        group[key]["has_exon"] = 1;
		group[key]["gene_name_exon"] = arr[1];
    } else if (type == "transcript") {
        group[key]["has_transcript"] = 1;
        match($0, /gene_name "([^"]+)"/, arr);
        group[key]["gene_name_intron"] = arr[1];
    }
}
# Print the final results for each key. If there are two same annotation (e.g. two intron) for a single integration site, the represented gene_name is the last one during iteration.  
END {
    for (key in group) {
        if (group[key]["has_CDS"]) {
            print group[key]["info"], "\tCDS\t" group[key]["gene_name_CDS"];
        } else if (group[key]["has_utr"]) {
            print group[key]["info"], "\tUTR\t" group[key]["gene_name_UTR"];
		} else if  (!group[key]["has_CDS"] && !group[key]["has_utr"] && group[key]["has_exon"]) {
			print group[key]["info"], "\tncRNA_exon\t" group[key]["gene_name_exon"];
        } else if (!group[key]["has_exon"] && group[key]["has_transcript"]) {
            print group[key]["info"], "\tintron\t" group[key]["gene_name_intron"];
        } else {
            print group[key]["info"], "\tother\t";
        }   
    }
}' clustering/${sample_name}/annotation_file.csv | sort -k1,1V -k2,2n > clustering/${sample_name}/intg_intogene_position_info.csv

#echo "Enter the path and file name of the final file that contains integration site information:"
#read -r final_file

awk '{print $4}' clustering/${sample_name}/intg_intogene_position_info.csv | grep -v -w -F -f /dev/stdin $integ_bed | awk '{ print $0, "\tintergenic_region\t", "." }' > clustering/${sample_name}/intg_intergene_position_info.csv

cat clustering/${sample_name}/intg_intogene_position_info.csv clustering/${sample_name}/intg_intergene_position_info.csv | sort -k1,1V -k2,2n > $final_file


#echo "Do you want to keep the intermediate files? (yes/no):"
#read keep_files

if [ "$keep_files" != "yes" ]; then
    rm clustering/${sample_name}/intg_intogene_position_info.csv clustering/${sample_name}/intg_intergene_position_info.csv clustering/${sample_name}/annotation_file.csv
fi
