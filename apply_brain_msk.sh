#!/bin/bash

#Script number 1 after obtaining fmriprep data.
#Applies the brain mask from fmriprep using fslmaths.

#The following two commands are needed to load FSL on Myriad.
module load fsl/5.0.9
source $FSLDIR/etc/fslconf/fsl.sh

parent_dir=/scratch/scratch/ucjuogu/NARPS2/derivatives/fmriprep

cd parent_dir

subfldrs=(sub*/)

for i in ${!subfldrs[@]}
do

subj=${subfldrs[$i]:4:3}

echo $subj

  for run in 01 02 03 04
  do

    echo $run

    curr_dir=${parent_dir}/sub-${subj}/func

    brain_msk=${curr_dir}/sub-${subj}_task-MGT_run-${run}_bold_space-MNI152NLin2009cAsym_brainmask.nii.gz
    bold_file=${curr_dir}/sub-${subj}_task-MGT_run-${run}_bold_space-MNI152NLin2009cAsym_preproc.nii.gz
    mskd_bold=${curr_dir}/sub-${subj}_task-MGT_run-${run}_bold_space-MNI152NLin2009cAsym_preproc_brain.nii.gz

    fslmaths ${bold_file} -mul ${brain_msk} ${mskd_bold}

done

done
