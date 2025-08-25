#!/bin/bash
#SBATCH --job-name=antsBrainExtraction
#SBATCH --time=00:30:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=6G
#SBATCH --output=logs/slurm/antsBrainExtraction-%A_%a.out
set -e
set -u

source ./code/setup.sh
module load apptainer

EXPERIMENT_NAME="antsBrainExtraction"

SUBJECT_ID=${SUBJECTS[${SLURM_ARRAY_TASK_ID}]}
echo "
SUBJECT_ID: ${SUBJECT_ID}
DATA_DIR: ${DATA_DIR}
"

LOG_DIR=logs/${EXPERIMENT_NAME}
mkdir -p $LOG_DIR  # ensure log folder exists
LOG_FILE=$LOG_DIR/${SUBJECT_ID}.log

OUTPUT_FILE=${DATA_DIR}/derivatives/${EXPERIMENT_NAME}/sub-${SUBJECT_ID}/BrainExtractionBrain.nii.gz
if [ -e ${OUTPUT_FILE} ]; then
    echo "Brain extracted image already exists. Exiting."
    exit 0
fi

APPTAINERENV_ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=${SLURM_CPUS_PER_TASK}
apptainer exec --cleanenv \
    -B ${DATA_DIR}:/data \
    --env SUBJECT_ID=${SUBJECT_ID} \
    ${SIF_IMG} \
    antsBrainExtraction.sh \
    -d 3 \
    -a /data/sub-${SUBJECT_ID}/ses-1/anat/sub-${SUBJECT_ID}_ses-1_run-1_T1w.nii.gz \
    -e "/opt/templates/OASIS"/T_template0.nii.gz \
    -m "/opt/templates/OASIS"/T_template0_BrainCerebellumProbabilityMask.nii.gz \
    -o /data/derivatives/${EXPERIMENT_NAME}/sub-${SUBJECT_ID}/ \
    > $LOG_FILE 2>&1
