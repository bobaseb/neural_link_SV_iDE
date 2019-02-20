#!/bin/bash

#BIC script, run after level 1

#narps1_only_subval_model #narps1_subval_entropy #narps1_only_entropy_model
#uses res4d.nii.gz output from FEAT/FSL
curr_model=narps1_subval_entropy
parent_dir=/scratch/scratch/ucjtbob/${curr_model}/narps_level1
home_dir=/home/ucjtbob

#source /home/ucjtbob/Envs/pymvpa/bin/activate
source /etc/profile.d/modules.sh
module unload compilers
module load compilers/gnu/4.9.2
module load swig/3.0.7/gnu-4.9.2
module load python2/recommended

cd ${parent_dir}

subfldrs=(sub*/)

for sub_fldr in ${subfldrs[@]}
do

echo $sub_fldr

curr_dir=${parent_dir}/${sub_fldr}stats/

cd ${curr_dir}

k_tmp=(pe*.nii.gz)
k=${#k_tmp[@]}

python ${home_dir}/narps_scripts/get_BIC.py ${curr_dir} ${k}

exit 1
done
