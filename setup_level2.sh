#!/bin/bash

#Script number 4 (after running level 1).
#Some hacks to avoid registration when level 2 is run.

#The following two commands are needed to load FSL on Myriad.
#These commands may need to be entered manually for some reason.
echo have you loaded FSL?
FSLv=5.0.9
module load fsl/${FSLv}
source $FSLDIR/etc/fslconf/fsl.sh

parent_dir=/scratch/scratch/ucjtbob/narps_level1
fmriprep_dir=/scratch/scratch/ucjuogu/NARPS2/derivatives/fmriprep

cd ${fmriprep_dir}

subfldrs=(sub*/)

for i in ${!subfldrs[@]}
do

subj=${subfldrs[$i]:4:3}

echo subject $subj

  for run in 01 02 03 04
  do

    echo run $run

    curr_dir=${parent_dir}/sub${subj}_run${run}.feat

    cd ${curr_dir}/reg

    rm *.mat

    cp ${FSLDIR}/etc/flirtsch/ident.mat ${curr_dir}/reg/example_func2standard.mat

    cd ..

    cp ${curr_dir}/mean_func.nii.gz ${curr_dir}/reg/standard.nii.gz

done

done
