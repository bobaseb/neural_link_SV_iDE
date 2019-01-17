#!/bin/bash

#Script number 6. Final.
#Resample masks and binarize them.

parent_dir=/scratch/scratch/ucjtbob/narps_masks

cd parent_dir

msks=(*)

for i in ${!subfldrs[@]}
do

subj=${subfldrs[$i]:4:3}

echo $subj

  for run in 01 02 03 04
  do

    echo $run

    curr_dir=${parent_dir}/sub-${subj}/func

    confounds=${curr_dir}/sub-${subj}_task-MGT_run-${run}_bold_confounds.tsv

    python get_confounds.py ${confounds}

done

done
