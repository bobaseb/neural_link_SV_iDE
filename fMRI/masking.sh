#!/bin/bash

#Script number 7. Final.
#Resample masks, binarize them, join left/right masks, answer hypotheses.

#The following commands are needed to load FSL on Myriad.
source /etc/profile.d/modules.sh
FSLv=5.0.9
module load fsl/${FSLv}
source $FSLDIR/etc/fslconf/fsl.sh

#make sure these directories exist
parent_dir=/scratch/scratch/ucjtbob/narps_masks
bin_dir=/scratch/scratch/ucjtbob/narps_masks_bin
cd $parent_dir
msks=(*)
model=narps0-5_gl_entropy
ref=/scratch/scratch/ucjtbob/${model}/narps_level3/CompareLoss.gfeat/mean_func.nii.gz
#standard=/scratch/scratch/ucjtbob/MNI152_T1_1mm_brain.nii.gz

#eye_mat=/scratch/scratch/ucjtbob/narps_level3/narps_entropy_model/identity.mat

for i in ${!msks[@]}
do

msk_tmp=${msks[$i]}

#remove .nii.gz suffix
msk_tmp2=$(echo $msk_tmp|rev)
msk=$(echo ${msk_tmp2:7}|rev)

echo $msk
out=${msk}_narps
#flirt -in mask3mm -ref $FSLDIR/data/standard/MNI152_T1_2mm -applyxfm -usesqform -out mask2mm
flirt -in $msk -ref $ref -applyxfm -usesqform -out $out
#flirt -interp nearestneighbour -in <mask> -ref <mask> -applyisoxfm 4 -out <mask_4mm>
done

right_msks=(Right*_narps.nii.gz)
left_msks=(Left*_narps.nii.gz)

#Assume only Accumbens and Amygdala
fslmaths ${right_msks[0]} -add ${left_msks[0]} Accumbens_narps.nii.gz
fslmaths ${right_msks[1]} -add ${left_msks[1]} Amygdala_narps.nii.gz

#Let's binarize all the masks
msks=(*)
for i in ${!msks[@]}
do

msk_tmp=${msks[$i]}

#remove .nii.gz suffix
msk_tmp2=$(echo $msk_tmp|rev)
msk=$(echo ${msk_tmp2:7}|rev)

echo $msk
out=${bin_dir}/${msk}_bin
fslmaths $msk -thr 50 -bin $out

done

#Now let's compute answers to all 9 hypotheses, and then some.

#level3_dir=/scratch/scratch/ucjtbob/narps_level3
level3_dir=/scratch/scratch/ucjtbob/${model}/narps_level3
#results_dir=/scratch/scratch/ucjtbob/narps_results
results_dir=/scratch/scratch/ucjtbob/${model}/narps_results
bin_dir=/scratch/scratch/ucjtbob/narps_masks_bin

#Parametric effect of gain:

#    Positive effect in ventromedial PFC - for the equal indifference group
msk=${bin_dir}/Frontal_Medial_Cortex_narps_bin.nii.gz
fslmaths ${msk} -mul ${level3_dir}/gainsEqInd.gfeat/cope1.feat/thresh_zstat1.nii.gz ${results_dir}/H1_mskd.nii.gz

#    Positive effect in ventromedial PFC - for the equal range group
msk=${bin_dir}/Frontal_Medial_Cortex_narps_bin.nii.gz
fslmaths ${msk} -mul ${level3_dir}/gainsEqR.gfeat/cope1.feat/thresh_zstat1.nii.gz ${results_dir}/H2_mskd.nii.gz

#    Positive effect in ventral striatum - for the equal indifference group
msk=${bin_dir}/Accumbens_narps_bin.nii.gz
fslmaths ${msk} -mul ${level3_dir}/gainsEqInd.gfeat/cope1.feat/thresh_zstat1.nii.gz ${results_dir}/H3_mskd.nii.gz

#    Positive effect in ventral striatum - for the equal range group 
msk=${bin_dir}/Accumbens_narps_bin.nii.gz
fslmaths ${msk} -mul ${level3_dir}/gainsEqR.gfeat/cope1.feat/thresh_zstat1.nii.gz ${results_dir}/H4_mskd.nii.gz

#Parametric effect of loss:

#    Negative effect in VMPFC - for the equal indifference group
msk=${bin_dir}/Frontal_Medial_Cortex_narps_bin.nii.gz
fslmaths ${msk} -mul ${level3_dir}/lossesEqInd.gfeat/cope1.feat/thresh_zstat2.nii.gz ${results_dir}/H5_mskd.nii.gz

#    Negative effect in VMPFC - for the equal range group
msk=${bin_dir}/Frontal_Medial_Cortex_narps_bin.nii.gz
fslmaths ${msk} -mul ${level3_dir}/lossesEqR.gfeat/cope1.feat/thresh_zstat2.nii.gz ${results_dir}/H6_mskd.nii.gz

#    Positive effect in amygdala - for the equal indifference group
msk=${bin_dir}/Amygdala_narps_bin.nii.gz
fslmaths ${msk} -mul ${level3_dir}/lossesEqInd.gfeat/cope1.feat/thresh_zstat1.nii.gz ${results_dir}/H7_mskd.nii.gz

#    Positive effect in amygdala - for the equal range group
msk=${bin_dir}/Amygdala_narps_bin.nii.gz
fslmaths ${msk} -mul ${level3_dir}/lossesEqR.gfeat/cope1.feat/thresh_zstat1.nii.gz ${results_dir}/H8_mskd.nii.gz

#Equal range vs. equal indifference:

#    Greater positive response to losses in amygdala for equal range condition vs. equal indifference condition.
msk=${bin_dir}/Amygdala_narps_bin.nii.gz
fslmaths ${msk} -mul ${level3_dir}/CompareLoss.gfeat/cope1.feat/thresh_zstat1.nii.gz ${results_dir}/H9a_mskd.nii.gz
fslmaths ${msk} -mul ${level3_dir}/CompareLoss.gfeat/cope1.feat/thresh_zstat2.nii.gz ${results_dir}/H9b_mskd.nii.gz


#results_dir=/scratch/scratch/ucjtbob/narps_results
results_dir=/scratch/scratch/ucjtbob/${model}/narps_results
#let's look at the mean of each resulting image
cd ${results_dir}
results=(*)

for i in ${!results[@]}
do

result_tmp=${results[$i]}

fslmaths ${result_tmp} -abs ${result_tmp}_abs

echo "declare activation if above zero"
fslstats ${result_tmp}_abs -M

done

rm *abs*
