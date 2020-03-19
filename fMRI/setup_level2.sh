#!/bin/bash

#Script number 4 (after running level 1).
#Some hacks to avoid registration when level 2 is run.

#The following commands are needed to load FSL on Myriad.
#call FSL
source /etc/profile.d/modules.sh
FSLv=5.0.9
module load fsl/${FSLv}
source $FSLDIR/etc/fslconf/fsl.sh

model=narps1-5_conflict2 #narps1-5_subvalY_entropy #narps1-5_conflict
#narps1-5_gl_entropy

which_scratch=skgtdnb #ucjtbob

parent_dir=/scratch/scratch/${which_scratch}/${model}/narps_level1
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

    cp example_func2standard.mat example_func2standard_old.txt
    cp standard2example_func.mat standard2example_func_old.txt
    rm *.mat

    cp ${FSLDIR}/etc/flirtsch/ident.mat ${curr_dir}/reg/example_func2standard.mat

    cd ..

    cp ${curr_dir}/mean_func.nii.gz ${curr_dir}/reg/standard.nii.gz

done

done
