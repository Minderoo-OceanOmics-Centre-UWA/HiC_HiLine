# hic-analysis

This page explains how to run the HiLine tool to analyse the quality of the HiC data for scaffolding reference genome assemblies.

**Step 1.** Run the 01_download_hic_data.sh script, pass in the RUNID and RUNDIR as arguments. 

**example**
```
bash 01_download_hic_data.sh "NEXT_251118_AD" "/scratch/pawsey0964/lhuet/hic-analysis"
```
**Step 2.** Stage the assembly files, create a list of OG numbers you are running the complexity anlysis for and call it OG-list.txt. Then run the 02_get_primary_assemblies.sh script. Pass in the download path. 

**example**
```
bash 02_get_primary_assemblies.sh "/scratch/pawsey0964/lhuet/hic-analysis"
```
**Step 3.** Put the assemblies into the hic directories, add the 03_submit_loop.sh and 04_submit_hiline.sh into the run directory 
```
**example**

/scratch/pawsey0964/lhuet/hic-analysis/NEXT_250325_AD/OG37H-1_HICL> rclone tree .
/
├── OG37H-1_HICL_S1_L001_R1_001.fastq.gz
├── OG37H-1_HICL_S1_L001_R2_001.fastq.gz
├── OG37H-1_HICL_ds.5a7614fa2c6543b39686cf1f2131fe34.json
├── OG37_v240116.hifi1.0.hifiasm.p_ctg.fasta

# where the run directory would be
/scratch/pawsey0964/lhuet/hic-analysis/NEXT_250325_AD/
```
**Step 4.** Update the loop script for your samples and submit the script
```
bash 03_submit_loop.sh
```
**The 04_submit_hiline.sh script performs the following steps**
1. Extracts the 30 largest contigs from the hifi assembly file
2. Skims the HiC reads to 1x
3. Aligns the skimmed reads to the 30 largest contigs and converts to cram file
4. runs HiLine on cram file and 30 largest contigs, producing a stats directory with the results.

If there is an error and you need to re-run the script on one or more samples, there is a --clean flag you can include when you run the 04_loop.sh which will remove any old results from the directory. To use this open the 04_loop.sh script and add the --clean flag here: 

```
for sample in "${samples[@]}"; do
    set -- $sample
    sample_dir=$1
    OG=$2
    sbatch run_hiline.sh "$run_dir" "$sample_dir" "$OG" --clean
done

```

**Step 5.** Download the results and pass onto the lab

Download the output stats directory from the finished run directly to teams and inform the Lab results are ready to be viewed.
