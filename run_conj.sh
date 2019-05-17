#!/bin/sh

#call FSL
source /etc/profile.d/modules.sh
FSLv=5.0.9
module load fsl/${FSLv}
source $FSLDIR/etc/fslconf/fsl.sh

curr_model=narps1-5_subval_entropy
OUTPUTDIR=/scratch/scratch/ucjtbob/${curr_model}

alignment=zstat1s #flip_DE_sign #zstat1s

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

entropy_minus_subval_p=${OUTPUTDIR}/second_level_diffs/signed_diffs/${alignment}/DE_minus_SV_signed_tfce_corrp_tstat1.nii.gz
subval_minus_entropy_p=${OUTPUTDIR}/second_level_diffs/signed_diffs/${alignment}/SV_minus_DE_signed_tfce_corrp_tstat1.nii.gz

entropy_minus_subval_zstat1=${OUTPUTDIR}/second_level_diffs/signed_diffs/${alignment}/DE_minus_SV_signed_zstat1.nii.gz
subval_minus_entropy_zstat1=${OUTPUTDIR}/second_level_diffs/signed_diffs/${alignment}/SV_minus_DE_signed_zstat1.nii.gz

fslmaths $entropy_minus_subval_p -ptoz $entropy_minus_subval_zstat1
fslmaths $entropy_minus_subval_zstat1 -abs $entropy_minus_subval_zstat1 #this is because we operate on 1-p instead of p
fslmaths $subval_minus_entropy_p -ptoz $subval_minus_entropy_zstat1
fslmaths $subval_minus_entropy_zstat1 -abs $subval_minus_entropy_zstat1 #this is because we operate on 1-p instead of p

#CONJUNCTIONS

mkdir ${OUTPUTDIR}/narps_level3/entropy_subval_conj
SEpos_DEpos=${OUTPUTDIR}/narps_level3/entropy_subval_conj/SVpos_DEpos
SEpos_DEneg=${OUTPUTDIR}/narps_level3/entropy_subval_conj/SVpos_DEneg
SEneg_DEneg=${OUTPUTDIR}/narps_level3/entropy_subval_conj/SVneg_DEneg
SEneg_DEpos=${OUTPUTDIR}/narps_level3/entropy_subval_conj/SVneg_DEpos

cd ${OUTPUTDIR}/narps_level3/entropy_subval_conj/

easy_thresh=/home/ucjtbob/narps_scripts/easythresh_conj.sh

#easythresh_conj -s $smoothness $pos_entropy_z $pos_subval_z mask 2.3 0.01 $example_func grot
bash $easy_thresh $pos_subval_z $pos_entropy_z 2.3 $example_func SVpos_DEpos
bash $easy_thresh $pos_subval_z $neg_entropy_z 2.3 $example_func SVpos_DEneg
bash $easy_thresh $neg_subval_z $neg_entropy_z 2.3 $example_func SVneg_DEneg
bash $easy_thresh $neg_subval_z $pos_entropy_z 2.3 $example_func SVneg_DEpos


fslmaths zstat_min_SVpos_DEpos.nii.gz -thr 2.3 zstat_min_SVpos_DEpos_thresh.nii.gz
fslmaths zstat_min_SVpos_DEneg.nii.gz -thr 2.3 zstat_min_SVpos_DEneg_thresh.nii.gz
fslmaths zstat_min_SVneg_DEneg.nii.gz -thr 2.3 zstat_min_SVneg_DEneg_thresh.nii.gz
fslmaths zstat_min_SVneg_DEpos.nii.gz -thr 2.3 zstat_min_SVneg_DEpos_thresh.nii.gz

in_conj_prefix=SVneg_DEpos #SEneg_DEneg #SEpos_DEneg #SEpos_DEpos
fslnums=$(fslstats zstat_min_${in_conj_prefix}_thresh.nii.gz -v)
TOT_VOXELS=${fslnums:0:(`expr index "$fslnums"  " "`)}
echo total non-zero voxels ${TOT_VOXELS}
cluster -i zstat_min_${in_conj_prefix}_thresh.nii.gz -t 2.3 -p 0.05 -d 0.0136188 --oindex=${in_conj_prefix}_cluster_index --olmax=${in_conj_prefix}_lmax.txt \
--osize=${in_conj_prefix}_cluster_size --volume=${TOT_VOXELS} > cluster_zstat1_${in_conj_prefix}.txt

#CONTRAST

easy_thresh=/home/ucjtbob/narps_scripts/easythresh_conj.sh
entropies_z_abs_bigger_msk=${OUTPUTDIR}/second_level_diffs/signed_diffs/${alignment}/entropies_z_abs_bigger_msk.nii.gz
subval_z_abs_bigger_msk=${OUTPUTDIR}/second_level_diffs/signed_diffs/${alignment}/subval_z_abs_bigger_msk.nii.gz
alignment=zstat1s #flip_DE_sign
cd ${OUTPUTDIR}/second_level_diffs/signed_diffs/${alignment}/
mkdir final_contrasts
cd ${OUTPUTDIR}/second_level_diffs/signed_diffs/${alignment}/final_contrasts

