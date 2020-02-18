#!/bin/bash

#run t-tests on BICs with randomise

curr_model=narps1-5_subval_entropy
parent_dir=/scratch/scratch/ucjtbob/${curr_model}
entropy=${parent_dir}/narps1_only_entropy_model/BIC_level2
subval=${parent_dir}/narps1_only_subval_model/BIC_level2
both=${parent_dir}/narps1_subval_entropy/BIC_level2


cd $both
sub_means=(BIC_sub*_mean.nii.gz)
sub_medians=(BIC_sub*_median.nii.gz)

sub_means2=()
sub_medians2=()
for i in ${!sub_means[@]}
do

sub_mean=${sub_means[${i}]}
sub_median=${sub_medians[${i}]}

SUBJ=${sub_means[${i}]:7:3}

#Remove the trailing zeros.
SUBJNUM=$(echo ${SUBJ} | sed 's/^0*//')

#echo $SUBJNUM
#exit 1

#Skip excluded subjects (see above).
if [[ $((SUBJNUM)) == 13 ]] || [[ $((SUBJNUM)) == 25 ]] || [[ $((SUBJNUM)) == 30 ]] || [[ $((SUBJNUM)) == 56 ]]
then
  echo subject ${SUBJNUM} excluded
  continue
fi

sub_means2+=($sub_mean)
sub_medians2+=($sub_median)

done

#first do some merging across subs

#call FSL
source /etc/profile.d/modules.sh
FSLv=5.0.9
module load fsl/${FSLv}
source $FSLDIR/etc/fslconf/fsl.sh

cd $both
fslmerge -t BIC_means.nii.gz ${sub_means2[@]}
fslmerge -t BIC_medians.nii.gz ${sub_medians2[@]}

cd $entropy
fslmerge -t BIC_means.nii.gz ${sub_means2[@]}
fslmerge -t BIC_medians.nii.gz ${sub_medians2[@]}

cd $subval
fslmerge -t BIC_means.nii.gz ${sub_means2[@]}
fslmerge -t BIC_medians.nii.gz ${sub_medians2[@]}

#compute differences between models (both means and medians)

mkdir ${parent_dir}/narps1_BIC_diffs
cd ${parent_dir}/narps1_BIC_diffs

#entropy/both means BIC diff
fslmaths ${both}/BIC_means.nii.gz -sub ${entropy}/BIC_means.nii.gz both_minus_entropy_means.nii.gz
fslmaths ${entropy}/BIC_means.nii.gz -sub ${both}/BIC_means.nii.gz entropy_minus_both_means.nii.gz

#entropy/both medians BIC diff
fslmaths ${both}/BIC_medians.nii.gz -sub ${entropy}/BIC_medians.nii.gz both_minus_entropy_medians.nii.gz
fslmaths ${entropy}/BIC_medians.nii.gz -sub ${both}/BIC_medians.nii.gz entropy_minus_both_medians.nii.gz

#subval/both means BIC diff
fslmaths ${both}/BIC_means.nii.gz -sub ${subval}/BIC_means.nii.gz both_minus_subval_means.nii.gz
fslmaths ${subval}/BIC_means.nii.gz -sub ${both}/BIC_means.nii.gz subval_minus_both_means.nii.gz

#subval/both medians BIC diff
fslmaths ${both}/BIC_medians.nii.gz -sub ${subval}/BIC_medians.nii.gz both_minus_subval_medians.nii.gz
fslmaths ${subval}/BIC_medians.nii.gz -sub ${both}/BIC_medians.nii.gz subval_minus_both_medians.nii.gz

#subval/entropy means BIC diff
fslmaths ${entropy}/BIC_means.nii.gz -sub ${subval}/BIC_means.nii.gz entropy_minus_subval_means.nii.gz
fslmaths ${subval}/BIC_means.nii.gz -sub ${entropy}/BIC_means.nii.gz subval_minus_entropy_means.nii.gz

#subval/entropy medians BIC diff
fslmaths ${entropy}/BIC_medians.nii.gz -sub ${subval}/BIC_medians.nii.gz entropy_minus_subval_medians.nii.gz
fslmaths ${subval}/BIC_medians.nii.gz -sub ${entropy}/BIC_medians.nii.gz subval_minus_entropy_medians.nii.gz
