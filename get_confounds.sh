#!/bin/bash

#Script number 2 after obtaining fmriprep data.
#Pick your confounds and put into an appropriate space separated file.
#Relies on get_confounds.py for the data munging.

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

    confounds=${curr_dir}/sub-${subj}_task-MGT_run-${run}_bold_confounds.tsv

    python get_confounds.py ${confounds}

done

done
