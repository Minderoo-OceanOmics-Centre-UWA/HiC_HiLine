#!/bin/bash --login
#---------------
#Requested resources:
#SBATCH --account=pawsey0964
#SBATCH --job-name=HiLine
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --time=02:00:00
#SBATCH --mem=30G
#SBATCH --export=ALL
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

date=$(date +%y%m%d)

echo "========================================="
echo "SLURM_JOB_ID = $SLURM_JOB_ID"
echo "SLURM_NODELIST = $SLURM_NODELIST"
echo "DATE: $date"
echo "========================================="

set -euo pipefail

run_dir="$1"
sample_dir="$2"
echo "Run directory: $run_dir"
sample=$3

CLEAN="false"
if [[ "${4:-}" == "--clean" ]]; then
    CLEAN="true"
fi

cd "${run_dir}/${sample_dir}"
echo "Now in: $(pwd)"

cd "${run_dir}/${sample_dir}"
echo "Now in: $(pwd)"

if [[ "$CLEAN" == "true" ]]; then
    echo "Cleaning old HiLine-generated files..."

    rm -rf \
        ${sample}_top30.fai \
        ${sample}_top30.names \
        ${sample}_30_largest_contigs.fasta \
        ${sample}_30_largest_contigs.fasta.amb \
        ${sample}_30_largest_contigs.fasta.bwt \
        ${sample}_30_largest_contigs.fasta.pac \
        ${sample}_30_largest_contigs.fasta.sa \
        ${sample}_30_largest_contigs.fasta.ann \
        ${sample}_30_largest_contigs.fasta.fai \
        ${sample}_30_largest_contigs.fasta.gz \
        ${sample}_30_largest_contigs.fasta.bgz \
        ${sample}_30_largest_contigs.fasta.bgz.* \
        ${sample}.aligned.cram \
        ${sample}.aligned.cram.crai \
        ${sample}.valid_pairs.cram \
        ${sample}.valid_pairs.cram.crai \
        ${sample}.stats \
        ${sample}.stats.* \
        *reads.collate*.bam

    rm -rf \
        ${sample}_R1_1x.fastq.gz \
        ${sample}_R2_1x.fastq.gz

    echo "Cleanup complete."
fi


#Define Hi-C files
HICR1=$(echo *R1_001.fastq.gz)
HICR2=$(echo *R2_001.fastq.gz)

echo "Hi-C forward: $HICR1"
echo "Hi-C reverse: $HICR2"

hic_R1X=${sample}_R1_1x.fastq.gz
hic_R2X=${sample}_R2_1x.fastq.gz

fasta=$(echo *p_ctg.fasta)

echo assembly: $fasta


## top 30 contigs


#1 index the genome

singularity run $SING2/hiline:0.2.4.sif samtools faidx $fasta

#2 get the top 30 largest contigs
sort -k2,2nr $fasta.fai | head -30 > ${sample}_top30.fai
cut -f1 ${sample}_top30.fai > ${sample}_top30.names

#3 extract the top 30 contigs into a new fasta file

 singularity run $SING2/hiline:0.2.4.sif samtools faidx $fasta $(cat ${sample}_top30.names) > \
  ${sample}_30_largest_contigs.fasta

# check size of the new fasta
singularity run $SING2/hiline:0.2.4.sif samtools faidx ${sample}_30_largest_contigs.fasta

awk '{sum+=$2} END {print "Total bp:", sum, " (~", sum/1e6, " Mb)"}' \
  ${sample}_30_largest_contigs.fasta.fai


#skim reads to 1X 

singularity run $SING2/bbtools:39.49.sif reformat.sh \
  in1=$HICR1 \
  in2=$HICR2 \
  out1=$hic_R1X \
  out2=$hic_R2X \
  samplerate=0.1667 \
  sampleseed=42


#align contigs with HiC reads and convert to cram file 

singularity run $SING/bwa:0.7.17.sif bwa index ${sample}_30_largest_contigs.fasta

singularity run "$SING/bwa:0.7.17.sif" bwa mem -5SP -T0 -t16 \
  "${sample}_30_largest_contigs.fasta" \
  "$hic_R1X" "$hic_R2X" \
  | singularity run "$SING/samtools_1.16.1.sif" samtools view \
      -T "${sample}_30_largest_contigs.fasta" \
      -C \
      -o "${sample}.aligned.cram" \
      -

singularity run $SING/samtools_1.16.1.sif bgzip -c ${sample}_30_largest_contigs.fasta \
  > ${sample}_30_largest_contigs.fasta.bgz

singularity run $SING/samtools_1.16.1.sif samtools faidx \
  ${sample}_30_largest_contigs.fasta.bgz

singularity run $SING2/hiline:0.2.4.sif HiLine \
 params -t16 ${sample}_30_largest_contigs.fasta.bgz Omni-C \
 align-sam-reads ${sample}.aligned.cram \
     valid-pairs ${sample}.valid_pairs.cram \
     save-stats ${sample}.stats
