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

#grot_pos=${OUTPUTDIR}/narps_level3/entropy_subval_conj/grot_pos
#grot_neg=${OUTPUTDIR}/narps_level3/entropy_subval_conj/grot_neg

cd ${OUTPUTDIR}/narps_level3/entropy_subval_conj/

easy_thresh=/home/ucjtbob/narps_scripts/easythresh_conj.sh

#easythresh_conj -s $smoothness $pos_entropy_z $pos_subval_z mask 2.3 0.01 $example_func grot
bash $easy_thresh $pos_entropy_z $pos_subval_z 2.3 $example_func grot_pos

bash $easy_thresh $neg_entropy_z $neg_subval_z 2.3 $example_func grot_neg

fslmaths zstat_min_grot_pos.nii.gz -thr 2.3 zstat_min_grot_pos_thresh.nii.gz
fslmaths zstat_min_grot_neg.nii.gz -thr 2.3 zstat_min_grot_neg_thresh.nii.gz

cluster --in=zstat_min_grot_pos_thresh.nii.gz --thresh=0.0001 --oindex=pos_cluster_index --olmax=pos_lmax.txt --osize=pos_cluster_size
cluster --in=zstat_min_grot_neg_thresh.nii.gz --thresh=0.0001 --oindex=neg_cluster_index --olmax=neg_lmax.txt --osize=neg_cluster_size

cd /home/ucjtbob/narps_scripts/
