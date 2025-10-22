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
# sbatch --dependency=$brain_extraction \
#     ${SLURM_OPTS} \
    # --array=0-$(( ${#SUBJECTS[@]} - 1 )) \
    # ./code/vprec-space_search/antsRegistration-FP64.sbatch
sbatch ${SLURM_OPTS} \
    --array=1-$(( ${#SUBJECTS[@]} - 1 )) \
    ./code/vprec-space_search/antsRegistration-FP64.sbatch

###########################
# ANTs VPREC space search #
###########################
export SIF_IMG=${ANTS_VPREC_SIF}
# sbatch --dependency=$brain_extraction \
#     --array=0-$(( ${#VPREC_CONFIGS[@]} * ${#SUBJECTS[@]} - 1 )) \
#     ${SLURM_OPTS} \
#     ./code/vprec-space_search/antsRegistration.sbatch
