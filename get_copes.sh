#!/bin/bash

#Script number 8. Post-final.
#Get all the cops & varcopes for NARPS upload.
save_dir=/home/ucjtbob/narps_final_copes
level2_dir=/scratch/scratch/ucjtbob/narps_entropy_model/narps_level2
level3_dir=/scratch/scratch/ucjtbob/narps_entropy_model/narps_level3

#cope order: intercept, gain, loss, entropy

#Group level
#Parametric effect of gain:

# H1 & H3 positive effect equal indifference group
H1_H3_thresh_zstat=${level3_dir}/gainsEqInd.gfeat/cope1.feat/thresh_zstat1.nii.gz
H1_H3_zstat=${level3_dir}/gainsEqInd.gfeat/cope1.feat/stats/zstat1.nii.gz

cp $H1_H3_thresh_zstat ${save_dir}/H1_H3_thresh_zstat.nii.gz
cp $H1_H3_zstat ${save_dir}/H1_H3_zstat.nii.gz

# H2 & H4 positive effect equal range group
H2_H4_thresh_zstat=${level3_dir}/gainsEqR.gfeat/cope1.feat/thresh_zstat1.nii.gz
H2_H4_zstat=${level3_dir}/gainsEqR.gfeat/cope1.feat/stats/zstat1.nii.gz

cp $H2_H4_thresh_zstat ${save_dir}/H2_H4_thresh_zstat.nii.gz
cp $H2_H4_zstat ${save_dir}/H2_H4_zstat.nii.gz

#Parametric effect of loss:

# H5 negative effect losses equal indifference group
H5_thresh_zstat=${level3_dir}/lossesEqInd.gfeat/cope1.feat/thresh_zstat2.nii.gz
H5_zstat=${level3_dir}/lossesEqInd.gfeat/cope1.feat/stats/zstat2.nii.gz

cp $H5_thresh_zstat ${save_dir}/H5_thresh_zstat.nii.gz
cp $H5_zstat ${save_dir}/H5_zstat.nii.gz

# H6 negative effect losses equal range group
H6_thresh_zstat=${level3_dir}/lossesEqR.gfeat/cope1.feat/thresh_zstat2.nii.gz
H6_zstat=${level3_dir}/lossesEqR.gfeat/cope1.feat/stats/zstat2.nii.gz

cp $H6_thresh_zstat ${save_dir}/H6_thresh_zstat.nii.gz
cp $H6_zstat ${save_dir}/H6_zstat.nii.gz

# H7 positive effect losses equal indifference group
H7_thresh_zstat=${level3_dir}/lossesEqInd.gfeat/cope1.feat/thresh_zstat1.nii.gz
H7_zstat=${level3_dir}/lossesEqInd.gfeat/cope1.feat/stats/zstat1.nii.gz

cp $H7_thresh_zstat ${save_dir}/H7_thresh_zstat.nii.gz
cp $H7_zstat ${save_dir}/H7_zstat.nii.gz

# H8 positive effect losses equal range group
H8_thresh_zstat=${level3_dir}/lossesEqR.gfeat/cope1.feat/thresh_zstat1.nii.gz
H8_zstat=${level3_dir}/lossesEqR.gfeat/cope1.feat/stats/zstat1.nii.gz

cp $H8_thresh_zstat ${save_dir}/H8_thresh_zstat.nii.gz
cp $H8_zstat ${save_dir}/H8_zstat.nii.gz

#Equal range vs. equal indifference:

# H9 positive effect of losses (compare group)
H9a_thresh_zstat=${level3_dir}/CompareLoss.gfeat/cope1.feat/thresh_zstat1.nii.gz #EqualR>EqualInd
H9a_zstat=${level3_dir}/CompareLoss.gfeat/cope1.feat/stats/zstat1.nii.gz

cp $H9a_thresh_zstat ${save_dir}/H9a_thresh_zstat.nii.gz
cp $H9a_zstat ${save_dir}/H9a_zstat.nii.gz

H9b_thresh_zstat=${level3_dir}/CompareLoss.gfeat/cope1.feat/thresh_zstat2.nii.gz #EqualR<EqualInd
H9b_zstat=${level3_dir}/CompareLoss.gfeat/cope1.feat/stats/zstat2.nii.gz

cp $H9b_thresh_zstat ${save_dir}/H9b_thresh_zstat.nii.gz
cp $H9b_zstat ${save_dir}/H9b_zstat.nii.gz

#Subject copes & varcopes for losses & gains

cd $level2_dir
sub_fldrs=(*)
for i in ${!sub_fldrs[@]}
do

sub_fldr=${sub_fldrs[$i]}
SUBJ=${sub_fldr:3:3}

cp ${sub_fldr}/cope2.feat/stats/cope1.nii.gz ${save_dir}/gains_cope_sub${SUBJ}.nii.gz  #gains cope
cp ${sub_fldr}/cope2.feat/stats/varcope1.nii.gz ${save_dir}/gains_varcope_sub${SUBJ}.nii.gz  #gains varcope

cp ${sub_fldr}/cope3.feat/stats/cope1.nii.gz ${save_dir}/loss_cope_sub${SUBJ}.nii.gz  #loss cope
cp ${sub_fldr}/cope3.feat/stats/varcope1.nii.gz ${save_dir}/loss_varcope_sub${SUBJ}.nii.gz  #loss varcope

done