filtered_by_entropy=${OUTPUTDIR}/second_level_diffs/signed_diffs/${alignment}/filtered_by_entropy
filtered_by_subval=${OUTPUTDIR}/second_level_diffs/signed_diffs/${alignment}/filtered_by_subval
mkdir $filtered_by_entropy
mkdir $filtered_by_subval

which_sign_all=(neg pos)
which_var_all=(subval entropy)
which_dir_all=(DE_minus_SV SV_minus_DE)

for which_sign in ${which_sign_all[@]}
do
  for which_var in ${which_var_all[@]}
  do
      for which_dir in ${which_dir_all[@]}
      do
        main_fx=${which_sign}_${which_var}_z
        in_conj_prefix=${which_dir}_${which_var}_${which_sign}
        echo $in_conj_prefix

        if [[ $((which_dir)) -eq DE_minus_SV ]]; then
          which_dir2=entropy_minus_subval
        else
          which_dir2=subval_minus_entropy
        fi

        main_contrast=${which_dir2}_zstat1
        bash $easy_thresh "${!main_contrast}" "${!main_fx}" 2.3 $example_func ${in_conj_prefix}

        fslmaths zstat_min_${in_conj_prefix}.nii.gz -thr 2.3 zstat_min_${in_conj_prefix}_thresh.nii.gz

        fslnums=$(fslstats zstat_min_${in_conj_prefix}_thresh.nii.gz -v)
        TOT_VOXELS=${fslnums:0:(`expr index "$fslnums"  " "`)}
        echo total non-zero voxels ${TOT_VOXELS}
        cluster -i zstat_min_${in_conj_prefix}_thresh.nii.gz -t 2.3 -p 0.05 -d 0.0136188 --oindex=${in_conj_prefix}_cluster_index --olmax=${in_conj_prefix}_lmax.txt \
        --osize=${in_conj_prefix}_cluster_size --volume=${TOT_VOXELS} > cluster_zstat1_${in_conj_prefix}.txt

        fslmaths zstat_min_${in_conj_prefix}_thresh.nii.gz -mul $entropies_z_abs_bigger_msk ${filtered_by_entropy}/zstat_min_${in_conj_prefix}_thresh.nii.gz
        fslmaths zstat_min_${in_conj_prefix}_thresh.nii.gz -mul $subval_z_abs_bigger_msk ${filtered_by_subval}/zstat_min_${in_conj_prefix}_thresh.nii.gz

        cd ${filtered_by_entropy}
        fslnums=$(fslstats ${filtered_by_entropy}/zstat_min_${in_conj_prefix}_thresh.nii.gz -v)
        TOT_VOXELS=${fslnums:0:(`expr index "$fslnums"  " "`)}
        echo filtered_by_entropy
        cluster -i ${filtered_by_entropy}/zstat_min_${in_conj_prefix}_thresh.nii.gz -t 2.3 -p 0.05 -d 0.0136188 --oindex=${in_conj_prefix}_cluster_index \
        --olmax=${in_conj_prefix}_lmax.txt --osize=${in_conj_prefix}_cluster_size --volume=${TOT_VOXELS} > cluster_zstat1_${in_conj_prefix}.txt

        cd ${filtered_by_subval}
        fslnums=$(fslstats ${filtered_by_subval}/zstat_min_${in_conj_prefix}_thresh.nii.gz -v)
        TOT_VOXELS=${fslnums:0:(`expr index "$fslnums"  " "`)}
        echo filtered_by_subval
        cluster -i ${filtered_by_subval}/zstat_min_${in_conj_prefix}_thresh.nii.gz -t 2.3 -p 0.05 -d 0.0136188 --oindex=${in_conj_prefix}_cluster_index \
        --olmax=${in_conj_prefix}_lmax.txt --osize=${in_conj_prefix}_cluster_size --volume=${TOT_VOXELS} > cluster_zstat1_${in_conj_prefix}.txt

      done
  done
done


#bash $easy_thresh $entropy_minus_subval_zstat1 $pos_entropy_z 2.3 $example_func ${in_conj_prefix} #effect of pos entropy
#bash $easy_thresh $subval_minus_entropy_zstat1 $pos_subval_z 2.3 $example_func ${in_conj_prefix} #effect of pos value
#bash $easy_thresh $entropy_minus_subval_zstat1 $neg_subval_z 2.3 $example_func ${in_conj_prefix} # bigger than interacts with other variable for negs (neg effect of subval here)
#(should've used zstat2 also in 2nd_level_randomise.sh to avoid confusion)
#bash $easy_thresh $subval_minus_entropy_zstat1 $neg_entropy_z 2.3 $example_func ${in_conj_prefix} # bigger than interacts with other variable for negs (neg effect of entropy here)
#bash $easy_thresh $subval_minus_entropy_zstat1 "${!main_fx}" 2.3 $example_func ${in_conj_prefix}
#cluster --in=zstat_min_${in_conj_prefix}_thresh.nii.gz --thresh=0.0001 --oindex=${in_conj_prefix}_cluster_index --olmax=${in_conj_prefix}_lmax.txt --osize=${in_conj_prefix}_cluster_size
#cd /home/ucjtbob/narps_scripts/

#fslmaths SV_minus_DE_signed.nii.gz -Tmean SV_minus_DE_signed_mn.nii.gz
#fslmaths DE_minus_SV_signed.nii.gz -Tmean DE_minus_SV_signed_mn.nii.gz
