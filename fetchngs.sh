#!/bin/bash
# David Shechter 2024-11-27
# Script to run nfcore/fetchngs with specified inputs and optional pipeline flag

# Load conda environment and modules
source /gs/gsfs0/hpc01/rhel8/apps/conda3/bin/activate

# Activate nfcore/nextflow/singularity environment
conda activate nfcore

# Function to display usage instructions
usage() {
    echo "Usage: $0 -i PRJNA1234567 [-p rnaseq]"
    echo "  -i: Mandatory input project code (PRJNA GEO number)"
    echo "  -p: Optional pipeline name for nf-core (e.g., rnaseq)"
    exit 1
}

# Parse input arguments
PROJECT=""
PIPELINE=""
while getopts "i:p:" opt; do
    case $opt in
        i) PROJECT=$OPTARG ;;
        p) PIPELINE=$OPTARG ;;
        *) usage ;;
    esac
done

# Check for mandatory input
if [ -z "$PROJECT" ]; then
    echo "Error: Project code (-i) is mandatory."
    usage
fi

# Set output directory to current working directory
OUTDIR=$(readlink -f .)

# Create ids.csv file with project code
echo "Project code: $PROJECT"
echo "$PROJECT" > ./ids.csv
echo "ids.csv created in $OUTDIR"

# Construct the Nextflow command
CMD="nextflow run nf-core/fetchngs -profile singularity --input ./ids.csv --outdir $OUTDIR --download_method sratools"
if [ -n "$PIPELINE" ]; then
    CMD="$CMD --nf_core_pipeline $PIPELINE"
fi

# Run the Nextflow command
echo "Running command: $CMD"
$CMD

# Check for successful completion
if grep -q "Pipeline completed successfully" .nextflow.log; then
    echo "Pipeline completed successfully."
else
    echo "Pipeline encountered an error. Check .nextflow.log for details."
    exit 1
fi

# Deactivate the conda environment
conda deactivate
