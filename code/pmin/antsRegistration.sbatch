#!/bin/sh
#SBATCH --job-name=pmin
#SBATCH --time=02:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=750M
#SBATCH --output=logs/slurm/pmin-%A_%a.out
set -eu

echo start
source ./code/setup.sh
echo done with setup

export EXPERIMENT_NAME="pmin"
export APPTAINERENV_ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=8

SUBJECT_ID=${SUBJECTS[${SLURM_ARRAY_TASK_ID}]}
FIXED_IMG=/templateflow/tpl-MNI152NLin2009cAsym/tpl-MNI152NLin2009cAsym_res-01_desc-brain_T1w.nii.gz
INPUT_IMG=${DATA_DIR}/derivatives/antsBrainExtraction/sub-${SUBJECT_ID}/BrainExtractionBrain.nii.gz

OUTPUT_DIR=${DATA_DIR}/derivatives/${EXPERIMENT_NAME}/sub-${SUBJECT_ID}
mkdir -p $OUTPUT_DIR  # ensure output folder exists
OUTPUT_FILE=${OUTPUT_DIR}/Warped.nii.gz

if [ -f "${OUTPUT_FILE}" ]; then
    echo "Output exists at ${OUTPUT_FILE}. Skipping." >&2
    continue
fi

LOG_DIR=logs/${EXPERIMENT_NAME}
mkdir -p $LOG_DIR  # ensure log folder exists
LOG_FILE=$LOG_DIR/${SUBJECT_ID}.log

echo "
##########################
# Experiment information #
##########################
SIF_IMG: $SIF_IMG
EXPERIMENT_NAME: $EXPERIMENT_NAME

FIXED_IMG: $FIXED_IMG
SUBJECT_ID: $SUBJECT_ID
INPUT_IMG: $INPUT_IMG
OUTPUT_DIR: $OUTPUT_DIR

ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS: $APPTAINERENV_ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
##########################
" > $LOG_FILE 2>&1

# Registration
apptainer exec --cleanenv \
    -B ${DATA_DIR}:${DATA_DIR} \
    -B ${OUTPUT_DIR}:${OUTPUT_DIR} \
    -B ${TEMPLATEFLOW_DIR}:/templateflow \
    ${SIF_IMG} antsRegistration \ \
    --verbose 1 \
    --dimensionality 3 \
    --collapse-output-transforms 1 \
    --use-histogram-matching 0 \
    --winsorize-image-intensities [0.005,0.995] \
    --interpolation Linear \
    --random-seed 1 \
    --output [${OUTPUT_DIR}/,${OUTPUT_DIR}/Warped.nii.gz] \
    --initial-moving-transform [${FIXED_IMG},${INPUT_IMG},1] \
    --transform Rigid[0.1] \
    --metric MI[${FIXED_IMG},${INPUT_IMG},1,32,Regular,0.25] \
    --convergence [1000x500x250x100,1e-6,10] \
    --shrink-factors 8x4x2x1 \
    --smoothing-sigmas 3x2x1x0vox \
    --transform Affine[0.1] \
    --metric MI[${FIXED_IMG},${INPUT_IMG},1,32,Regular,0.25] \
    --convergence [1000x500x250x100,1e-6,10] \
    --shrink-factors 8x4x2x1 \
    --smoothing-sigmas 3x2x1x0vox \
    --transform SyN[ 0.1,3,0 ] \
    --metric CC[${FIXED_IMG},${INPUT_IMG},1,4] \
    --convergence [100x70x50x20,1e-6,10] \
    --shrink-factors 8x4x2x1 \
    --smoothing-sigmas 3x2x1x0vox \
    > $LOG_FILE 2>&1
