!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 4
#SBATCH -t 10:00:00
#SBATCH -J bwa_alignment
#SBATCH --mail-type=ALL
#SBATCH --mail-user=asdo3744@student.uu.se
#SBATCH --output=%x.%j.out

# Load modules
module load bioinfo-tools
module load bwa/0.7.18
module load samtools

# Define variables for RNA data and bin locations
RNA_DIR="/home/ashdos28/scripts/step2_trim"
BINS_DIR="/home/ashdos28/scripts/quality_bins"
ALIGNMENT_DIR="/home/ashdos28/scripts/BWA_TRYOUT"

# Create output directory if it doesn't exist
mkdir -p $ALIGNMENT_DIR

# Function to align reads for a given sample
align_reads() {
    local sample=$1
    local r1=$2
    local r2=$3

    for BIN in $BINS_DIR/*.fa; do
        BIN_NAME=$(basename $BIN .fa)

        # Index the bin
        bwa index $BIN
       # Align RNA reads to bin, sort the output, and convert to BAM
        bwa mem -t 4 $BIN $r1 $r2 | \
            samtools view -@ 4 -Sb - > $ALIGNMENT_DIR/${BIN_NAME}_${sample}_aligned.bam
        samtools sort -@ 4 $ALIGNMENT_DIR/${BIN_NAME}_${sample}_aligned.bam -o $ALIGNMENT_DIR/${BIN_NAME}_${sample}_aligned.sorted.bam

        # Index the BAM file
        samtools index $ALIGNMENT_DIR/${BIN_NAME}_${sample}_aligned.sorted.bam
    done
}

# Align reads for D1
align_reads "D1" "$RNA_DIR/D1_RNAOX_1_trimmed.fastq.gz" "$RNA_DIR/D1_RNAOX_2_trimmed.fastq.gz"

# Align reads for D3
align_reads "D3" "$RNA_DIR/D3_RNAHO_1_trimmed.fastq.gz" "$RNA_DIR/D3_RNAHO_2_trimmed.fastq.gz"
