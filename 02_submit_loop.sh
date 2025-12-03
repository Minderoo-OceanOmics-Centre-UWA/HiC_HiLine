#!/bin/bash


run_dir="/scratch/pawsey0964/lhuet/HIC/NEXT_251118_AD"
samples=(
"OG55G-2_HICL OG55"
"OG56G-1_HICL OG56"
"OG57M-4_HICL OG57"
"OG58W-3_HICL OG58"
"OG64W-1_HICL OG64"
"OG70W-3_HICL OG70"
"OG72G-2_HICL OG72"
"OG758M-3_HICL OG758"
"OG770M2-1_HICL OG770"
"OG784G-1_HICL OG784"
"OG81W-1_HICL OG81"
"OG834L-1_HICL OG834"
)


for sample in "${samples[@]}"; do
    set -- $sample
    sample_dir=$1
    OG=$2
    sbatch 03_run_hiline.sh "$run_dir" "$sample_dir" "$OG" --clean
done
