#!/bin/sh
#SBATCH -J antsBrainExtraction-QC
#SBATCH --time=00:45:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --output=logs/slurm/antsBrainExtraction-QC-%A_%a.out
set -eu

module load fsl

bids_dataset=$1
output_dir=$bids_dataset/derivatives/antsBrainExtraction-QC
mkdir -p $output_dir

subject_ids=($(awk 'NR>1 {print $1}' $bids_dataset/participants.tsv))

echo "Found ${#subject_ids[@]} subjects."
for i in ${!subject_ids[@]}; do
    subject_id=${subject_ids[$i]}
    t1=${bids_dataset}/sub-${subject_id}/ses-1/anat/sub-${subject_id}_ses-1_run-1_T1w.nii.gz
    mask=${bids_dataset}/derivatives/antsBrainExtraction/sub-${subject_id}/BrainExtractionMask.nii.gz

    qc_file=${output_dir}/sub-${subject_id}_lightbox_QC.png

    echo "[$((i+1))/${#subject_ids[@]}] Generating QC for subject $subject_id"

    # Axial
    fsleyes render \
        -s lightbox \
        --labelSpace voxel \
        --ncols 6 \
        --zaxis 2 \
        -ss 0.02 \
        -zr 0.35 0.9 \
        --hideCursor \
        --size 1720 1440 \
        --outfile ${output_dir}/sub-${subject_id}_axial.png \
        $t1 --displayRange 0 500 \
        $mask --overlayType mask --outline --outlineWidth 2 --maskColour 1 0 0
    sleep 2

    # Coronal
    fsleyes render \
        -s lightbox \
        --labelSpace voxel \
        --ncols 6 \
        --zaxis 1 \
        -ss 0.02 \
        -zr 0.1 0.85 \
        --hideCursor \
        --size 1720 1440 \
        --outfile ${output_dir}/sub-${subject_id}_coronal.png \
        $t1 --displayRange 0 500 \
        $mask --overlayType mask --outline --outlineWidth 2 --maskColour 1 0 0
    sleep 2

    # Sagittal
    fsleyes render \
        -s lightbox \
        --labelSpace voxel \
        --ncols 6 \
        --zaxis 0 \
        -ss 0.02 \
        -zr 0.1 0.9 \
        --hideCursor \
        --size 1720 1440 \
        --outfile ${output_dir}/sub-${subject_id}_sagittal.png \
        $t1 --displayRange 0 500 \
        $mask --overlayType mask --outline --outlineWidth 2 --maskColour 1 0 0
    sleep 2

    convert +append ${output_dir}/sub-${subject_id}_axial.png ${output_dir}/sub-${subject_id}_sagittal.png $qc_file
    rm ${output_dir}/sub-${subject_id}_axial.png ${output_dir}/sub-${subject_id}_sagittal.png
done
