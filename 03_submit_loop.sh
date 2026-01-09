#!/bin/bash


run_dir="/scratch/pawsey0964/olivianguyen/hic-analysis/NOVA_251204_AD2"
samples=(
"OG70W-3_HICL_L1 OG70"
"OG58W-3_HICL_L1 OG58"
"OG758M-3_HICL_L1 OG758"
"OG57M-4_HICL_L1 OG57"
"OG784G-1_HICL_L1 OG784" 
)


for sample in "${samples[@]}"; do
    set -- $sample
    sample_dir=$1
    OG=$2
    sbatch 04_submit_hiline.sh "$run_dir" "$sample_dir" "$OG" --clean 
done
