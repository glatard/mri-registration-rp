export WORK_DIR=$SCRATCH/mri-registration-rp
export TEMPLATEFLOW_DIR=${PROJECT_HOME}/templateflow
export SIF_DIR=${PROJECT_HOME}/containers
export ANTS_BASE_SIF=${SIF_DIR}/ants-p2-baseline.sif
export DATA_DIR=${PROJECT_HOME}/datasets/corr/RawDataBIDS/BMB_1
export DATALAD_URL="https://datasets.datalad.org/corr/RawDataBIDS/BMB_1"
export SUBJECTS=($(awk 'NR>1 {print $1}' ${DATA_DIR}/participants.tsv))
export SLURM_OPTS="--account=rrg-glatard"

# PMIN
export ANTS_PMIN_SIF=${SIF_DIR}/ants-p2-pmin.sif

# VPREC
export ANTS_VPREC_SIF=${SIF_DIR}/ants-p2-vprec.sif
export VPREC_RANGES=(8 7)
export VPREC_PRECISIONS=({23..6})
export VPREC_CONFIGS=("0001" "0011" "0100" "0110" "0111" "1111")
export N_COMBINATIONS=$((${#VPREC_PRECISIONS[@]} * ${#VPREC_RANGES[@]}))
