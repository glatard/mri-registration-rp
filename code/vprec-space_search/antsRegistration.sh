#!/bin/sh
set -eu

# source ./code/env.sh

VFC_BACKENDS=$1
CONFIG=$2
SUBJECT_ID=$3
OUTPUT_DIR=$4

FIXED_IMG=/templateflow/tpl-MNI152NLin2009cAsym/tpl-MNI152NLin2009cAsym_res-01_desc-brain_T1w.nii.gz
INPUT_IMG=${DATA_DIR}/derivatives/antsBrainExtraction/sub-${SUBJECT_ID}/BrainExtractionBrain.nii.gz

echo "
##########################
# Experiment information #
##########################
SIF_IMG: $SIF_IMG
EXPERIMENT_NAME: $EXPERIMENT_NAME
CONFIG: $CONFIG
VFC_BACKENDS: $VFC_BACKENDS

FIXED_IMG: $FIXED_IMG
SUBJECT_ID: $SUBJECT_ID
INPUT_IMG: $INPUT_IMG
OUTPUT_DIR: $OUTPUT_DIR

ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS: $APPTAINERENV_ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
##########################
"

ants_align () {
    echo "VFC_BACKENDS=$1"
    apptainer exec --cleanenv \
        -B ${DATA_DIR}:${DATA_DIR} \
        -B ${OUTPUT_DIR}:${OUTPUT_DIR} \
        -B ${TEMPLATEFLOW_DIR}:/templateflow \
        --env VFC_BACKENDS="$1" \
        ${SIF_IMG} antsRegistration \
        --verbose 1 \
        --dimensionality 3 \
        --collapse-output-transforms 0 \
        --use-histogram-matching 0 \
        --winsorize-image-intensities [0.005,0.995] \
        --interpolation Linear \
        --random-seed 1 \
        --write-composite-transform 1 \
        --output [${OUTPUT_DIR}/align_,${OUTPUT_DIR}/Aligned.nii.gz] \
        --initial-moving-transform [${FIXED_IMG},${INPUT_IMG},1] \
        --transform Rigid[0.1] \
        --metric MI[${FIXED_IMG},${INPUT_IMG},1,32,Regular,0.25] \
        --convergence [0,1e-6,10] \
        --shrink-factors 1 \
        --smoothing-sigmas 0vox
}

ants_rigid () {
    echo "VFC_BACKENDS=$1"
    apptainer exec --cleanenv \
        -B ${DATA_DIR}:${DATA_DIR} \
        -B ${OUTPUT_DIR}:${OUTPUT_DIR} \
        -B ${TEMPLATEFLOW_DIR}:/templateflow \
        --env VFC_BACKENDS="$1" \
        ${SIF_IMG} antsRegistration \
        --verbose 1 \
        --dimensionality 3 \
        --collapse-output-transforms 0 \
        --use-histogram-matching 0 \
        --winsorize-image-intensities [0.005,0.995] \
        --interpolation Linear \
        --random-seed 1 \
        --write-composite-transform 1 \
        --output [${OUTPUT_DIR}/rigid_,${OUTPUT_DIR}/Rigid.nii.gz] \
        --initial-moving-transform ${OUTPUT_DIR}/align_Composite.h5 \
        --transform Rigid[0.1] \
        --metric MI[${FIXED_IMG},${INPUT_IMG},1,32,Regular,0.25] \
        --convergence [1000x500x250x100,1e-6,10] \
        --shrink-factors 8x4x2x1 \
        --smoothing-sigmas 3x2x1x0vox
}

