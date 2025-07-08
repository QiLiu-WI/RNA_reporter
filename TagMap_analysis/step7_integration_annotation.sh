#!/bin/bash

#echo "Enter the path of the bed file of integration site:"
#read -r integ_bed
bed_file="$1"          # Input BED file (from clustering)
gtf_file="$2"          # GTF annotation file (e.g., GENCODE)
output_csv="$3"        # Final annotated CSV output
keep_files="$4"        # "yes" to keep intermediate files, "no" to delete

# === Input validation ===
if [[ $# -ne 4 ]]; then
  echo "[ERROR] Usage: $0 <integration.bed> <annotation.gtf> <output.csv> <keep_files (yes/no)>"
  exit 1
fi

if [[ ! -f "$bed_file" ]]; then
  echo "[ERROR] BED file not found: $bed_file"
  exit 1
fi

if [[ ! -f "$gtf_file" ]]; then
  echo "[ERROR] GTF file not found: $gtf_file"
  exit 1
fi

# === Set up temporary paths ===
tmp_prefix=$(basename "$output_csv" .csv)
tmp_dir=$(mktemp -d)
annotation_file="$tmp_dir/annotation.csv"
intogene_file="$tmp_dir/intogene.csv"
intergene_file="$tmp_dir/intergene.csv"

# === Step 1: Intersect BED with GTF ===
bedtools intersect -a "$bed_file" -b "$gtf_file" -wo > "$annotation_file"

awk '{
  key = $4;
  type = $10;

  # concatenate all fields from $16 to $NF into attr string
  attr = "";
  for (i = 16; i <= NF; i++) {
    attr = attr $i " ";
  }

  # initialize group for this key
  if (!(key in group)) {
    group[key]["info"] = $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7;
    group[key]["has_CDS"] = 0;
    group[key]["has_UTR"] = 0;
    group[key]["has_exon"] = 0;
    group[key]["has_transcript"] = 0;
    group[key]["gene_name_CDS"] = ".";
    group[key]["gene_name_UTR"] = ".";
    group[key]["gene_name_exon"] = ".";
    group[key]["gene_name_transcript"] = ".";
  }

  if (type == "CDS") {
    group[key]["has_CDS"] = 1;
    if (match(attr, /gene_name "([^"]+)"/, arr)) {
      group[key]["gene_name_CDS"] = arr[1];
    }
  } else if (type == "UTR") {
    group[key]["has_UTR"] = 1;
    if (match(attr, /gene_name "([^"]+)"/, arr)) {
      group[key]["gene_name_UTR"] = arr[1];
    }
  } else if (type == "exon") {
    group[key]["has_exon"] = 1;
    if (match(attr, /gene_name "([^"]+)"/, arr)) {
      group[key]["gene_name_exon"] = arr[1];
    }
  } else if (type == "transcript") {
    group[key]["has_transcript"] = 1;
    if (match(attr, /gene_name "([^"]+)"/, arr)) {
      group[key]["gene_name_transcript"] = arr[1];
    }
  }
}
END {
  for (key in group) {
    if (group[key]["has_CDS"]) {
      print group[key]["info"] "\tCDS\t" group[key]["gene_name_CDS"];
    } else if (group[key]["has_UTR"]) {
      print group[key]["info"] "\tUTR\t" group[key]["gene_name_UTR"];
    } else if (group[key]["has_exon"]) {
      print group[key]["info"] "\tncRNA_exon\t" group[key]["gene_name_exon"];
    } else if (group[key]["has_transcript"]) {
      print group[key]["info"] "\tintron\t" group[key]["gene_name_transcript"];
    } else {
      print group[key]["info"] "\tother\t.";
    }
  }
}' "$annotation_file" | sort -k1,1V -k2,2n > "$intogene_file"

#echo "Enter the path and file name of the final file that contains integration site information:"
#read -r final_file

# === Step 3: Identify intergenic regions ===
awk '{print $4}' "$intogene_file" \
| grep -v -w -F -f /dev/stdin "$bed_file" \
| awk '{ print $0 }' \
| grep -Ff - "$bed_file" \
| awk '{ print $0, "\tintergenic_region\t", "." }' > "$intergene_file"

# === Step 4: Merge into final output ===
cat "$intogene_file" "$intergene_file" | sort -k1,1V -k2,2n > "$output_csv"

# === Step 5: Cleanup ===
if [[ "$keep_files" != "yes" ]]; then
  rm -rf "$tmp_dir"
else
  echo "[INFO] Intermediate files kept in: $tmp_dir"
fi

echo "[INFO] Annotation complete: $output_csv"
