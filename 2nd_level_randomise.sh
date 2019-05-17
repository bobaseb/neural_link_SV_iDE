#!/bin/bash -l

# Batch script to run FSL on Myriad
#
# Oct 2015
#
# Based on serial.sh by:
#
# Owain Kenway, Research Computing, 16/Sept/2010

#$ -S /bin/bash

# 1. Request 1 hour of wallclock time (format hours:minutes:seconds).
#$ -l h_rt=40:0:0

# 2. Request 4 gigabyte of RAM.
#$ -l mem=4G

# Note: some FSL programs are multi-threaded eg FEAT and you will need to
# use -pe smp 12 as well.
#$ -pe smp 12

# 3. Set the name of the job.
#$ -N narps2_randomise

# 6. Set the working directory to somewhere in your scratch space.  This is
# a necessary step with the upgraded software stack as compute nodes cannot
# write to $HOME.

# Note: this directory MUST exist before your job starts!
# Replace "<your_UCL_id>" with your UCL user ID :)
#$ -wd /home/ucjtbob/Scratch/narps1-5_subval_entropy/second_level_diffs_logs
# make n jobs run with different numbers
#$ -t 1-2

#1-2 for both directions in signed_diffs
#job_num=$( expr $SGE_TASK_ID - 1 )

# 7. Setup FSL runtime environment

#The following two commands are needed to load FSL on Myriad.
FSLv=5.0.9
module load fsl/${FSLv}
source $FSLDIR/etc/fslconf/fsl.sh

# 8. Need this environment variable for FEAT and other methods eg bedpostx to
# stop job submission from within jobs and qrsh sessions.

export FSLSUBALREADYRUN=true

#make sure that second_level_diffs & second_level_diffs_logs exists!!!

parent_dir=/scratch/scratch/ucjtbob #if on myriad
model_dir=narps1-5_subval_entropy
level=narps_level2
#narps1_subval_entropy/narps_level2/sub001.gfeat/cope2.feat/stats/zstat1.nii.gz
signed_or_abs=abs #signed #
mkdir ${parent_dir}/${model_dir}/second_level_diffs/${signed_or_abs}_diffs

cd ${parent_dir}/${model_dir}/${level}
subfldrs=(sub*/)

subvals=()
entropies=()
for i in ${!subfldrs[@]}
do
SUBJ=${subfldrs[${i}]:3:3}
#Remove the trailing zeros.
SUBJNUM=$(echo ${SUBJ} | sed 's/^0*//')
#Skip excluded subjects (see above).
if [[ $((SUBJNUM)) == 13 ]] || [[ $((SUBJNUM)) == 25 ]] || [[ $((SUBJNUM)) == 30 ]] || [[ $((SUBJNUM)) == 56 ]]
then
  echo subject ${SUBJNUM} excluded
  continue
fi

#Stat filename.
#fn_subval=${parent_dir}/${model_dir}/${level}/sub${SUBJ}.gfeat/cope2.feat/stats/zstat1.nii.gz
#fn_entropy=${parent_dir}/${model_dir}/${level}/sub${SUBJ}.gfeat/cope3.feat/stats/zstat1.nii.gz
fn_subval=${parent_dir}/${model_dir}/${level}/sub${SUBJ}.gfeat/cope2.feat/stats/zstat1.nii.gz
fn_entropy=${parent_dir}/${model_dir}/${level}/sub${SUBJ}.gfeat/cope3.feat/stats/zstat2.nii.gz

subvals+=(${fn_subval})
entropies+=(${fn_entropy})
done

cd ${parent_dir}/${model_dir}/second_level_diffs/${signed_or_abs}_diffs
subval_z_fn=${parent_dir}/${model_dir}/second_level_diffs/${signed_or_abs}_diffs/subval_z.nii.gz
entropy_z_fn=${parent_dir}/${model_dir}/second_level_diffs/${signed_or_abs}_diffs/entropies_z.nii.gz

if [[ $((SGE_TASK_ID)) -eq $((1)) ]]; then
  which_sign=SV_minus_DE_${signed_or_abs}
elif [[ $((SGE_TASK_ID)) -eq $((2)) ]]; then
  which_sign=DE_minus_SV_${signed_or_abs}
fi

if [ ! -f ${subval_z_fn} ]; then
    fslmerge -t ${subval_z_fn} ${subvals[@]}
fi

if [ ! -f ${entropy_z_fn} ]; then
    fslmerge -t ${entropy_z_fn} ${entropies[@]}
fi

if [[ $((signed_or_abs)) -eq abs ]]; then
  echo ${signed_or_abs} condition
  fslmaths ${subval_z_fn} -abs ${subval_z_fn}
  fslmaths ${entropy_z_fn} -abs ${entropy_z_fn}
fi

if [[ $((SGE_TASK_ID)) -eq $((1)) ]]; then
  fslmaths ${subval_z_fn} -sub  ${entropy_z_fn} ${which_sign}
elif [[ $((SGE_TASK_ID)) -eq $((2)) ]]; then
  fslmaths  ${entropy_z_fn} -sub ${subval_z_fn} ${which_sign}
fi

randomise_parallel -i ${which_sign}.nii.gz -o ${which_sign} -1 -T
fslmaths ${which_sign}_tfce_corrp_tstat1 -thr 0.99 -bin -mul ${which_sign}_tstat1 ${which_sign}_thresh_tstat1
cluster --in=${which_sign}_thresh_tstat1 --thresh=0.0001 --oindex=${which_sign}_cluster_index --olmax=${which_sign}_lmax.txt --osize=${which_sign}_cluster_size --mm