ants_affine () {
    echo "VFC_BACKENDS=$1"
    apptainer exec --cleanenv \
        -B ${DATA_DIR}:${DATA_DIR} \
        -B ${OUTPUT_DIR}:${OUTPUT_DIR} \
        -B ${TEMPLATEFLOW_DIR}:/templateflow \
        --env VFC_BACKENDS="$1" \
        ${SIF_IMG} antsRegistration \
        --verbose 1 \
        --dimensionality 3 \
        --collapse-output-transforms 0 \
        --use-histogram-matching 0 \
        --winsorize-image-intensities [0.005,0.995] \
        --interpolation Linear \
        --random-seed 1 \
        --write-composite-transform 1 \
        --output [${OUTPUT_DIR}/affine_,${OUTPUT_DIR}/Affine.nii.gz] \
        --initial-moving-transform ${OUTPUT_DIR}/rigid_Composite.h5 \
        --transform Affine[0.1] \
        --metric MI[${FIXED_IMG},${INPUT_IMG},1,32,Regular,0.25] \
        --convergence [1000x500x250x100,1e-6,10] \
        --shrink-factors 8x4x2x1 \
        --smoothing-sigmas 3x2x1x0vox
}

ants_syn () {
    echo "VFC_BACKENDS=$1"
    apptainer exec --cleanenv \
        -B ${DATA_DIR}:${DATA_DIR} \
        -B ${OUTPUT_DIR}:${OUTPUT_DIR} \
        -B ${TEMPLATEFLOW_DIR}:/templateflow \
        --env VFC_BACKENDS="$1" \
        ${SIF_IMG} antsRegistration \
        --verbose 1 \
        --dimensionality 3 \
        --collapse-output-transforms 0 \
        --use-histogram-matching 0 \
        --winsorize-image-intensities [0.005,0.995] \
        --interpolation Linear \
        --random-seed 1 \
        --write-composite-transform 1 \
        --output [${OUTPUT_DIR}/syn_,${OUTPUT_DIR}/Warped.nii.gz,${OUTPUT_DIR}/InverseWarped.nii.gz] \
        --initial-moving-transform ${OUTPUT_DIR}/affine_Composite.h5 \
        --transform SyN[ 0.1,3,0 ] \
        --metric CC[${FIXED_IMG},${INPUT_IMG},1,4] \
        --convergence [100x70x50x20,1e-6,10] \
        --shrink-factors 8x4x2x1 \
        --smoothing-sigmas 3x2x1x0vox
}

case $CONFIG in
    "0000")
    ants_align  "libinterflop_ieee.so"
    ants_rigid  "libinterflop_ieee.so"
    ants_affine "libinterflop_ieee.so"
    ants_syn    "libinterflop_ieee.so"
    ;;
    "0001")
    ants_align  "libinterflop_ieee.so"
    ants_rigid  "libinterflop_ieee.so"
    ants_affine "libinterflop_ieee.so"
    ants_syn    "$VFC_BACKENDS"
    ;;
    "0011")
    ants_align  "libinterflop_ieee.so"
    ants_rigid  "libinterflop_ieee.so"
    ants_affine "$VFC_BACKENDS"
    ants_syn    "$VFC_BACKENDS"
    ;;
    "0100")
    ants_align  "libinterflop_ieee.so"
    ants_rigid  "$VFC_BACKENDS"
    ants_affine "libinterflop_ieee.so"
    ants_syn    "libinterflop_ieee.so"
    ;;
    "0110")
    ants_align  "libinterflop_ieee.so"
    ants_rigid  "$VFC_BACKENDS"
    ants_affine "$VFC_BACKENDS"
    ants_syn    "libinterflop_ieee.so"
    ;;
    "0111")
    ants_align  "libinterflop_ieee.so"
    ants_rigid  "$VFC_BACKENDS"
    ants_affine "$VFC_BACKENDS"
    ants_syn    "$VFC_BACKENDS"
    ;;
    "1111")
    ants_align  "$VFC_BACKENDS"
    ants_rigid  "$VFC_BACKENDS"
    ants_affine "$VFC_BACKENDS"
    ants_syn    "$VFC_BACKENDS"
    ;;
    *)
    echo "Unknown configuration"
    ;;
esac


parent_dir=${OUTPUT_DIR}
tar_dir=${parent_dir}.tar
echo "Creating tar for $parent_dir at $tar_dir"
tar -cvf $tar_dir -C $(dirname $parent_dir) $(basename $parent_dir)
echo "Cleaning up unused files..."
if [ ! -f ${tar_dir} ]; then
        echo "tar dir not found: skip cleanup"
        continue
fi
find $parent_dir -mindepth 1 ! -name 'Warped.nii.gz' -delete
