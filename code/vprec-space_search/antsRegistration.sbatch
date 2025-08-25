#!/bin/sh
#SBATCH --job-name=vprec-space_search
#SBATCH --time=20:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=750M
#SBATCH --output=logs/slurm/vprec-space_search-%A_%a.out
set -eu

source ./code/setup.sh

export EXPERIMENT_NAME="vprec-space_search"
export APPTAINERENV_ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=8

# Map task ID to configuration, subject
CONFIG=${VPREC_CONFIGS[$(( ${SLURM_ARRAY_TASK_ID} / ${#SUBJECTS[@]} ))]}
SUBJECT_ID=${SUBJECTS[$(( ${SLURM_ARRAY_TASK_ID} % ${#SUBJECTS[@]} ))]}

LOG_DIR=logs/${EXPERIMENT_NAME}/$CONFIG
mkdir -p $LOG_DIR  # ensure log folder exists

cmds=()
for RANGE in ${VPREC_RANGES[@]}; do
    for PRECISION in ${VPREC_PRECISIONS[@]}; do
        OUTPUT_DIR=${DATA_DIR}/derivatives/${EXPERIMENT_NAME}/$CONFIG/"r$RANGE-p$PRECISION"/sub-${SUBJECT_ID}
        mkdir -p $OUTPUT_DIR  # ensure output folder exists
        OUTPUT_FILE=${OUTPUT_DIR}/Warped.nii.gz

        LOG_FILE=$LOG_DIR/${SUBJECT_ID}-r${RANGE}-p${PRECISION}.log

        if [ -f "${OUTPUT_FILE}" ]; then
            echo "Output exists at ${OUTPUT_FILE}. Skipping." >&2
            continue
        fi

        VFC_BACKENDS="libinterflop_vprec.so --range-binary32=$RANGE --precision-binary32=$PRECISION --range-binary64=$RANGE --precision-binary64=$PRECISION"

        # Launch in background
        cmds+=("srun --exclusive -n1 --time=06:00:00 \
         sh ./code/${EXPERIMENT_NAME}/antsRegistration.sh \
         '$VFC_BACKENDS' '$CONFIG' '$SUBJECT_ID' '$OUTPUT_DIR' \
         > $LOG_FILE 2>&1")

    done
done

printf "%s\n" "${cmds[@]}" | parallel -j 8
