#!/bin/sh
set -eu

source ./code/setup.sh

echo "launching sbatch jobs..."
#########################
# ANTs Brain Extraction #
#########################
export SIF_IMG=${ANTS_BASE_SIF}
# brain_extraction=$(sbatch --parsable --array=0-$(( ${#SUBJECTS[@]} - 1 )) ${SLURM_OPTS} ./code/antsBrainExtraction.sbatch)

#####################
# ANTs (Binary 64) #
####################
export SIF_IMG=${ANTS_VPREC_SIF}
# TODO Seperate implementation in antsRegistration.sh
# SBATCH array over all subjects (no combination, only FP64)

###########################
# ANTs VPREC space search #
###########################
export SIF_IMG=${ANTS_VPREC_SIF}
# echo "sbatch --dependency=$brain_extraction \
#     --array=0-$(( ${#VPREC_CONFIGS[@]} * ${#SUBJECTS[@]} - 1 )) \
#     ${SLURM_OPTS} \
#     ./code/vprec-space_search/antsRegistration.sbatch"
sbatch \
    --array=0 \
    ${SLURM_OPTS} \
    ./code/vprec-space_search/antsRegistration.sbatch
# source ./code/vprec-space_search/antsRegistration.sbatch
