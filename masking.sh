#!/bin/bash

#Script number 6. Final.
#Resample masks, binarize them, join left/right masks, answer hypotheses.

#The following two commands are needed to load FSL on Myriad.
FSLv=5.0.9
module load fsl/${FSLv}
source $FSLDIR/etc/fslconf/fsl.sh

#make sure these directories exist
parent_dir=/scratch/scratch/ucjtbob/narps_masks
bin_dir=/scratch/scratch/ucjtbob/narps_masks_bin
cd $parent_dir
msks=(*)
ref=/scratch/scratch/ucjtbob/narps_level3/CompareLoss.gfeat/mean_func.nii.gz
#standard=/scratch/scratch/ucjtbob/MNI152_T1_1mm_brain.nii.gz

for i in ${!msks[@]}
do

msk_tmp=${msks[$i]}

#remove .nii.gz suffix
msk_tmp2=$(echo $msk_tmp|rev)
msk=$(echo ${msk_tmp2:7}|rev)

echo $msk
out=${msk}_narps
flirt -in $msk -ref $ref -out $out -applyxfm
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
fslmaths $msk -bin $out

done

#Now let's compute answers to all 9 hypotheses, and then some.

level3_dir=/scratch/scratch/ucjtbob/narps_level3
results_dir=/scratch/scratch/ucjtbob/narps_results
bin_dir=/scratch/scratch/ucjtbob/narps_masks_bin

#Parametric effect of gain:

#    Positive effect in ventromedial PFC - for the equal indifference group
msk=${bin_dir}/Frontal_Medial_Cortex_narps_bin.nii.gz
fslmaths ${msk} -mul ${level3_dir}/gainsEqInd.gfeat/cope1.feat/stats/zstat1.nii.gz ${results_dir}/H1_mskd.nii.gz

#    Positive effect in ventromedial PFC - for the equal range group
msk=${bin_dir}/Frontal_Medial_Cortex_narps_bin.nii.gz
fslmaths ${msk} -mul ${level3_dir}/gainsEqR.gfeat/cope1.feat/stats/zstat1.nii.gz ${results_dir}/H2_mskd.nii.gz

#    Positive effect in ventral striatum - for the equal indifference group
msk=${bin_dir}/Accumbens_narps_bin.nii.gz
fslmaths ${msk} -mul ${level3_dir}/gainsEqInd.gfeat/cope1.feat/stats/zstat1.nii.gz ${results_dir}/H3_mskd.nii.gz

#    Positive effect in ventral striatum - for the equal range group
msk=${bin_dir}/Accumbens_narps_bin.nii.gz
fslmaths ${msk} -mul ${level3_dir}/gainsEqR.gfeat/cope1.feat/stats/zstat1.nii.gz ${results_dir}/H4_mskd.nii.gz

#Parametric effect of loss:

#    Negative effect in VMPFC - for the equal indifference group
msk=${bin_dir}/Frontal_Medial_Cortex_narps_bin.nii.gz
fslmaths ${msk} -mul ${level3_dir}/lossesEqInd.gfeat/cope1.feat/stats/zstat2.nii.gz ${results_dir}/H5_mskd.nii.gz

#    Negative effect in VMPFC - for the equal range group
msk=${bin_dir}/Frontal_Medial_Cortex_narps_bin.nii.gz
fslmaths ${msk} -mul ${level3_dir}/lossesEqR.gfeat/cope1.feat/stats/zstat2.nii.gz ${results_dir}/H6_mskd.nii.gz

#    Positive effect in amygdala - for the equal indifference group
msk=${bin_dir}/Amygdala_narps_bin.nii.gz
fslmaths ${msk} -mul ${level3_dir}/lossesEqInd.gfeat/cope1.feat/stats/zstat1.nii.gz ${results_dir}/H7_mskd.nii.gz

#    Positive effect in amygdala - for the equal range group
msk=${bin_dir}/Amygdala_narps_bin.nii.gz
fslmaths ${msk} -mul ${level3_dir}/lossesEqR.gfeat/cope1.feat/stats/zstat1.nii.gz ${results_dir}/H8_mskd.nii.gz

#Equal range vs. equal indifference:

