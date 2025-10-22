#!/bin/sh
#SBATCH --job-name=vprec-space_search
#SBATCH --time=08:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=750M
#SBATCH --output=logs/slurm/vprec-space_search-%A_%a.out
set -eu

source ./code/setup.sh

export EXPERIMENT_NAME="vprec-space_search"
export APPTAINERENV_ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=8

# Map task ID to configuration, subject
CONFIG="0000"
SUBJECT_ID=${SUBJECTS[${SLURM_ARRAY_TASK_ID}]}

LOG_DIR=logs/${EXPERIMENT_NAME}/$CONFIG
mkdir -p $LOG_DIR  # ensure log folder exists

OUTPUT_DIR=${DATA_DIR}/derivatives/${EXPERIMENT_NAME}/$CONFIG/binary64/sub-${SUBJECT_ID}
OUTPUT_FILE=${OUTPUT_DIR}/Warped.nii.gz
mkdir -p $OUTPUT_DIR  # ensure output folder exists

LOG_FILE=$LOG_DIR/${SUBJECT_ID}-binary64.log

if [ -f "${OUTPUT_FILE}" ]; then
    echo "Output exists at ${OUTPUT_FILE}. Skipping." >&2
    exit 0
fi

# Launch in foreground
VFC_BACKENDS="libinterflop_ieee.so"
sh ./code/${EXPERIMENT_NAME}/antsRegistration.sh \
    "$VFC_BACKENDS" "$CONFIG" "$SUBJECT_ID" "$OUTPUT_DIR" \
    > $LOG_FILE 2>&1
