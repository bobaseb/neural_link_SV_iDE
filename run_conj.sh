#!/bin/sh

#call FSL
source /etc/profile.d/modules.sh
FSLv=5.0.9
module load fsl/${FSLv}
source $FSLDIR/etc/fslconf/fsl.sh

curr_model=narps1_subval_entropy
OUTPUTDIR=/scratch/scratch/ucjtbob/${curr_model}

smoothness=${OUTPUTDIR}/narps_level3/entropyAllSubs.gfeat/cope1.feat/stats/smoothness
example_func=${OUTPUTDIR}/narps_level3/entropyAllSubs.gfeat/cope1.feat/example_func.nii.gz

pos_entropy_z=${OUTPUTDIR}/narps_level3/entropyAllSubs.gfeat/cope1.feat/stats/zstat1.nii.gz
neg_entropy_z=${OUTPUTDIR}/narps_level3/entropyAllSubs.gfeat/cope1.feat/stats/zstat2.nii.gz
pos_subval_z=${OUTPUTDIR}/narps_level3/subvalAllSubs.gfeat/cope1.feat/stats/zstat1.nii.gz
neg_subval_z=${OUTPUTDIR}/narps_level3/subvalAllSubs.gfeat/cope1.feat/stats/zstat2.nii.gz

pos_entropy_p=${OUTPUTDIR}/narps_level3/entropyAllSubs.gfeat/cope1.feat/stats/pval1.nii.gz
neg_entropy_p=${OUTPUTDIR}/narps_level3/entropyAllSubs.gfeat/cope1.feat/stats/pval2.nii.gz
pos_subval_p=${OUTPUTDIR}/narps_level3/subvalAllSubs.gfeat/cope1.feat/stats/pval1.nii.gz
neg_subval_p=${OUTPUTDIR}/narps_level3/subvalAllSubs.gfeat/cope1.feat/stats/pval2.nii.gz

#fslmaths $pos_entropy_z -ztop ${pos_entropy_p}
#fslmaths $pos_subval_z -ztop ${pos_subval_p}
#fslmaths $neg_entropy_z -ztop ${neg_entropy_p}
#fslmaths $neg_subval_z -ztop ${neg_subval_p}

entropy_minus_subval_p=${OUTPUTDIR}/second_level_diffs/signed_diffs/entropy_minus_subval_tfce_corrp_tstat1.nii.gz
subval_minus_entropy_p=${OUTPUTDIR}/second_level_diffs/signed_diffs/subval_minus_entropy_tfce_corrp_tstat1.nii.gz

entropy_minus_subval_zstat1=${OUTPUTDIR}/second_level_diffs/signed_diffs/entropy_minus_subval_zstat1.nii.gz
subval_minus_entropy_zstat1=${OUTPUTDIR}/second_level_diffs/signed_diffs/subval_minus_entropy_zstat1.nii.gz

#fslmaths $entropy_minus_subval_p -ptoz $entropy_minus_subval_zstat1
#fslmaths $entropy_minus_subval_zstat1 -abs $entropy_minus_subval_zstat1 #this is because we operate on 1-p instead of p
#fslmaths $subval_minus_entropy_p -ptoz $subval_minus_entropy_zstat1
#fslmaths $subval_minus_entropy_zstat1 -abs $subval_minus_entropy_zstat1 #this is because we operate on 1-p instead of p

#grot_pos=${OUTPUTDIR}/narps_level3/entropy_subval_conj/grot_pos
#grot_neg=${OUTPUTDIR}/narps_level3/entropy_subval_conj/grot_neg

cd ${OUTPUTDIR}/narps_level3/entropy_subval_conj/

easy_thresh=/home/ucjtbob/narps_scripts/easythresh_conj.sh

#easythresh_conj -s $smoothness $pos_entropy_z $pos_subval_z mask 2.3 0.01 $example_func grot
#bash $easy_thresh $pos_entropy_z $pos_subval_z 2.3 $example_func grot_pos
#bash $easy_thresh $neg_entropy_z $neg_subval_z 2.3 $example_func grot_neg

in_conj_prefix=entropy_minus_subval_neg #subval_minus_entropy_pos #entropy_minus_subval_pos #subval_minus_entropy_neg #
#bash $easy_thresh $entropy_minus_subval_zstat1 $pos_entropy_z 2.3 $example_func ${in_conj_prefix}
#bash $easy_thresh $subval_minus_entropy_zstat1 $pos_subval_z 2.3 $example_func ${in_conj_prefix}
#bash $easy_thresh $entropy_minus_subval_zstat1 $neg_subval_z 2.3 $example_func ${in_conj_prefix} # bigger than interacts with other variable for negs (neg effect of subval here)
#(should've used zstat2 to avoid confusion)
bash $easy_thresh $subval_minus_entropy_zstat1 $neg_entropy_z 2.3 $example_func ${in_conj_prefix} # bigger than interacts with other variable for negs (neg effect of entropy here)

#exit 1

#fslmaths zstat_min_grot_pos.nii.gz -thr 2.3 zstat_min_grot_pos_thresh.nii.gz
#fslmaths zstat_min_grot_neg.nii.gz -thr 2.3 zstat_min_grot_neg_thresh.nii.gz
fslmaths zstat_min_${in_conj_prefix}.nii.gz -thr 2.3 zstat_min_${in_conj_prefix}_thresh.nii.gz


#cluster --in=zstat_min_grot_pos_thresh.nii.gz --thresh=0.0001 --oindex=pos_cluster_index --olmax=pos_lmax.txt --osize=pos_cluster_size
#cluster --in=zstat_min_grot_neg_thresh.nii.gz --thresh=0.0001 --oindex=neg_cluster_index --olmax=neg_lmax.txt --osize=neg_cluster_size
cluster --in=zstat_min_${in_conj_prefix}_thresh.nii.gz --thresh=0.0001 --oindex=${in_conj_prefix}_cluster_index --olmax=${in_conj_prefix}_lmax.txt --osize=${in_conj_prefix}_cluster_size

fslnums=$(fslstats zstat_min_${in_conj_prefix}_thresh.nii.gz -v)
TOT_VOXELS=${fslnums:0:(`expr index "$fslnums"  " "`)}
echo total non-zero voxels ${TOT_VOXELS}
cluster -i zstat_min_${in_conj_prefix}_thresh.nii.gz -t 2.3 -p 0.05 -d 0.0136188 --oindex=${in_conj_prefix}_cluster_index --olmax=${in_conj_prefix}_lmax.txt --osize=${in_conj_prefix}_cluster_size --volume=${TOT_VOXELS} > cluster_zstat1_${in_conj_prefix}.txt


cd /home/ucjtbob/narps_scripts/