#    Greater positive response to losses in amygdala for equal range condition vs. equal indifference condition.
msk=${bin_dir}/Amygdala_narps_bin.nii.gz
fslmaths ${msk} -mul ${level3_dir}/CompareLoss.gfeat/cope1.feat/stats/zstat1.nii.gz ${results_dir}/H9a_mskd.nii.gz
fslmaths ${msk} -mul ${level3_dir}/CompareLoss.gfeat/cope1.feat/stats/zstat2.nii.gz ${results_dir}/H9b_mskd.nii.gz


#let's look at the mean of each resulting image
cd ${results_dir}
results=(*)

for i in ${!results[@]}
do

result_tmp=${results[$i]}

fslstats ${result_tmp} -m

done

#answers by visual inspection below
"
##Main Hypotheses

#H1: Positive effect of gains in ventromedial PFC - for the equal indifference group
#2 significant clusters; one at left pre/post central gyrus (-48,-16, 51.6) and one at left parahippocampal gyrus (see H3)
#no ventromedial PFC
#Answer is No.

#H2: Positive effect of gains in ventromedial PFC - for the equal range group
#zstat1 (mean>0)
#16 significant clusters, closest cluster is frontal orbital cortex & frontal pole
#Left Ventral Striatum (i.e., Left Nucleus Accumbens) is significant (see H4)
#Answer is No.

#H3: Positive effect of gains in ventral striatum - for the equal indifference group
#zstat1 (mean>0)
#2 significant clusters; one at left pre/post central gyrus (-48,-16, 51.6) and one at left parahippocampal gyrus
#no ventral striatum
#Answer is No.

#H4: Positive effect of gains in ventral striatum - for the equal range group
#zstat1 (mean>0)
#16 significant clusters, only left nucleus accumbens is significant (cluster #7)
#Answer is Yes.

#H5: Negative effect of losses in VMPFC - for the equal indifference group
#zstat2 (mean<0)
#17 significant clusters, most significant cluster is VMPFC
#Answer is Yes.

#H6: Negative effect of losses in VMPFC - for the equal range group
#zstat2 (mean<0)
#11 significant clusters, most significant cluster is VMPFC
#Answer is Yes.

#H7: Positive effect of losses in amygdala - for the equal indifference group
#zstat1 (mean>0)
#11 significant clusters, no amygdala
#Answer is No.

#H8: Positive effect of losses in amygdala - for the equal range group
#zstat1 (mean>0)
#6 significant clusters, no amygdala
#Answer is No.

#H9: Greater positive response to losses in amygdala for equal range condition vs. equal indifference condition.
#zstat1 (EqualR>EqualInd)
#cluster 1 at right pre/post central gyrus (46,-14,46.8)
#cluster 2 at precuneous cortex/cingulate gyrus  (-2,-54,15.6)
#zstat2 (EqualInd>EqualR)
#14 significant clusters, no amygdala
#Answer is No.

###Entropy Results
#E1: Positive effect - for the equal indifference group
#Huge cluster of 30,000 voxels spanning occipital, temporal, parietal, and prefrontal areas
#This huge activation includes a big vmPFC activation as well as nucleus accumbens and amygdala.
#2nd small cluster in cerebellum (near left crus II).

#E2: Negative effect - for the equal indifference group
#Huge cluster of 25,000 voxels originating in the paracingulate gyrus spreading to other frontal gyrii
#other clusters include superior parietal lobule, insula, LOC superior division, cerebellum (11 significant clusters total)
#not much IT activation except near the occipital end
#no vmPFC, no amygdala, no ventral striatum

#**E1 & E2 activations seem somewhat non-overlapping

#E3: Positive effect - for the equal range group
#Huge cluster of almost 30,000 voxels originating from vmPFC going through precuneous cortex, cingulate gyrus to occipital pole
#includes activation in nucleus accumbens (ventral striatum) and amygdala (both bilaterally)
#other 3 clusters in middle/superior frontal gyrii, left pre/post central gyrii, frontal orbital cortex & frontal pole

#E4: Negative effect - for the equal range group
#9 clusters total. Biggest one originating in paracingulate gyrus (8400 voxels).
#also cerebellum, angular/supramrginal gyrus (6000 voxels), LOC, superior parietal
# and insular cortex/frontal operculum (4600 voxels)
#no vmPFC, no amygdala, no ventral striatum

#*** E1 mirrors E3 & E2 mirrors E4"
